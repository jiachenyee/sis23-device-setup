//
//  ProxyServer.swift
//  udpProxy
//
//  Created by XIAOWEI WANG on 2018/11/11.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation
import PlaygroundSupport

extension ProxyServer: GCDAsyncUdpSocketDelegate {
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        let (host4, port4, family4) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        ProxyLogger.info( String(format:  "Connected to %@, %d, %d", host4, port4, family4)) //-debug-log
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let e = error {
            ProxyLogger.error( e.localizedDescription) //-debug-log
        } else {
            ProxyLogger.error("Unknow error") //-debug-log
        }
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
      
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        if let e = error {
            ProxyLogger.error(String(format: "tag: %d, error: %@", tag, e.localizedDescription)) //-debug-log
        } else {
            ProxyLogger.error(String(format: "tag: %d", tag)) //-debug-log
        }
    }
    
    func createDronePuppet(id: Int, address: Data) -> DronePuppet {
        return DronePuppet(id: id, address: address, socket: _commanderSocket!)
    }
    
    func buildDroneKey(address: Data) -> String {
        let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        return String(format: "%@:%d", host, port)
    }

    func addDrone(address: Data) {
        _commanderQueue.async {
            let droneKey = self.buildDroneKey(address: address)
            let puppet = self.createDronePuppet(id: self._drones.count + 1, address: address)
            let drone = Drone(dronePuppet: puppet)
            self._drones.append(drone)
            self._droneMapping[droneKey] = drone
        }
    }

    func processCommandData(_ sock: GCDAsyncUdpSocket, data: Data, address: Data) {
        // date from drones
        let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        let droneKey = self.buildDroneKey(address: address)
        if let response = String(data: data, encoding: .utf8) {
            ProxyLogger.info("\(response)")
            if let drone = fetchDrone(key: droneKey) {
                if let clientAddress = _clientAddress {
                    let wrappedResponse = [
                        "address": drone.puppet.stringAddress,
                        "port": drone.puppet.port,
                        "id": drone.puppet.id,
                        "command": response
                    ].toJSON()!.data(using: .utf8)!
                    _forwarderSocket?.send(wrappedResponse, toAddress: clientAddress, withTimeout: 0, tag: 0)
                }
                drone.notifyResponse(response: response)
            } else {
                if response.lowercased() == "ok" {
                    if _limitReached {
                        DroneLog.warning(String(format: "drones exceed the limit, ignore: %@, %d, %@",host, port, response)) //-debug-log
                        return
                    }
                    self.addDrone(address: address)
                    DroneLog.info(String(format: "drone found: %@, %d, %@",host, port, response)) //-debug-log
                    _limitReached = allFound
                    if _limitReached {
                        DroneLog.info(String(format: "Found %d drones", maxDrones)) //-debug-log
                        _semaphore.signal()
                        sock.endCurrentSend()
                        sock._sendQueue.removeAll()
                    }
                }
            }

        } else {
            ProxyLogger.error(String(format: "processCommandData: : %@, %d, %@",host, port, "invalid message")) //-debug-log
        }
    }

    func processOSDData(data: Data, address: Data) {
        let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        let droneKey = self.buildDroneKey(address: address)
        if let response = String(data: data, encoding: .utf8) {
            if response.lowercased().starts(with: "mid:") || response.lowercased().starts(with: "pitch:"){ // status info
                if let drone = fetchDrone(key: droneKey) {
                    if let clientAddress = _clientAddress {
                        let osdData = [
                            "address": host,
                            "port": port,
                            "osd": response
                        ].toJSON()!
                        _OSDSocket?.send(osdData.data(using: .utf8)!, toAddress: clientAddress, withTimeout: 0, tag: 0)
                    }
                    if _clientAddress == nil {
                        ProxyLogger.debug("update status")
                        let status = DroneStatus.buildFromString(statusString: response)
                        drone.puppet.status = status
                        let command = CommandFactory.Command.droneStatus(status: status)
                        if let handler = PlaygroundPage.current.liveView as? LiveViewFrameController {
                            DispatchQueue.main.async {
                                _ = handler.handleMessageFromPage(command.toPlaygroundValue(droneId: drone.puppet.id))
                            }
                        }
                    }
                }
            }
        } else {
            ProxyLogger.error(String(format: "processOSDData: : %@, %d, %@",host, port, "invalid message")) //-debug-log
        }
    }
    
    func sendToDrone(commandDict: [String: Any?]) {
        if let command = commandDict["command"] as? String,
            let id = commandDict["id"] as? Int {

            if let drone = fetchDrone(id: id) {
                _ = drone.canQueueCommand(commandString: command, command: .flyBackward(cm: 1))
            }
        }
    }

    func buildDronesData(count: Int) -> Data {
        var droneList = Array<Dictionary<String, Any?>>()
        
        for (index, drone) in self.drones.enumerated() {
            if index >= count {
                break
            }
            var droneData = [String: Any?]()
            droneData["address"] = drone.puppet.stringAddress
            droneData["port"] = drone.puppet.port
            droneData["id"] = drone.puppet.id
            droneList.append(droneData)
        }
        return ["command": "connect", "drones" : droneList].toJSON()!.data(using: .utf8)!
    }

    func processForwarderData(data: Data, address: Data) {
        // date from code process

        if let response = String(data: data, encoding: .utf8), let dict: [String: Any?] = response.toDict(),
            let command = dict["command"] as? String {
            ProxyLogger.info("\(response)")
            switch command {
            case "connect":
                let count = ( dict["count"] as? Int ) ?? 1
                if self.drones.count >= count {
                    _clientAddress = address
                    _forwarderQueue.async {
                        let data = self.buildDronesData(count: count)
                        self._forwarderSocket?.send(data, toAddress: address, withTimeout: 0, tag: 0)
                    }
                }
            case "client is closing":
                _clientAddress = nil
                let data = ["command": "disconnected"].toJSON()!.data(using: .utf8)!
                self._forwarderSocket?.send(data, toAddress: address, withTimeout: 0, tag: 0)
            default:
                _commanderQueue.async {
                    self.sendToDrone(commandDict: dict)
                }
            }
        } else {
            let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
            ProxyLogger.error(String(format: "%@, %d, %@",host, port, "invalid message")) //-debug-log
        }
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        let stringAddress = String(format: "%@:%d", host, port)
        switch sock.localPort {
        case _commanderPort:
            _commanderQueue.async {
                self.processCommandData(sock, data: data, address: address)
            }

        case _OSDPort:
            _OSDQueue.async {
                self.processOSDData(data: data, address: address)
            }

        case _forwarderPort:
            _forwarderQueue.async {
                self.processForwarderData(data: data, address: address)
            }

        default:
            assert(false)
        }

        do {
            try sock.receiveOnce()
        } catch {
             ProxyLogger.error(
                String(format: "endpoint: %@, %d, %@", stringAddress, error.localizedDescription)
            )
        }
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        //
    }
}
