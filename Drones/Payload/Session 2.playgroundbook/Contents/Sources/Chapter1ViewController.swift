//
//  Chapter1ViewController.swift
//  Chapter1ViewController
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

@objc(SoloViewBaseController)
public class SoloViewBaseController: LiveViewBaseController {
    let proxyServer = ProxyServer()

    static var loaded = false
    
    let _scanQueue = DispatchQueue(label: "Scan")
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        lbVersion.text = NSLocalizedString("Scanning Tellos...", comment: "Scanning Tellos...")
        initLogger()
        DroneManager.isProxyMode = true
        proxyServer.startForwarder()
        self.proxyServer.startCommander()
        self.scanDrone()

        if ( !SoloViewBaseController.loaded) {
            SoloViewBaseController.loaded = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.updateStatusTimeOut()
            }

        } else {
            DroneLog.debug("viewDidLoad more than once")
        }
    }
    
    @objc func updateStatusTimeOut() {
        let currentDate = Date()
        let diff = currentDate.timeIntervalSince( _lastTimestampOfUpdatingStatus )
        DroneLog.debug("currentDate: \(currentDate), \(_lastTimestampOfUpdatingStatus), \(diff)")
        if  diff > 2 {
            _lastTimestampOfUpdatingStatus = Date()
            DroneLog.debug("updating status expired")
            DispatchQueue.main.async {
                self.lbVersion.text = NSLocalizedString("Wifi", comment: "Scanning Tellos...")
                for battery in self.batteries {
                    battery.image = UIImage(named: "battery_ic_11")
                    battery.alpha = 0.3
                }
            }
            heartbeat()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DroneLog.debug("asyncAfter updateStatusTimeOut")
            self.updateStatusTimeOut()
        }
    }

    func heartbeat() {
        DroneLog.debug("heartbeat")
        scanDrone()
    }

    func scanDrone() {
        _scanQueue.async {
            // setDebugDrone(ipAddress: "192.168.3.87")
            let address = debugDrone ?? "192.168.10.1"
            DroneLog.debug("scanning drones[\(address)]...")
            let count = self.proxyServer.scan(ipAddress: address)
            DroneLog.debug("scanning result: \(count)")
            if count > 0 {
                DispatchQueue.main.async {
                    self.lbVersion.text = nil
                }
            }
        }
    }
}

@objc(Chapter1_1ViewController)
class Chapter1_1ViewController: SoloViewBaseController {
}

@objc(Chapter1_2ViewController)
class Chapter1_2ViewController: SoloViewBaseController {
}

@objc(Chapter1_3ViewController)
class Chapter1_3ViewController: SoloViewBaseController {
}

@objc(Chapter1_4ViewController)
class Chapter1_4ViewController: SoloViewBaseController {
}

@objc(Chapter1_5ViewController)
class Chapter1_5ViewController: SoloViewBaseController {
}

@objc(Chapter1_6ViewController)
class Chapter1_6ViewController: SoloViewBaseController {
}

@objc(Chapter1_7ViewController)
class Chapter1_7ViewController: SoloViewBaseController {
}

@objc(Chapter1_8ViewController)
class Chapter1_8ViewController: SoloViewBaseController {
}

@objc(Chapter1_9ViewController)
class Chapter1_9ViewController: SoloViewBaseController {
}

@objc(Chapter1_10ViewController)
class Chapter1_10ViewController: SoloViewBaseController {
}


