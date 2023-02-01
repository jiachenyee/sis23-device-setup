//
//  MessageHandler.swift
//  Book_Sources
//
//  Created by XIAOWEI WANG on 2018/11/14.
//

import Foundation
import PlaygroundSupport

class MessageHandler: PlaygroundRemoteLiveViewProxyDelegate {
    public var isConnected = false
    func remoteLiveViewProxy( _ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
                              received message: PlaygroundValue ) {
        isConnected = true
        // DroneLog.error("\(Date())\(Thread.current)---Received a message from the always-on live view\(message)")
    }

    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        
    }
}
