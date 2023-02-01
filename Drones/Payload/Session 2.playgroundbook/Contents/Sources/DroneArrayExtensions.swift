//
//  Extensions.swift
//  Book_Sources
//
//  Created by XIAOWEI WANG on 2018/11/18.
//

import Foundation

extension Array where Element == Drone {
    
    @discardableResult
    public func mon() -> Int {
        for drone in self {
            _ = drone.mon()
        }
        return count
    }
    
    @discardableResult
    public func mdirection(direction: Int) -> Int {
        for drone in self {
            _ = drone.mdirection(direction: direction)
        }
        return count
    }
    
    @discardableResult
    public func takeOff() -> Int {
        for drone in self {
            _ = drone.takeOff()
        }
        return count
    }
    
    @discardableResult
    public func getSN() -> Int {
        for drone in self {
            _ = drone.getSN()
        }
        return count
    }
    
    @discardableResult
    public func land() -> Int {
        for drone in self {
            _ = drone.land()
        }
        return count
    }
    
    @discardableResult
    public func flyUp(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyUp(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyDown(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyDown(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyLeft(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyLeft(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyRight(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyRight(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyForward(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyForward(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyBackward(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyBackward(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func turnLeft(degree: Int) -> Int {
        for drone in self {
            _ = drone.turnLeft(degree: degree)
        }
        return count
    }
    
    @discardableResult
    public func turnRight(degree: Int) -> Int {
        for drone in self {
            _ = drone.turnRight(degree: degree)
        }
        return count
    }
    
    @discardableResult
    public func go(x: Int, y: Int, z: Int, speed: UInt) -> Int {
        for drone in self {
            let speed = drone.getSpeed()
            _ = drone.go(x: x, y: y, z: z, speed: speed, marker: "")
        }
        return count
    }
    
    @discardableResult
    public func go(x: Int, y: Int, z: Int, speed: UInt, marker: String) -> Int {
        for drone in self {
            let speed = drone.getSpeed()
            _ = drone.go(x: x, y: y, z: z, speed: speed, marker: marker)
        }
        return count
    }
    
    @discardableResult
    private func transit(x: Int, y: Int, z: Int, pad1: Int, pad2: Int) -> Int {
        for drone in self{
            let speed = drone.getSpeed()
            let m1 = String(format: "m%d", pad1)
            let m2 = String(format: "m%d", pad2)
            _ = drone.jump(x: x, y: y, z: z, speed: speed, yaw: 0, marker1: m1, marker2: m2)
            TelloManager.assessor?.add(action: .transit(x: x, y: y, z: z, pad1: pad1, pad2: pad2))
        }
        return count
    }
    
    @discardableResult
    public func transit(x: Int, y: Int, z: Int) -> Int {
        return transit(x: x, y: y, z: z, pad1: -2, pad2: -2)
    }
    
    @discardableResult
    internal func sync(seconds: UInt = 10) -> Int {
        if count > 1 {
            let group = DispatchGroup()
            let syncTimeout = seconds + 1
            for drone in self {
                drone.sync(group: group, seconds: seconds, timeout: drone.puppet.responseTimeout)
            }
            
            DroneLog.debug(String(format: "before group.wait, wait: %d seconds", syncTimeout)) //-debug-log
            let ret = group.wait(timeout: .now() + TimeInterval(syncTimeout)) == .success
            DroneLog.debug(String(format: "after group.wait, result: %@", ret ? "success" : "timeout")) //-debug-log
        }
        return count
    }
}
