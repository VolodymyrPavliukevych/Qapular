//
//  QCCPhase.swift
//  ActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import QCCTaskManagerKit
import QCCProjectEssenceKit

@objc public class QCCPhase : BasePhase {
    var existedToolList : [String : Bool] = [String : Bool]()
    var processingObjects : [String : QCCProjectEssence] = [String : QCCProjectEssence]()
    
    lazy var taskManager : QCCTaskManager = {
        if (self.objectProcessingQueueType() == QCCObjectProcessingQueueType.Concurrent) {
            var manager: QCCTaskManager = QCCTaskManager()
            manager.taskFinishedBlock = self.taskFinishedBlock()
            return manager
        } else {
            var manager: QCCTaskManager = QCCTaskManager(forSerialTasks: ())
            manager.taskFinishedBlock = self.taskFinishedBlock()
            manager.taskReceiveOutputDataBlock = {(taskManager: QCCTaskManager, taskIdentefiers : String, lenght : UInt) in
            }
            return manager
        }
    }()
    
    override public func launch() {
        super.launch()
        
        if let objects : [QCCProjectEssence] = self.dataSource.objectsForProcessing(byAction: action, phase: self) {
            for objectEssence in objects {
                processObjectEssence(objectEssence)
            }
        }

        // Launch tasks
        for (taskIdentefier, _) in self.processingObjects {
            if (self.result == .inProgress && self.action.state == .inProgress) {
                self.taskManager.launchTaskWithIdenefier(taskIdentefier)
            }
        }
    }
    
    func processObjectEssence(objectEssence : QCCProjectEssence) -> Void {
        if (objectEssence.root) {
            if let projectGroup : QCCProjectGroup = objectEssence as? QCCProjectGroup {
                processObjectEssence(objectEssence, projectRootFolderPath: projectGroup.projectRootFolderPath())
                
            }
        } else {
            print("\(objectEssence) is not root")
        }
    }
    
    func processObjectEssence(objectEssence : QCCProjectEssence, projectRootFolderPath : String) -> Void {
        if (self.result != .inProgress || self.action.state != .inProgress) {
            return;
        }
        
        if let projectGroup : QCCProjectGroup = objectEssence as? QCCProjectGroup {
            for object in projectGroup.children {
                if let child : QCCProjectEssence = object as? QCCProjectEssence {
                    processObjectEssence(child, projectRootFolderPath: projectRootFolderPath)
                }
            }
            return
        }
        
        guard let toolPath = self.dataSource.toolForProcessing(byAction: action, phase: self, UTTypeString: objectEssence.fileUTTString()) else {
            return
        }
        
        if let toolEvailability : Bool = existedToolList[toolPath] {
            if !toolEvailability {
                terimnatePhase(Error.ToolDoesNotExist)
                return;
            }
        }
        
        if (NSFileManager.defaultManager().fileExistsAtPath(toolPath) && NSFileManager.defaultManager().isExecutableFileAtPath(toolPath)) {
            existedToolList[toolPath] = true
        }else {
            print("Please check:\(toolPath)");
            existedToolList[toolPath] = false
            terimnatePhase(Error.ToolDoesNotExist)
            return;
        }
        
        let fileUTTString : String = objectEssence.fileUTTString()

        var args : [String] = self.dataSource.propertiesForProcessing(byAction: action, phase: self, UTTypeString: fileUTTString)
        let objectArgs : [String] = objectProcessingArgs(forObjectEssence: objectEssence, projectFolderPath: projectRootFolderPath)
        var artefactArgs : [String] = [String]()
        
        let artefactEssence : QCCProjectEssence? = self.dataSource.artefactForProcessing(byAction: action, phase: self, fromObject: objectEssence)

        artefactArgs = artefactProcessingArgs(forProcessingObjectEssence: objectEssence, artefactEssence: artefactEssence)
        

        let shouldReverseArgs = self.dataSource.shouldReverseObjectAndArtefactSection(byAction: action, phase: self, forObject: objectEssence)
        
        if (shouldReverseArgs) {
            args.appendContentsOf(artefactArgs)
            args.appendContentsOf(objectArgs)
        }else {
            args.appendContentsOf(objectArgs)
            args.appendContentsOf(artefactArgs)
        }
        
        if let taskIdentefier : String = taskManager.launch(false, path: toolPath, withArgs:args, fromFolder: self.dataSource.temporaryDirectoryURL(action).path) {
            if result == .inProgress {
                self.processingObjects[taskIdentefier] = objectEssence
            }
            
        } else {
            terimnatePhase(Error.PhaseResultFail)
            return;
        }
    }
    
