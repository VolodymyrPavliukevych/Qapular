//
//  QCCProjectProcessor+DeploymentConfigurationDataSource.swift
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import QCCDeploymentConfigurationKit
import QCCTargetManagerKit

extension QCCProjectProcessor : QCCDeploymentConfigurationLocalization {
    public func localizationStringForKey(key: String) -> String? {
        
        if let type : QCCActionType = QCCActionType.value(forIdentifier: key) {
            return type.description()
        }
        
        return "Unknown string"
    }
}

extension QCCProjectProcessor : QCCDeploymentConfigurationDataSource {
    
    public func targetItems() -> [String : String] {
        
        var dictionary : [String : String] = [String : String]()
        
        for (key, value) in self.documentController.applicationTargetManager.targets() {
            if value.schema.availableActions().count != 0 {
                dictionary[key] = value.name
            }
        }
        
        return dictionary
    }
    
    public func actionKeyList() -> [String : String] {
        var dictionary : [String : String] = [String : String]()
        
        for actionType : QCCActionType in QCCActionType.allValues {
            dictionary[actionType.identifier()] = actionType.description()
        }
        
        return dictionary
    }
    
}
