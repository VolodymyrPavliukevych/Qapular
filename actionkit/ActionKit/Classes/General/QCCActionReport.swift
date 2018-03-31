//
//  QCCActionReport.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation

let QCCActionReportArgumentsSeparator : String = " "

@objc public enum QCCActionReportType : Int {
    
    case LaunchComand
    case LaunchArgs
    case Output
    case Error
    
    public static let allValues = [LaunchComand, LaunchArgs, Output, Error]
    
    public static func value(forIdentifier identifier : String) -> QCCActionReportType? {
        
        for type in QCCActionReportType.allValues {
            if (type.identifier() == identifier) {
                return type
            }
        }
        
        return nil
    }
    
    public func description() -> String {
        switch self {
        case .LaunchComand:
            return "Launch comand."
            
        case .LaunchArgs:
            return "Launch args."
            
        case .Output:
            return "Output"
            
        case .Error:
            return "Error"
        }
    }
    
    public func identifier() -> String {
        switch self {
        case .LaunchComand:
            return "QCCActionReportLaunchComand"
            
        case .LaunchArgs:
            return "QCCActionReportLaunchArgs"
            
        case .Output:
            return "QCCActionReportOutput"
            
        case .Error:
            return "QCCActionReportError"
        }
    }
}
