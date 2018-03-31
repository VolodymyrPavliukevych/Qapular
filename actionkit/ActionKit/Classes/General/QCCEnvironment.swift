//
//  QCCEnvironment.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation

// Block syntaks
//public typealias STPDataModelResponseClosureType = (uiResponseStatus : STPDataModelUIResponseStatus, items : [STPItem]) -> (Void)

/**
 🔔🔔
 Please update Header.h if you change anything here.
 🔔🔔
 
   Using mask
 var mask : QCCPhaseObjectTypeMask = [
 QCCPhaseObjectTypeMask.ProjectSource, 
 QCCPhaseObjectTypeMask.AttachedSource, 
 QCCPhaseObjectTypeMask(obectType: QCCPhaseObjectType.PostPhaseArtefact)
 ]

 if mask.contains(QCCPhaseObjectTypeMask.ProjectSource) { }
 mask = mask.union(QCCPhaseObjectTypeMask.PostPhaseArtefact)
 mask.remove(QCCPhaseObjectTypeMask.ProjectSource)

*/

@objc public enum QCCPhaseObjectType : Int {
    case ProjectSource      = 0b0001
    case AttachedSource     = 0b0010
    case PostPhaseArtefact  = 0b0100
    case Command            = 0b1000
}

public struct QCCPhaseObjectTypeMask : OptionSetType {
    public let rawValue : Int
    public init(rawValue:Int) { self.rawValue = rawValue }
    public init(obectType:QCCPhaseObjectType) { self.rawValue = obectType.rawValue }
    
    public static let None                 = QCCPhaseObjectTypeMask(rawValue:0b0000)
    public static let ProjectSource        = QCCPhaseObjectTypeMask(rawValue:0b0001)
    public static let AttachedSource       = QCCPhaseObjectTypeMask(rawValue:0b0010)
    public static let PostPhaseArtefact    = QCCPhaseObjectTypeMask(rawValue:0b0100)
    public static let Command              = QCCPhaseObjectTypeMask(rawValue:0b1000)
    public static let All                  = QCCPhaseObjectTypeMask(rawValue:0b1111)
}


@objc public enum QCCObjectProcessingQueueType : Int {
    case Serial
    case Concurrent
}

@objc public enum QCCPhaseProcessingQueueType : Int {
    case Serial
    case Concurrent
}

@objc public enum QCCActionType : Int {
    
    case Clear
    case Index
    case Analyze
    case Compile
    case Upload
    case Run
    case Debug
    case Erase

    public static let allValues = [Clear, Index, Analyze, Compile, Upload, Run, Debug, Erase]
    
    public static func value(forIdentifier identifier : String) -> QCCActionType? {
    
        for type in QCCActionType.allValues {
            if (type.identifier() == identifier) {
                return type
            }
        }
        
        return nil
    }
    
    public func description() -> String {
        switch self {
        case .Clear:
            return "Clear action type."
            
        case .Index:
            return "Index action type."
            
        case .Analyze:
            return "Analyze action type."
            
        case .Compile:
            return "Build action type."
            
        case .Upload:
            return "Upload action type."
            
        case .Run:
            return "Run action type."
            
        case .Debug:
            return "Debug action type."
            
        case .Erase:
            return "Erase action type."
        }
    }
    
    public func identifier() -> String {
        switch self {
        case .Clear:
            return "%CLEAR%"
            
        case .Index:
            return "%INDEX%"
            
        case .Analyze:
            return "%ANALYZE%"
            
        case .Compile:
            return "%COMPILE%"
            
        case .Upload:
            return "%UPLOAD%"
            
        case .Run:
            return "%RUN%"
            
        case .Debug:
            return "%DEBUG%"
            
        case .Erase:
            return "%ERASE%"
        }
    }
}

