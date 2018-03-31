//
//  QCCProjectProcessor+QCCProjectEnvironmentSource.swift
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation

extension QCCProjectProcessor : QCCProjectEnvironmentSource {

    public func clangOptionsForFileOptions(fileOptions: [String : String]?) -> [String] {
        
        guard let option : [String : String] = fileOptions else {
            return [String]()
        }
        
        guard let UTTypeString : String = option[QCCProjectEnvironmentSourceDocumentUTTypeOptionKey] else {
            return [String]()
        }
        
        
        let actionKey : String = self.actionKey(QCCActionType.Analyze)
        if let actionIdentifier : String = self.deploymentSchema().actionIdentifierForActionKey(actionKey) {
            
            for index in 0...self.deploymentSchema().numberOfPhaseForActionKey(actionKey) {
                if let phase = self.deploymentSchema().phaseForActionIdentifier(actionIdentifier, forIndex: index) {
                if let phaseIdentifier = self.deploymentSchema().phaseIdentifierForPhase(phase) {
                                   return self.propertiesForProcessing(byActionIdentifier: actionIdentifier,
                                                                 actionType: QCCActionType.Analyze,
                                                                 phaseIdentifier: phaseIdentifier,
                                                                 UTTypeString:UTTypeString)
                    }
                }
            }
        }
        return [String]()
    }
}

extension QCCProjectProcessor {

    func environmentString(forKey environmentKey : String) -> String? {
        
        switch environmentKey {
        case "SELECTED_BOARD_PORT":
            return self.selectedBSDPortName
        default:
            return nil
        }
    
    }
}