    func objectProcessingArgs(forObjectEssence objectEssence : QCCProjectEssence, projectFolderPath : String?) -> [String] {
        
        var args : [String] = [String]()
        let fileUTTString : String = objectEssence.fileUTTString()
    
        // Object section
        args.appendContentsOf(self.dataSource.objectPrefixesForProcessing(byAction: action, phase: self, UTTypeString: fileUTTString))
        
        if let projectFolderPath : String = projectFolderPath {
            if let objectPath : String = objectEssence.fileURLWithProjectPath(projectFolderPath).path {
                
                if let objectPathPattern : String = self.dataSource.objectPathPatternForProcessing(byAction: action, phase: self) {
                    if (objectPathPattern.containsString(self.dataSource.patternKey())) {
                    
                        let resultPath = objectPathPattern.stringByReplacingOccurrencesOfString(self.dataSource.patternKey(), withString: objectPath)
                        
                        args.append(resultPath)
                        
                    }else {
                        args.append(objectPath)
                    }
                    
                }else {
                    args.append(objectPath)
                }
            }
        }
        
        args.appendContentsOf(self.dataSource.objectPostfixesForProcessing(byAction: action, phase: self, UTTypeString: fileUTTString))
        
        return args
    }
    
    func artefactProcessingArgs(forProcessingObjectEssence objectEssence : QCCProjectEssence, artefactEssence : QCCProjectEssence?) -> [String] {
        var args : [String] = [String]()
        let fileUTTString : String = objectEssence.fileUTTString()
        
        //Artefact section
        if let artefactEssence : QCCProjectEssence  = artefactEssence {
            args.appendContentsOf(self.dataSource.artefactPrefixesForProcessing(byAction: action, phase: self, UTTypeString: fileUTTString))
            if let artefactPath : String = artefactPath(artefactEssence) {
                args.append(artefactPath)
            }
            args.appendContentsOf(self.dataSource.artefactPostfixesForProcessing(byAction: action, phase: self, UTTypeString: fileUTTString))
        }
        
        return args;
        
    }
    
    func artefactPath(artefactEssence : QCCProjectEssence?) -> String? {
        if let artefactEssence : QCCProjectEssence = artefactEssence {
            if let temporaryDirectoryPath : String = self.dataSource.temporaryDirectoryURL(action).path {
                if let artefactPath : String = artefactEssence.fileURLWithProjectPath(temporaryDirectoryPath).path {
                    return artefactPath
                }
            }
        }
        return nil
    }
    
    func objectProcessingQueueType() -> QCCObjectProcessingQueueType {
        let type : QCCObjectProcessingQueueType = self.dataSource.objectQueueType(forAction: action, phase: self)
        return type
    }
    
    func terimnatePhase(erorr : Error) -> Void {
        result = .Fail
        if let phaseFinished : QCCPhaseFinishedClosureType = self.phaseFinishedClosure {
            phaseFinished(phase: self, error: erorr)
        }
    }
    
    func taskFinishedBlock()->((taskManager: QCCTaskManager, taskIdentefier: String) ->Void) {
        return {(taskManager: QCCTaskManager, taskIdentefier: String) in
            
            var report : [String : String] = [String : String]()
            
            report[QCCActionReportType.LaunchComand.identifier()] = taskManager.launchPathForTaskIdenefier(taskIdentefier)
            
            if let argStrings : [String] = taskManager.argsForTaskIdenefier(taskIdentefier) as? [String] {
                report[QCCActionReportType.LaunchArgs.identifier()] = argStrings.joinWithSeparator(QCCActionReportArgumentsSeparator)
            }
            
            
            
            if let outputData: NSData = taskManager.outputDataForTaskIdenefier(taskIdentefier) {
                if (outputData.length > 0) {
                    if let output : String = NSString(data: outputData, encoding: NSUTF8StringEncoding) as? String {
                        report[QCCActionReportType.Output.identifier()] = output
                    }
                }
            }
            
            if let errorData:NSData = taskManager.errorDataForTaskIdenefier(taskIdentefier) {
                if errorData.length > 0 {
                    self.result = QCCPhaseResult.Fail
                    
                    if let errorOutput : String = NSString(data: errorData, encoding: NSUTF8StringEncoding) as? String {
                        report[QCCActionReportType.Error.identifier()] = errorOutput
                    }
                    
                    if let phaseFinished : QCCPhaseFinishedClosureType = self.phaseFinishedClosure {
                        phaseFinished(phase: self, error: .PhaseResultFail)
                    }
                    
                }
            }
            
            if (self.taskManager.taskIdentefiers().count == self.taskManager.finishedTaskIdentefiers().count) {
                if let phaseFinished : QCCPhaseFinishedClosureType = self.phaseFinishedClosure {
                    phaseFinished(phase: self, error: nil)
                }
            }
            
            if let actionReportClosure : QCCActionReportClosureType = self.action.actionReportClosure {
                actionReportClosure(action: self.action, phase: self, report: report)
            }
            
        }
    }
}
