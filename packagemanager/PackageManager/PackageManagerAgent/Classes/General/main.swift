//
//  main.swift
//  PackageManagerAgent
//
//  Created by Volodymyr Pavlyukevich on 6/9/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import PackageManagerAgentProtocol

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(withProtocol: PackageManagerAgentProtocol.self)
        let exportedObject = PMAgent()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}

let delegate = ServiceDelegate()
let listener = NSXPCListener(machServiceName:"com.qapular.PackageManagerAgent");
listener.delegate = delegate;
listener.resume()
NSRunLoop.currentRunLoop().run()
