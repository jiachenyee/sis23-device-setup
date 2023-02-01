//
//  ProxyServer.swift
//  udpProxy
//
//  Created by XIAOWEI WANG on 2018/11/11.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation

class DispatchQueueWrapper {
    private var _queue: DispatchQueue
    private let _queueKey = DispatchSpecificKey<()>()
    
    var raw: DispatchQueue {
        return _queue
    }
    init(label: String) {
        _queue = DispatchQueue(label: label)
        _queue.setSpecific(key: _queueKey, value: ())
    }

    func sync<R>(block: () -> R) -> R {
        var result : R
        if( DispatchQueue.getSpecific(key: _queueKey) != nil) {
            result = block()
        } else {
            result = _queue.sync(execute: block)
        }
        return result
    }
    
    func async(block: @escaping () -> Void) {
        if( DispatchQueue.getSpecific(key: _queueKey) != nil) {
            block()
        } else {
            _queue.async(execute: block)
        }
    }
}

public class ProxyServer {
    
    internal var _drones: [Drone] = [Drone]()
    internal var _droneMapping: [String: Drone] = [String:Drone]()
    
    internal var _commanderSocket: GCDAsyncUdpSocket? = nil
    internal var _forwarderSocket: GCDAsyncUdpSocket? = nil
    internal var _OSDSocket: GCDAsyncUdpSocket? = nil
    
    internal var _commanderQueue: DispatchQueueWrapper
    internal var _forwarderQueue: DispatchQueueWrapper
    internal var _OSDQueue: DispatchQueueWrapper

    internal var _commanderPort: UInt16 = 57777
    internal var _forwarderPort: UInt16 = 8889
    internal var _OSDPort: UInt16 = 8890
    
    private var _callback: ((_ server: ProxyServer) -> Void)? = nil
    
    internal var _limitReached = false
    internal var _semaphore: DispatchSemaphore
    

    internal var _delegateQueue: DispatchQueue
    private var _closed = false
    
    internal var _clientAddress: Data? = nil
    
    var clientAddress: Data? {
        return _forwarderQueue.sync { () -> Data? in
            return _clientAddress
        }
    }
    
    private var _maxDrones = 4
    
    public var allFound: Bool {
        return _commanderQueue.sync { () -> Bool in
            return _drones.count >= _maxDrones
        }
    }

    public var maxDrones: Int {
        return _commanderQueue.sync { () -> Int in
            return _maxDrones
        }
    }
    
    public var drones: [Drone]  {
        return _commanderQueue.sync(block: { () -> [Drone]  in
            return _drones
        })
    }
    
    func fetchDrone(key: String) -> Drone? {
        return _commanderQueue.sync(block: { () -> Drone? in
            return _droneMapping[key]
        })
    }
    
    func fetchDrone(id: Int) -> Drone? {
        return _commanderQueue.sync(block: { () -> Drone? in
            return _drones.first(where: { (drone) -> Bool in
                return drone.puppet.id == id
            })
        })
    }
    
    /// Constructor
    public init() {
        _semaphore  = DispatchSemaphore(value: 0)
        
        _commanderQueue = DispatchQueueWrapper(label: "CommanderQueue")
        _forwarderQueue = DispatchQueueWrapper(label: "ForwarderQueue")
        _OSDQueue = DispatchQueueWrapper(label: "OSDQueue")
        
        _delegateQueue = DispatchQueue(label: "DelegateQueue")
    }
    
    deinit {
        self.close()
    }
    
