//
//  QCCProjectProcessor.swift
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import ActionKit
import QCCProjectEssenceKit
import QCCTargetManagerKit
import QCCDeploymentConfigurationKit

/**
 public typealias QCCActionProgressClosureType = (action: ActionKit.BaseAction, progress: NSProgress, error: NSError?) -> (Void)
 public typealias QCCActionReportClosureType = (action: ActionKit.BaseAction, phase: ActionKit.BasePhase, report: [String : String]) -> (Void)
 */

extension QCCProjectProcessor {
    
    func deploymentConfiguration() -> QCCDeploymentConfiguration {
        let projectDocument : QCCProjectDocument = self.projectDocument()
        return projectDocument.deploymentConfiguration()
    }
    
    func stopAction() -> Void {
        actionList.enumerateKeysAndObjectsUsingBlock { (key: AnyObject, object: AnyObject, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let action : QCCAction = object as? QCCAction {
                if (action.state == QCCActionState.Initialized || action.state == QCCActionState.inProgress) {
                    action.cancel()
                }
            }
        }
    }
    
    func isWorkingAction(withType type: ActionKit.QCCActionType) -> Bool {
        
        var found : Bool = false
        
        actionList.enumerateKeysAndObjectsUsingBlock { (key: AnyObject, object: AnyObject, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
//            if let runtimeIdentifier : String = key as? String {
                if let action : QCCAction = object as? QCCAction {
                    if (action.type == type && (action.state == QCCActionState.Initialized || action.state == QCCActionState.inProgress)) {
                        found = true
                        stop.initialize(true)
                    }
                }
//            }
        }
        return found
    }
    
    // Needs to add Action queue type processing
    // To provide posibility to work concurrently
    func doAction(identifier: String, type: ActionKit.QCCActionType) -> Bool {
        
        if isWorkingAction(withType: type) {
            return false
        }
        
        let action : QCCAction = QCCAction(identifier: identifier, type: type, dataSource: self)
        action.actionProgressClosure = self.actionProgressClosure()
        action.actionReportClosure = self.actionReportClosure()
        
        actionList.setValue(action, forKey: action.runtimeIdentifier)
        action.start()
        
        return true
    }
    

    
    func unwrapRawValue(forPropertyList list : [[String : AnyObject]]) -> [QCConfigurationProperty] {
        
        var result : [QCConfigurationProperty] = [QCConfigurationProperty]()
        
        for rawProperty : [String : AnyObject] in list {
            
            if let baseConfigurationElementType : String = rawProperty[QCCBaseConfigurationElementTypeKey] as? String {
                if baseConfigurationElementType == QCConfigurationPropertyKey {
                    if let configurationProperty : QCConfigurationProperty = QCCDeploymentConfiguration.elementFromDictionary(rawProperty) as? QCConfigurationProperty {
                        if (configurationProperty.isComplicatedValue){
                            let unwraperValue = unwrapPath(configurationProperty.value)
                            configurationProperty.updateValue(unwraperValue)
                        }
                        
                        result.append(configurationProperty)
                    }
                }
            }
        }
        
        return result;
    }
    
    
    func unwrapPath(string : String) -> String {
        // Try to resolve package URL
        
        let packageURL : QCComplexURL? = QCComplexURL(string: string, packageManager: { (identifier : String) -> QCCPackage? in
            return self.documentController.applicationTargetManager.packages()[identifier]
            
        }) { (environmentKey : String) -> String? in
            return self.environmentString(forKey: environmentKey)
        }
        
        if let urlPath = packageURL {
            return urlPath.fullPath()
        }
        
        // If it is not Package URL return origin string
        return string
    }
    
    func actionKey(type: ActionKit.QCCActionType) -> String {
        
        switch (type) {
            
        case .Clear:
            return QCCSchemaActionClearKey
            
        case .Index:
            return QCCSchemaActionIndexKey
            
        case .Analyze:
            return QCCSchemaActionAnalyzeKey
            
        case .Compile:
            return QCCSchemaActionCompileKey
            
        case .Upload:
            return QCCSchemaActionUploadKey
            
        case .Run:
            return QCCSchemaActionRunKey
            
        case .Debug:
            return QCCSchemaActionDebugKey
            
        case .Erase:
            return QCCSchemaActionEraceKey
            
        }
    }

    // We should move that to ActionKit
    func phaseProcessingQueueType(string : String?) -> QCCPhaseProcessingQueueType {
        if string == "Concurrent" {
            return QCCPhaseProcessingQueueType.Concurrent
        }
        return QCCPhaseProcessingQueueType.Serial
    }
    
    func objectProcessingQueueType(string : String?) -> QCCObjectProcessingQueueType {
        if string == "Concurrent" {
            return QCCObjectProcessingQueueType.Concurrent
        }
        return QCCObjectProcessingQueueType.Serial
    }
    
    func phaseObjectTypeMask(values: [String]?) -> QCCPhaseObjectTypeMask {
        var mask : QCCPhaseObjectTypeMask = []
        if let array : [String] = values {
            for value : String in array {
                switch(value) {
                case QCCPhaseObjectTypePostPhaseArtefactKey:
                    mask = mask.union(QCCPhaseObjectTypeMask.PostPhaseArtefact)
                case QCCPhaseObjectTypeProjectSourceKey:
                    mask = mask.union(QCCPhaseObjectTypeMask.ProjectSource)
                case QCCPhaseObjectTypeAttachedSourceKey:
                    mask = mask.union(QCCPhaseObjectTypeMask.AttachedSource)
                case QCCPhaseObjectTypeCommandKey:
                    mask = mask.union(QCCPhaseObjectTypeMask.Command)
                default : break
                }
            }
        }
        
        return mask
    }
    
    /*
     
     _temeroryDirectoryGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey:[[self buildTemporaryFolderURL] lastPathComponent], QCCProjectSourceRootFileKey : @(YES)}
     identifier:nil
     projectURL:[[self buildTemporaryFolderURL] URLByDeletingLastPathComponent]];
     
     */
    
    
    
    func processAttachedSource(path : String) -> QCCProjectGroup? {
        let packageURL : QCComplexURL? = QCComplexURL(string: path) { (identifier : String) -> QCCPackage? in
            return self.documentController.applicationTargetManager.packages()[identifier]
        }
        
        if let urlPath = packageURL {
            return QCCProjectProcessor.sourceForPathString(urlPath.fullPath())
        }else {
            return QCCProjectProcessor.sourceForPathString(path)
        }
    }
}

extension QCCProjectProcessor: QCCActionDataSource {
    
    //MARK: Helper
    func rawPhase(actionIdentifier: String, phaseIdentifier: String) -> [String : AnyObject]? {
    
        let schema : QCCSchema = self.deploymentSchema()
        if let phase : [String : AnyObject] = schema.phaseForActionIdentifier(actionIdentifier, forIdentifier: phaseIdentifier) {
            return phase
        }
        
        return nil
    }

    func rawPhase(actionIdentifier: String, phaseIndex: Int) -> [String : AnyObject]? {
        
        let schema : QCCSchema = self.deploymentSchema()
        if let phase : [String : AnyObject] = schema.phaseForActionIdentifier(actionIdentifier, forIndex: phaseIndex) {
            return phase
        }
        
        return nil
    }
    
    //MARK: Tmporary folder
    public func temporaryDirectoryURL(action: BaseAction) -> NSURL {
        return self.buildTemporaryFolderURL()
    }
    //MARK: QCCActionDataSource
    public func numberOfPhaseInAction(action: BaseAction) -> Int {
        return self.deploymentSchema().numberOfPhaseForActionKey(actionKey(action.type))
    }
    
    public func phaseIdentifier(forAction action: BaseAction, atIndex index: Int) -> String? {
        if let phase : [String : AnyObject] = self.deploymentSchema().phaseForActionIdentifier(action.identifier, forIndex: index) {
            return self.deploymentSchema().phaseIdentifierForPhase(phase)
        }
        return nil
    }
    
    public func phaseQueueType(forAction action: BaseAction, atIndex index: Int) -> QCCPhaseProcessingQueueType {
        return phaseProcessingQueueType(self.deploymentSchema().phaseProcessingQueueTypeForActionKey(actionKey(action.type)))
    }
    
    public func objectQueueType(forAction action: BaseAction, phase: BasePhase) -> QCCObjectProcessingQueueType {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            return objectProcessingQueueType(self.deploymentSchema().objectProcessingQueueTypeForPhase(raw))
        }
        return QCCObjectProcessingQueueType.Serial
    }
    //MARK: Object and artefact around section
    public func shouldReverseObjectAndArtefactSection(byAction action: BaseAction, phase: BasePhase, forObject object: QCCProjectEssence) -> Bool {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            return self.deploymentSchema().shouldReverseObjectAndArtefactSectionForPhase(raw)
        }
        return false
    }
    
