//
//  QCCAction.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation

@objc public class QCCAction : BaseAction {
    
    var preparedPhaseList : [QCCPhase] = [QCCPhase]()
    var processedPhaseList : [QCCPhase] = [QCCPhase]()
    
    override public func start() {        
//        let numberOfPhase : Int = self.dataSource.numberOfPhaseInAction(self)
        
        for index in 0...numberOfPhase {
            guard let phaseIdentifier : String = self.dataSource.phaseIdentifier(forAction: self, atIndex: index) else {
                continue
            }
            
            let phaseQueueType : QCCPhaseProcessingQueueType = self.dataSource.phaseQueueType(forAction: self, atIndex: index)
            let phase : QCCPhase  = QCCPhase(identifier:phaseIdentifier, type: phaseQueueType, dataSource:self.dataSource, action:  self)
            
            switch (phaseQueueType) {
            case .Serial:
                preparedPhaseList.append(phase)
                break
            case .Concurrent:
                launchPhase(phase)
                break
            }
        }
        super.start()
    }
    
    func launchPhase(phase: QCCPhase)->Void {
        processedPhaseList.append(phase)
        phase.phaseFinishedClosure = phaseFinishedClosure()
        phase.launch()
    }
    
    override func launchNextPhase()->Void {
        super.launchNextPhase()
        
        if (self.state == .Stoped) {
            return
        }
        
        if let phase: QCCPhase = preparedPhaseList.first {
            preparedPhaseList.removeFirst()
            launchPhase(phase)
        } else {
            // There isn't to add in queue
        }
    }
    
    override func phaseFinished(phase: BasePhase, error : Error?) {
        
        if phase.result != QCCPhaseResult.Fail {
            if (phase.type == QCCPhaseProcessingQueueType.Serial){
                self.launchNextPhase()
            }
        } else {
            self.state = QCCActionState.Fail
        }
        
        
        self.progress.completedUnitCount = self.progress.completedUnitCount.successor()
        
        if preparedPhaseList.count == 0 && processedPhaseList.count == numberOfPhase {
            self.state = QCCActionState.Success
        }
        
        if let actionProgress = self.actionProgressClosure {
            actionProgress(action: self, progress: self.progress, error: error?.fondationError())
        }
    }
    
    
}
