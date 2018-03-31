//
//  BaseAction.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Cocoa
import QCCTaskManagerKit
import QCCProjectEssenceKit

public typealias QCCActionProgressClosureType = (action : BaseAction, progress : NSProgress, error: NSError?) -> (Void)
public typealias QCCActionReportClosureType = (action : BaseAction, phase: BasePhase, report: [String:String]) -> (Void)

@objc public enum QCCActionState : Int {
    case Initialized
    case Stoped
    case inProgress
    case Success
    case Fail
}

public protocol QCCActionDataSource : NSObjectProtocol {
    // General
    func temporaryDirectoryURL(action: BaseAction) -> NSURL

    // Action
    func numberOfPhaseInAction(action: BaseAction) -> Int
    func phaseIdentifier(forAction action: BaseAction, atIndex index: Int) -> String?

    // Phase
    func phaseQueueType(forAction action: BaseAction, atIndex index: Int) -> QCCPhaseProcessingQueueType
    func objectQueueType(forAction action: BaseAction, phase : BasePhase) -> QCCObjectProcessingQueueType
    
    
    func phaseObjectTypeMask(ForAction action: BaseAction, phase: BasePhase) -> QCCPhaseObjectTypeMask
    
    /**
    Interface to get list of objects for each of queue : Concurrent | Serial for processing. Interface for (ProjectSource | AttachedSource) QCCPhaseObjectType
    
    - Parameters:
        - Action: current runtime action
        - Phase: current runtime phase
        - Queue:  Concurrent | Serial
     
    - Returns: Array of QCCProjectEssence.
    */
    
    func objectsForProcessing(byAction action: BaseAction, phase: BasePhase) -> [QCCProjectEssence]?

    /**
    Interface provides Phase Identefier producing (artefacts) -> objects for selected phase. Each of queue : Concurrent | Serial for processing. Interface for PostPhaseArtefact QCCPhaseObjectType
    
    - Parameters:
    - Action: current runtime action
    - Phase: current runtime phase
    - Queue:  Concurrent | Serial
    
    - Returns: Phase identifier.
    */

    func objectProducingPhaseIdentifiers(forAction action: BaseAction, phase: BasePhase, processingQueueType : QCCObjectProcessingQueueType) -> [String]?
    
    func toolForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> String?
    
    func propertiesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> [String]
    
    func objectPrefixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> [String]
    func objectPostfixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> [String]

    func patternKey() -> String
    
    func objectPathPatternForProcessing(byAction action: BaseAction, phase: BasePhase) -> String?
    func objectNamingPatternForProcessing(byAction action: BaseAction, phase: BasePhase) -> String?
    
    func artefactForProcessing(byAction action: BaseAction, phase: BasePhase, fromObject object : QCCProjectEssence) -> QCCProjectEssence?

    func artefactPrefixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> [String]
    func artefactPostfixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString : String) -> [String]
    
    func shouldReverseObjectAndArtefactSection(byAction action: BaseAction, phase: BasePhase, forObject object : QCCProjectEssence) -> Bool
    
    // TODO:
    // FIXME:
    
}

@objc public class BaseAction: NSObject {

    private(set) public var identifier : String
    internal(set) public var state : QCCActionState
    private(set) public var type : QCCActionType
    private(set) public var dataSource : QCCActionDataSource
    
    private(set) public lazy var runtimeIdentifier : String = {
        return NSUUID().UUIDString
    }()
    
    lazy private(set) public var progress : NSProgress = {
        return NSProgress(totalUnitCount: Int64(self.numberOfPhase))
    }()
    
    lazy var numberOfPhase : Int = {
        return self.dataSource.numberOfPhaseInAction(self)
    }()
    
    public var actionProgressClosure : QCCActionProgressClosureType?
    public var actionReportClosure : QCCActionReportClosureType?
    
    public init(identifier: String, type: QCCActionType, dataSource: QCCActionDataSource) {
        self.identifier = identifier
        self.type = type
        self.dataSource = dataSource
        self.state = .Initialized
    }
    
    public func start() ->Void {
        if (self.state == .Initialized) {
            self.state = .inProgress
            launchNextPhase()
        }
    }
    
    public func cancel()->Void {
        self.state = .Stoped
        if let actionProgress = self.actionProgressClosure {
            actionProgress(action: self, progress: self.progress, error: nil)
        }
    }
    
    // MARK: Phase around
    func launchNextPhase()->Void {
    }
    
    func phaseFinishedClosure()->QCCPhaseFinishedClosureType {
        return  {(phase : BasePhase, error : Error?) in
            self.phaseFinished(phase, error: error)
        }
    }
    
    func phaseFinished(phase : BasePhase, error : Error?) -> Void {
    }
    
    override public var description: String {
        return super.description + "\n[identifier: " + self.identifier + "]\n[runtimeIdentifier: " + self.runtimeIdentifier + "]\n"
    }
    
}