    public func phaseObjectTypeMask(ForAction action: BaseAction, phase: BasePhase) -> QCCPhaseObjectTypeMask {
        
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            return phaseObjectTypeMask(self.deploymentSchema().phaseObjectTypeForPhase(raw))
        }
        
        return QCCPhaseObjectTypeMask.None
    }
    
    public func patternKey() -> String {
        return QCCPhasePatternKey
    }
    
    public func objectPathPatternForProcessing(byAction action: BaseAction, phase: BasePhase) -> String? {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            return self.deploymentSchema().objectPathPatternForPhase(raw)
        }
        return nil
    }
    
    public func objectNamingPatternForProcessing(byAction action: BaseAction, phase: BasePhase) -> String? {
        return nil
    }

    
    //[QCCPhaseObjectTypePostPhaseArtefact; QCCPhaseObjectTypeProjectSource; QCCPhaseObjectTypeAttachedSource]
    
    public func objectsForProcessing(actionIdentifier: String, phaseIdentifier: String) -> [QCCProjectEssence]? {
        var essences : [QCCProjectEssence] = [QCCProjectEssence]()
        
        if let raw : [String : AnyObject] = rawPhase(actionIdentifier, phaseIdentifier: phaseIdentifier) {
            if let phaseObjectTypes: [String] = self.deploymentSchema().phaseObjectTypeForPhase(raw) {
                for value in phaseObjectTypes {
                    switch value {
                    case QCCPhaseObjectTypeProjectSourceKey:
                        essences.appendContentsOf(self.projectDocument().sourceTreeContentArray())
                        
                    case QCCPhaseObjectTypePostPhaseArtefactKey:
                        if let phaseProducerIdentifiers : [String] = self.deploymentSchema().objectProducingPhaseIdentifiersForPhase(raw) {
                            essences.appendContentsOf(unwrapArtefact(phaseProducerIdentifiers))
                        }
                        break
                        
                    case QCCPhaseObjectTypeAttachedSourceKey:
                        if let attachedSourcePathList : [String] = self.deploymentSchema().attachedSourceListForPhase(raw) {
                            for path in attachedSourcePathList {
                                if let group : QCCProjectGroup = processAttachedSource(path) {
                                    essences.append(group)
                                }
                            }
                        }
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
        return essences
    }
    
    func unwrapArtefact(phaseProducerIdentifiers: [String]) -> [QCCProjectEssence] {
        let group = temeroryGroup()
        
        // To list all phase identifiers to get all artefacts.
        for phaseProducersIdentifier : String in phaseProducerIdentifiers {
            
            let identifier : String? = {
            
            for (key, phaseIdentifiers) in deploymentSchema().phaseIdentefiersForActionKey() {
                if phaseIdentifiers.contains(phaseProducersIdentifier) {
                    if let identifier = deploymentSchema().actionIdentifierForActionKey(key) {
                        return identifier
                    }
                }
            }
                
                return nil
            }()
            
            guard let actionIdentifier : String = identifier else {
                return [QCCProjectEssence]()
            }
            
            // get all root objects in that phase ware processed.
            if let phaseProducingRootObjects : [QCCProjectEssence] = objectsForProcessing(actionIdentifier, phaseIdentifier: phaseProducersIdentifier) {
                
                // to list root procesed objects.
                for  phaseProducingObject : QCCProjectEssence in phaseProducingRootObjects {
                    
                    // get all children objects were procssed.
                    
                    var children : [AnyObject] = [AnyObject]()
                    // Take only first item is phase produce the same artefact for all sources
                    if (isSingleObjectProducedBy(actionIdentifier, phaseIdentifier: phaseProducersIdentifier)) {
                        if let child = phaseProducingObject.allChildren().first {
                            children.append(child)
                        }
                    }else {
                        children.appendContentsOf(phaseProducingObject.allChildren())
                    }
                    
                    for phaseProducingObject in  children {
                        
                        // cast to QCCProjectEssence.
                        if let phaseProducingEssence : QCCProjectFile = phaseProducingObject as? QCCProjectFile {
                            // If tool is availbale, lets process
                            if let _ : String = toolForProcessing(actionIdentifier, phaseIdentifier: phaseProducersIdentifier, UTTypeString:  phaseProducingEssence.fileUTTString()) {
                                // get artefacts for procesed essence objects befoer.
                                if let phaseProducingArtefact = artefactForProcessing(actionIdentifier, phaseIdentifier: phaseProducersIdentifier, fromObject: phaseProducingEssence) {
                                    phaseProducingArtefact.parent = group
                                }
                            }
                        }
                    }
                }
            }
        }
    
        return [group]
    
    }
    
    public func objectsForProcessing(byAction action: BaseAction, phase: BasePhase) -> [QCCProjectEssence]? {
        return objectsForProcessing(action.identifier, phaseIdentifier: phase.identifier)
    }

    public func objectProducingPhaseIdentifiers(forAction action: BaseAction, phase: BasePhase, processingQueueType: QCCObjectProcessingQueueType) -> [String]? {
        
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            return self.deploymentSchema().objectProducingPhaseIdentifiersForPhase(raw)
        }
        return nil
    }
    
    public func artefactForProcessing(actionIdentifier : String, phaseIdentifier: String, fromObject object: QCCProjectEssence) -> QCCProjectEssence? {
        var artefactName : String?
        if let raw : [String : AnyObject] = rawPhase(actionIdentifier, phaseIdentifier: phaseIdentifier) {
            if let pattern = self.deploymentSchema().artefactNamingPatternForPhase(raw) {
                artefactName = pattern.stringByReplacingOccurrencesOfString(QCCPhaseArtefactObjectPatternKey, withString: object.path)
            }
        }
        
        // Do not provide artefact item if we don't have any pattern
        if artefactName == nil {
            return nil
        }
        
        let dictionary : NSMutableDictionary = NSMutableDictionary()
        dictionary.setValue(artefactName, forKey: QCCProjectSourcePathKey)
        let file : QCCProjectFile = QCCProjectFile.init(dictionary: dictionary as [NSObject : AnyObject], identifier: nil)
        file.parent = self.temeroryDirectoryGroup()
        return file
    }
    
    func isSingleObjectProducedBy(actionIdentifier : String, phaseIdentifier: String) -> Bool {
        if let raw : [String : AnyObject] = rawPhase(actionIdentifier, phaseIdentifier: phaseIdentifier) {
            // if phase contains some pattern -> leads to many produced objects
            if let pattern = self.deploymentSchema().artefactNamingPatternForPhase(raw) {
                return !pattern.containsString(QCCPhaseArtefactObjectPatternKey)
            }
        }
        
        return true
    }
    
    public func artefactForProcessing(byAction action: BaseAction, phase: BasePhase, fromObject object: QCCProjectEssence) -> QCCProjectEssence? {
        return artefactForProcessing(action.identifier, phaseIdentifier: phase.identifier, fromObject: object)
    }

    //MARK: Tool
    //TODO: Check if tool exist
    public func toolForProcessing(actionIdentifier : String, phaseIdentifier: String, UTTypeString: String) -> String? {
        
        if let raw : [String : AnyObject] = rawPhase(actionIdentifier, phaseIdentifier: phaseIdentifier) {
            if let dictionary : [String : String] = self.deploymentSchema().processingToolsForPhase(raw) {
                let keys : [String] = Array(dictionary.keys)
                if let nearestParentUTType = keys.orderedContainsUTI(UTTypeString).last {
                    if let rawPath = dictionary[nearestParentUTType] {
                        return unwrapPath(rawPath)
                    }
                }
            }
        }
        
        return nil
    }

    public func toolForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> String? {
        return toolForProcessing(action.identifier, phaseIdentifier: phase.identifier, UTTypeString: UTTypeString)
    }
        //MARK: main property section
    public func propertiesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> [String] {
        
        return propertiesForProcessing(byActionIdentifier: action.identifier,
                                       actionType: action.type,
                                       phaseIdentifier: phase.identifier,
                                       UTTypeString: UTTypeString)
    }
    
    public func propertiesForProcessing(byActionIdentifier actionIdentifier: String, actionType : QCCActionType, phaseIdentifier: String, UTTypeString: String) -> [String] {
        if let raw : [String : AnyObject] = rawPhase(actionIdentifier, phaseIdentifier: phaseIdentifier) {
            var rawProperties: [[String : AnyObject]] = [[String : AnyObject]]()
            
            
            var properties : [QCConfigurationProperty] = [QCConfigurationProperty]()
            
            //Should we extend with shared property
            
            if (self.deploymentSchema().shouldUseSharedPropertyForPhase(raw)) {
                if let sharedProperty = self.deploymentSchema().sharedPropertyList() {
                    
                    properties.appendContentsOf(unwrapRawValue(forPropertyList: sharedProperty).filter({ (property: QCConfigurationProperty) -> Bool in
                        
                        let rightUTType : Bool = (UTTypeString.conformsUTI(property.UTIString))
                        let rightAction : Bool = property.actionKeys.contains(actionType.identifier())
                        
                        return (rightUTType && rightAction)
                    }))
                }
            }
            
            
            if let rawPropertyList = self.deploymentSchema().propertyListForPhase(raw) {
                rawProperties.appendContentsOf(rawPropertyList)
            }
            
            
            for rawProperty in rawProperties {
                if let propertyUTTypeString : String = rawProperty[QCCBuildConfigurationUTIStringKey] as? String {
                    if UTTypeString.conformsUTI(propertyUTTypeString) {
                        let element : QCCBaseConfigurationElement? = QCCDeploymentConfiguration.elementFromDictionary(rawProperty)
                        if let property : QCConfigurationProperty = element as? QCConfigurationProperty {
                            if property.isComplicatedValue {
                                let unwraperValue = unwrapPath(property.value)
                                property.updateValue(unwraperValue)
                            }
                            
                            properties.append(property)
                        }
                    }
                }
            }
            
            properties.appendContentsOf(defaultPropertyList())
            
            if (self.deploymentSchema().isExtendablePhase(raw)) {
                
                for projectProperty : QCConfigurationProperty in self.deploymentPropertyList()  {
                    if UTTypeString.conformsUTI(projectProperty.UTIString) {
                        properties.append(projectProperty)
                    }
                }
            }
            return self.deploymentConfiguration().blandProperty(properties).removeDuplicates()
        }
        return [String]()
    }
    

    
    //MARK: Object property section
    public func objectPrefixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> [String] {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            if let rawPropertyList = self.deploymentSchema().objectPrefixPropertyListForPhase(raw) {
                return self.deploymentConfiguration().blandPropertyWithRaw(rawPropertyList)
            }
        }
        return [String]()
    }
    
    public func objectPostfixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> [String]{
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            if let rawPropertyList = self.deploymentSchema().objectPostfixPropertyListForPhase(raw) {
                var properties : [QCConfigurationProperty] = [QCConfigurationProperty]()
                properties.appendContentsOf(defaultPropertyList())
                
                for rawProperty : [String : AnyObject] in rawPropertyList {
                    let element : QCCBaseConfigurationElement? = QCCDeploymentConfiguration.elementFromDictionary(rawProperty)
                    if let property : QCConfigurationProperty = element as? QCConfigurationProperty {
                        let rightUTType : Bool = (UTTypeString.conformsUTI(property.UTIString))
                        let rightAction : Bool = property.actionKeys.contains(action.type.identifier())
                        
                        if  (rightUTType && rightAction) {
                            if property.isComplicatedValue {
                                let unwraperValue = unwrapPath(property.value)
                                property.updateValue(unwraperValue)
                            }
                            
                            properties.append(property)
                        }
                    }
                }
                
                return self.deploymentConfiguration().blandProperty(properties).removeDuplicates()
            }
        }
        return [String]()
    }
    
    //MARK: Arfefact property section
    public func artefactPrefixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> [String] {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            // raw phase
            if let rawPropertyList = self.deploymentSchema().artefactPrefixPropertyListForPhase(raw) {
                
                var properties : [QCConfigurationProperty] = [QCConfigurationProperty]()
                properties.appendContentsOf(defaultPropertyList())

                for rawProperty : [String : AnyObject] in rawPropertyList {
                    let element : QCCBaseConfigurationElement? = QCCDeploymentConfiguration.elementFromDictionary(rawProperty)
                    if let property : QCConfigurationProperty = element as? QCConfigurationProperty {
                        let rightUTType : Bool = (UTTypeString.conformsUTI(property.UTIString))
                        let rightAction : Bool = property.actionKeys.contains(action.type.identifier())
                        
                        if  (rightUTType && rightAction) {
                            properties.append(property)
                        }
                    }
                }
                return self.deploymentConfiguration().blandProperty(properties).removeDuplicates()
            }
        }
        return [String]()
    }
    
    public func artefactPostfixesForProcessing(byAction action: BaseAction, phase: BasePhase, UTTypeString: String) -> [String] {
        if let raw : [String : AnyObject] = rawPhase(action.identifier, phaseIdentifier: phase.identifier) {
            // raw phase
            if let rawPropertyList = self.deploymentSchema().artefactPostfixPropertyListForPhase(raw) {
                var properties : [QCConfigurationProperty] = [QCConfigurationProperty]()
                properties.appendContentsOf(defaultPropertyList())
                
                for rawProperty : [String : AnyObject] in rawPropertyList {
                    let element : QCCBaseConfigurationElement? = QCCDeploymentConfiguration.elementFromDictionary(rawProperty)
                    if let property : QCConfigurationProperty = element as? QCConfigurationProperty {
                        let rightUTType : Bool = (UTTypeString.conformsUTI(property.UTIString))
                        let rightAction : Bool = property.actionKeys.contains(action.type.identifier())
                        
                        if  (rightUTType && rightAction) {
                            properties.append(property)
                        }
                    }
                }
                return self.deploymentConfiguration().blandProperty(properties).removeDuplicates()
            }
        }
        return [String]()
    }
    

    
}