    public func startOSDListener() {
        guard _OSDSocket == nil else {
            return
        }
        let socketQueue = DispatchQueue(label: "OSDSocketQueue")
        _OSDSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: _OSDQueue.raw, socketQueue: socketQueue)
        if let socket = _OSDSocket {
            socket.isIPv4Enabled = true
            socket.isIPv6Enabled = false
            
            do {
                if !socket.didBind {
                    try socket.bind(toPort: _OSDPort)
                    try socket.receiveOnce()
                }
            } catch {
                ProxyLogger.error(String(format: "forwarder listening error: %@", error.localizedDescription)) //-debug-log
            }
        }
    }
    
    public func startForwarder() {
        let socketQueue = DispatchQueue(label: "ForwarderSocketQueue")
        _forwarderSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: _forwarderQueue.raw, socketQueue: socketQueue)
        if let socket = _forwarderSocket {
            socket.isIPv4Enabled = true
            socket.isIPv6Enabled = false
            
            do {
                if !socket.didBind {
                    try socket.bind(toPort: _forwarderPort)
                    try socket.receiveOnce()
                }
            } catch {
                ProxyLogger.error(String(format: "forwarder listening error: %@", error.localizedDescription)) //-debug-log
            }
        }
    }
    
    public func startCommander() {
        let socketQueue = DispatchQueue(label: "CommanderSocketQueue")
        _commanderSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: _commanderQueue.raw, socketQueue: socketQueue)
        if let socket = _commanderSocket {
            socket.isIPv4Enabled = true
            socket.isIPv6Enabled = false
            
            do {
                if !socket.didBind {
                    try socket.bind(toPort: _commanderPort)
                    try socket.receiveOnce()
                }
            } catch {
                ProxyLogger.error(String(format: "commander listening error: %@", error.localizedDescription)) //-debug-log
            }
        }
    }
    
    let _ensureGroup = DispatchGroup()
    public func close() {
    }
    
    public func scan(ipAddress: String) -> Int {
        let addr4 = GCDAsyncUdpSocket.addressAndPortToData(stringAddress: ipAddress, port: 8889)
        var count = 0
        if let addr = addr4 {
            count = scan(maxDrones: 1, addresses: [addr])
        }
        DroneLog.info(String(format: "--------new scan for 1 drones( %@ ), count: %d--------", ipAddress, count)) //-debug-log
        return count
    }
    
    @discardableResult
    public func scan(number: Int, timeout: TimeInterval = 10) -> Int {
        let addresses = GCDAsyncUdpSocket.getSubnetAddresses(interfaceDescription: "en0", port: 8889)
        let count = scan(maxDrones: number, addresses: addresses, timeout: timeout)
        if count > 0 {
            drones.getSN()
            drones.sync(seconds: 10)
            drones.mon()
            drones.sync(seconds: 10)
            drones.mdirection(direction: 0)
            drones.sync(seconds: 10)
        }
        return count
    }

    func pingHosts( addresses: [Data] ) -> [Data] {
        var activeHosts = [Data]()
        let queue: OperationQueue = OperationQueue()
        queue.maxConcurrentOperationCount = 50
        for addr in addresses {
            let (hostname, _, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr)
            let po = PingOperation(ip: hostname) { (error, str) in
                if error == nil {
                    DroneLog.debug(String(format: "%@ is active", hostname))
                    activeHosts.append(addr)
                }
            }
            queue.addOperation(po)
        }
        queue.waitUntilAllOperationsAreFinished()
        return activeHosts
    }

    func scan(maxDrones: Int, addresses: [Data], timeout: TimeInterval = 2) -> Int {
        var result = 0
        _commanderQueue.sync {
            _maxDrones = maxDrones > addresses.count ? addresses.count : maxDrones
            _drones.removeAll()
            _droneMapping.removeAll()
            _limitReached = false
        }
        
        let activeHosts = pingHosts(addresses: addresses)
        DroneLog.info(String(format: "--------new scan for %d drones, timeout: %d--------", maxDrones, UInt(timeout))) //-debug-log
        DroneLog.info(String(format: "--------active hosts: %d--------", activeHosts.count)) //-debug-log
        let socket = _commanderSocket!
        var rounds = 0
        let maxRounds = 1
        while result < maxDrones {
            rounds += 1
            if result < maxDrones {
                DroneLog.info(String(format: "new round: %d rounds", rounds)) //-debug-log
            }
            
            for addr in activeHosts {
                socket.send("command".data(using: .utf8)!, toAddress: addr, withTimeout: timeout, tag: -1)
                let (hostname, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr)
                DroneLog.debug(String(format: "scanning port %@:%d", hostname, port))
            }
            _ = _semaphore.wait(timeout: .now() + timeout)
            _commanderQueue.sync {
                result = _drones.count
            }
            if rounds >= maxRounds {
                break
            }
        }
        DroneLog.info(String(format: "scan result: %d found", result)) //-debug-log

        if result > 0 {
            startOSDListener()
        }
        
        return result
    }
}
