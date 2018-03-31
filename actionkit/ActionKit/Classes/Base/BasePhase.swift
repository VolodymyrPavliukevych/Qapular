//
//  BasePhase.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Cocoa
import QCCProjectEssenceKit

@objc public enum QCCPhaseResult : Int {
    case Unknown
    case inProgress
    case Success
    case Fail
}

public typealias QCCPhaseFinishedClosureType = (phase : BasePhase, error : Error?) -> (Void)

@objc public class BasePhase: NSObject {
    
    private(set) public var identifier : String
    private(set) public var type : QCCPhaseProcessingQueueType
    internal(set) public var dataSource : QCCActionDataSource
    internal(set) public lazy var runtimeIdentifier : String = {
        return NSUUID().UUIDString
    }()
    
    internal(set) public var result = QCCPhaseResult.Unknown
    internal(set) public var artefactEssences : [QCCProjectEssence] = [QCCProjectEssence]()
    private(set) public var action : BaseAction
    
    public var phaseFinishedClosure : QCCPhaseFinishedClosureType?

    
    public init(identifier: String, type: QCCPhaseProcessingQueueType, dataSource: QCCActionDataSource, action : BaseAction) {
        self.identifier = identifier
        self.type = type
        self.dataSource = dataSource
        self.action = action
    }


    public func launch() ->Void {
        self.result = QCCPhaseResult.inProgress
    }
    
    override public var description: String {
        return super.description + "\n[identifier: " + self.identifier + "]\n[runtimeIdentifier: " + self.runtimeIdentifier + "]\n"
    }
}
