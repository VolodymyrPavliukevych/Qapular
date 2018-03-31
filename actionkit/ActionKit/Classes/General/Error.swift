//
//  Error.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation

@objc public enum Error :Int,  ErrorType {
    case PhaseResultFail        = 10001
    case ActionStoped           = 10002
    case ToolDoesNotExist       = 10003
    
    public func fondationError() -> NSError {
        return NSError(domain: domain(), code: self.rawValue, userInfo: userInfo())
    }
    
    func domain() -> String {
        return "com.qapular.ActionKit"
    }
    
    
    func userInfo() -> [NSObject : AnyObject] {
        
        var userInfo : [NSObject : AnyObject] = [NSObject : AnyObject]()
        
        userInfo[NSLocalizedDescriptionKey] = localizedDescription();
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = localizedRecoverySuggestion();
        
        return userInfo
    }
    
    func localizedDescription() -> String {
        switch self {
        case .ToolDoesNotExist:
            return NSLocalizedString("Processing command line tool does not exist.", comment: "Error localized description");
            
        case .PhaseResultFail:
            return NSLocalizedString("Some of phase return error.", comment: "Error localized description");
            
        default:
            return "Unknown error."
        }
    }
    
    func localizedRecoverySuggestion() -> String {
        switch self {
        case .ToolDoesNotExist:
            return NSLocalizedString("Please, check is your tool exist.", comment: "Error localized description");
        case .PhaseResultFail:
            return NSLocalizedString("Please, check debug output, error will be market with red color.", comment: "Error localized description");
            
        default:
            return "Unfortunately I don't know how to help you. Please, send more information on https://qapular.com/contact"
        }
    }
}
