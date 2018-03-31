//
//  PMAgent.swift
//  PackageManager
//
//  Created by Volodymyr Pavlyukevich on 6/9/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import PackageManagerAgentProtocol


extension PMAgent : PackageManagerAgentProtocol {
    
    @objc func checkAgentStatus(key: String, response : PackageManagerAgentProtocolResponse) -> Bool {
        response(response:"ok", error: nil)
        return true;
    }
}

class PMAgent {
    
}
