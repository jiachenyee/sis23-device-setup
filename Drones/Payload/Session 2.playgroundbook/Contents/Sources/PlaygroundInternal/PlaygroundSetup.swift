//
//  PlaygroundSetup.swift
//  PlaygroundSetup
//
/*
 
 * @version 1.0
 
 * @date Sep 2018
 
 *
 
 *
 
 * @Copyright (c) 2018 Ryze Tech
 
 *
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 
 * of this software and associated documentation files (the "Software"), to deal
 
 * in the Software without restriction, including without limitation the rights
 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 
 * copies of the Software, and to permit persons to whom the Software is
 
 * furnished to do so, subject to the following conditions:
 
 *
 
 * The above copyright notice and this permission notice shall be included in
 
 * all copies or substantial portions of the Software.
 
 *
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 
 * SOFTWARE.
 
 * *
 * Created by XIAOWEI WANG on 03/09/2018.
 * support@ryzerobotics.com
 *
 
 */

import UIKit
import PlaygroundSupport

private var _messageHandler = MessageHandler()
private var _manager: DroneManager? = nil
public var Tello: Drone!
private var _debugDrone: String? = nil
private var _debugProxy: String? = nil

var debugProxy: String? {
    return _debugProxy
}

var debugDrone: String? {
    return _debugDrone
}

public var TelloManager: DroneManager {
    get {
        if _manager == nil {
            _manager = DroneManager()
            _manager?._delegate = DroneCommandResponse()
        }
        return _manager!
    }
}

public func setDebugDrone(ipAddress: String ) {
    _debugDrone = ipAddress
}

public func setDebugProxy(ipAddress: String ) {
    _debugProxy = ipAddress
}

public func scanProxyOne() -> Int {
    if let tmp = _manager {
        tmp.close()
        _manager = nil
    }
    
    let count = TelloManager.connectToProxy(ipAddress: "127.0.0.1", count: 1)
    if count > 0 {
        Tello = TelloManager.drones.first!
        while !Tello.statusReady {
            delay(milliseconds: 500)
        }
    } else {
        Tello = Drone(dronePuppet: DronePuppet())
    }
    return count
}

public func scanOne() -> Int {
    if DroneManager.isProxyMode {
        return scanProxyOne()
    }
    if let tmp = _manager {
        tmp.close()
        _manager = nil
    }

    let count = TelloManager.scan(ipAddress: _debugDrone ?? "192.168.10.1")
    if count > 0 {
        Tello = TelloManager.drones.first!
        while !Tello.statusReady {
            delay(milliseconds: 500)
        }
    } else {
        Tello = Drone(dronePuppet: DronePuppet())
    }
    return count
}

internal func scan(number: Int, timeout: TimeInterval = 10) -> Int {
    if let tmp = _manager {
        tmp.close()
        _manager = nil
    }
    
    let count = TelloManager.scan(number: number, timeout: timeout)
    _ = TelloManager.drones.getSN()
    return count
}

public func _setup(controllerName: String) {
    initLogger(level: .debug)
    PlaygroundPage.current.liveView = instantiateLiveView(controllerName: controllerName)
}

public func _setup(storyboardName: String) {
    initLogger(level: .debug)
    PlaygroundPage.current.liveView = instantiateLiveView(storyboardName: storyboardName)
}

public func _setupOneDroneEnv(mon: Bool = false, proxyMode: Bool = true) {
    initLogger(level: .debug)
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        DroneLog.error("Always-on live view not configured in this page's LiveView.swift.")
        return
    }

    remoteView.delegate = _messageHandler
    
    _sendToView(value: .string("ping"))
    
    repeat {
        RunLoop.main.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1))
    } while !_messageHandler.isConnected
    
    DroneLog.error("set MessageHandler.")
    
    DroneManager.isProxyMode = proxyMode
    
    if scanOne() > 0 {
        _sendToView(value: .dictionary([
            "action":  PlaygroundValue.string("connected"),
            "value" :  PlaygroundValue.string("Connected to Drone")
            ]))
    } else {
        _sendToView(value: .dictionary([
            "action":  PlaygroundValue.string("status"),
            "value" :  PlaygroundValue.string("No drones found")
            ]))
    }
    PlaygroundPage.current.needsIndefiniteExecution = true
}

public func _sendToView(value: PlaygroundValue) {
    if let handler = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
        handler.send(value)
    }
}

public func _setupMultipleDronesEnv() {
    initLogger(level: .debug)
    PlaygroundPage.current.needsIndefiniteExecution = true
}

public func _cleanOneDroneEnv() {
    TelloManager.close()
    PlaygroundPage.current.needsIndefiniteExecution = false
}

public func _cleanMultipleDroneEnv() {
    TelloManager.sync(seconds: 10)
    TelloManager.close()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
