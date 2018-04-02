//
//  QCCSchema.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych on 2015
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCSchema.h"
#import "QCComplexURL.h"

NSString *const QCCPhaseProcessingToolKey               = @"QCCPhaseProcessingTool";
NSString *const QCCPhaseObjectPathPatternKey            = @"QCCPhaseObjectPathPattern";
NSString *const QCCPhaseObjectNamingPatternKey          = @"QCCPhaseObjectNamingPattern";

NSString *const QCCPhasePatternKey                      = @"$(object)";

NSString *const QCCPhaseArtefactNamingPatternKey        = @"QCCPhaseArtefactNamingPattern";
NSString *const QCCPhaseArtefactObjectPatternKey        = @"$(object)";

NSString *const QCCPhaseArtefactPostfixKey              = @"QCCPhaseArtefactPostfix";
NSString *const QCCPhaseArtefactPrefixKey               = @"QCCPhaseArtefactPrefix";

NSString *const QCCPhaseDescriptionKey                  = @"QCCPhaseDescription";
NSString *const QCCPhaseExtendableByUserKey             = @"QCCPhaseExtendableByUser";
NSString *const QCCPhaseIdentifierKey                   = @"QCCPhaseIdentifier";
NSString *const QCCPhaseObjectPostfixKey                = @"QCCPhaseObjectPostfix";
NSString *const QCCPhaseObjectPrefixKey                 = @"QCCPhaseObjectPrefix";
NSString *const QCCPhaseProcessingArtefactSourceIdentifiersKey = @"QCCPhaseProcessingArtefactSourceIdentifiers";
NSString *const QCCPhaseProcessingObjectKey             = @"QCCPhaseProcessingObject";

NSString *const QCCPhasePropertyKey                     = @"QCCPhaseProperty";
NSString *const QCCPhaseShouldReverseObjectAndArtefactSectionKey    = @"QCCPhaseShouldReverseObjectAndArtefactSection";
NSString *const QCCPhaseShouldUseSharedPropertyKey      = @"QCCPhaseShouldUseSharedProperty";

NSString *const QCCSchemaActionPhaseKey                 = @"QCCSchemaActionPhase";
NSString *const QCCSchemaActionIdentifierKey            = @"QCCSchemaActionIdentifier";

NSString *const QCCSchemaActionAnalyzeKey               = @"QCCSchemaActionAnalyze";
NSString *const QCCSchemaActionClearKey                 = @"QCCSchemaActionClear";
NSString *const QCCSchemaActionCompileKey               = @"QCCSchemaActionCompile";
NSString *const QCCSchemaActionDebugKey                 = @"QCCSchemaActionDebug";
NSString *const QCCSchemaActionEraceKey                 = @"QCCSchemaActionErace";
NSString *const QCCSchemaActionIndexKey                 = @"QCCSchemaActionIndex";
NSString *const QCCSchemaActionRunKey                   = @"QCCSchemaActionRun";
NSString *const QCCSchemaActionsKey                     = @"QCCSchemaActions";
NSString *const QCCSchemaActionUploadKey                = @"QCCSchemaActionUpload";

NSString *const QCCSchemaIdentifierKey                  = @"QCCSchemaIdentifier";
NSString *const QCCSchemaSharedPropertyKey              = @"QCCSchemaSharedProperty";

NSString *const QCCObjectProcessingQueueTypeKey         = @"QCCObjectProcessingQueueType";
NSString *const QCCPhaseProcessingQueueTypeKey          = @"QCCPhaseProcessingQueueType";

NSString *const QCCSchemaAttachedIncludeKey             = @"QCCSchemaAttachedInclude";
NSString *const QCCSchemaAttachedLibraryKey             = @"QCCSchemaAttachedLibrary";
NSString *const QCCSchemaAttachedSourceKey              = @"QCCSchemaAttachedSource";
NSString *const QCCSchemaAttachedCommandKey             = @"QCCSchemaAttachedCommand";


NSString *const QCCPhaseObjectTypePostPhaseArtefactKey  = @"QCCPhaseObjectTypePostPhaseArtefact";
NSString *const QCCPhaseObjectTypeProjectSourceKey      = @"QCCPhaseObjectTypeProjectSource";
NSString *const QCCPhaseObjectTypeAttachedSourceKey     = @"QCCPhaseObjectTypeAttachedSource";
NSString *const QCCPhaseObjectTypeCommandKey            = @"QCCPhaseObjectTypeCommand";


/*
 QCCPhaseObjectType
 QCCPhaseObjectType ProjectSource
 QCCPhaseObjectType AttachedSource
 QCCPhaseObjectType PostPhaseArtefact
 */

@implementation QCCSchema

#pragma mark - Main interface


#pragma mark - Helper
//    NSString *compileToolPath = [self linkForPackageIdentifier:compilePackageIdentifier container:QCCPackageURLToolAnchorKey key:compileKey];

- (NSString *) linkForPackageIdentifier:(NSString *) identifier container:(NSString *) container key:(NSString *) key {

    NSString *linkPath = [NSString stringWithFormat:@"${%@:%@}/${%@:%@}",
                                 QCCPackageURLAnchorKey,
                                 identifier,
                                 container,
                                 key];
    return linkPath;
}

#pragma mark - Action section
- (nonnull NSDictionary<NSString *, NSDictionary *> *) availableActions {
    return [self valueForSchemaKey:QCCSchemaActionsKey];
}

- (nonnull NSArray <NSString *> *) availableActionKeys {
    return [[self availableActions] allKeys];
}

- (nullable NSDictionary<NSString *, id> *) actionDictionaryForKey:(nonnull NSString *) key {
    return [self availableActions][key];
}

- (nullable NSString *) actionIdentifierForActionKey:(nonnull NSString *) actionKey {
    NSDictionary *dictionary = [self actionDictionaryForKey:actionKey];
    return dictionary[QCCSchemaActionIdentifierKey];
}

- (nonnull NSDictionary <NSString *, NSArray <NSString *> *> *) phaseIdentefiersForActionKey {
    
    static NSMutableDictionary *actions;
    static dispatch_once_t phaseIdentefiersForActionKeyOnceToken;
    dispatch_once(&phaseIdentefiersForActionKeyOnceToken, ^{
        actions = [NSMutableDictionary new];
        
        for (NSString *actionKey in [self availableActionKeys]) {
            
            NSMutableArray *phaseIdentifiers = [NSMutableArray new];
            for (NSDictionary *rawPhase in [self phaseListForActionKey:actionKey]) {
                NSString *phaseIdentifier = [self phaseIdentifierForPhase:rawPhase];
                if (phaseIdentifier)
                    [phaseIdentifiers addObject:phaseIdentifier];
            }
            actions[actionKey] = phaseIdentifiers;
        }
    });
    
    return actions;

};

#pragma mark - Phase section
- (nullable NSArray <NSDictionary *> *) phaseListForActionKey:(nonnull NSString *) actionKey {
    NSDictionary *dictionary = [self actionDictionaryForKey:actionKey];
    return dictionary[QCCSchemaActionPhaseKey];
}

- (nullable NSArray <NSDictionary *> *) phaseListForActionIdentifier:(nonnull NSString *) actionIdentifier {
    
    for (NSString *actionKey in [self availableActionKeys]) {
        NSDictionary *action = [self availableActions][actionKey];
        if ([action[QCCSchemaActionIdentifierKey] isEqualToString:actionIdentifier]) {
            return [self phaseListForActionKey:actionKey];
        }
    }
    return nil;
}


- (nullable NSString *) phaseProcessingQueueTypeForActionKey:(nonnull NSString *) actionKey {
    NSDictionary *dictionary =  [self actionDictionaryForKey:actionKey];
    return dictionary[QCCPhaseProcessingQueueTypeKey];
}

- (nullable NSDictionary<NSString *, id> *) phaseForActionIdentifier:(nonnull NSString *) actionIdentifier forIndex:(NSInteger) index {
    NSArray *phaseList = [self phaseListForActionIdentifier:actionIdentifier];
    if ([phaseList count] <= index)
        return nil;
    
    return [phaseList objectAtIndex:index];
}

- (nullable NSDictionary<NSString *, id> *) phaseForActionIdentifier:(nonnull NSString *) actionIdentifier forIdentifier:(nonnull NSString *) phaseIdentifier {

    NSArray *phaseList = [self phaseListForActionIdentifier:actionIdentifier];

    for (NSDictionary * phase in phaseList) {
        if ([phase[QCCPhaseIdentifierKey] isEqualToString:phaseIdentifier]){
            return phase;
        }
    }
    
    return nil;
}

- (nullable NSString *) phaseIdentifierForPhase:(nonnull NSDictionary<NSString *, id> *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseIdentifierKey];
    }
    return nil;
}



// Queue for object processing in phase
- (nullable NSString *) objectProcessingQueueTypeForPhase:(nonnull NSDictionary<NSString *, id> *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
       return phase[QCCObjectProcessingQueueTypeKey];
    }
    return nil;
}

// List of object types [QCCPhaseObjectTypePostPhaseArtefact; QCCPhaseObjectTypeProjectSource; QCCPhaseObjectTypeAttachedSource; QCCPhaseObjectTypeCommand]
- (nullable NSArray <NSString *> *) phaseObjectTypeForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseProcessingObjectKey];
    }
    return nil;
}

// Phase identifier where processor should get list of artefact to process as object
- (nullable NSArray <NSString *> *) objectProducingPhaseIdentifiersForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseProcessingArtefactSourceIdentifiersKey];
    }
    return nil;
}

- (nullable NSArray <NSString *> *) attachedSourceListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCSchemaAttachedSourceKey];
    }
    return nil;
}

- (nullable NSArray <NSString *> *) attachedCommandListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCSchemaAttachedCommandKey];
    }
    return nil;
}


- (nullable NSDictionary<NSString *, NSString *> *) processingToolsForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseProcessingToolKey];
    }
    return nil;
}

- (nullable NSString *) phaseDescriptionForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseDescriptionKey];
    }
    return nil;
}

- (BOOL) isExtendablePhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return [phase[QCCPhaseExtendableByUserKey] boolValue];
    }
    
    return NO;
}

- (BOOL) shouldUseSharedPropertyForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return [phase[QCCPhaseShouldUseSharedPropertyKey] boolValue];
    }
    
    return NO;
}

- (BOOL) shouldReverseObjectAndArtefactSectionForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return [phase[QCCPhaseShouldReverseObjectAndArtefactSectionKey] boolValue];
    }
    
    return NO;
}

- (nullable NSString *) artefactNamingPatternForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseArtefactNamingPatternKey];
    }
    
    return nil;
}

- (nullable NSString *) objectPathPatternForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseObjectPathPatternKey];
    }
    return nil;
}

- (nullable NSArray <NSDictionary *> *) propertyListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhasePropertyKey];
    }
    
    return nil;
}

- (nullable NSArray <NSDictionary *> *) objectPrefixPropertyListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseObjectPostfixKey];
    }
    
    return nil;
}

- (nullable NSArray <NSDictionary *> *) objectPostfixPropertyListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseObjectPostfixKey];
    }
    
    return nil;
}

- (nullable NSArray <NSDictionary *> *) artefactPrefixPropertyListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseArtefactPrefixKey];
    }
    
    return nil;
}

- (nullable NSArray <NSDictionary *> *) artefactPostfixPropertyListForPhase:(nonnull NSDictionary *) phase {
    if ([phase isKindOfClass:[NSDictionary class]]) {
        return phase[QCCPhaseArtefactPostfixKey];
    }
    
    return nil;
}

- (nullable NSArray <NSDictionary *> *) sharedPropertyList {
    return [self valueForSchemaKey:QCCSchemaSharedPropertyKey];
}

- (nullable NSArray <NSString *> *) attachedInclude {
    return [self valueForSchemaKey:QCCSchemaAttachedIncludeKey];
}

- (nullable NSArray <NSString *> *) attachedLibrary {
    return [self valueForSchemaKey:QCCSchemaAttachedLibraryKey];
}

- (nullable NSArray <NSString *> *) attachedSource {
    return [self valueForSchemaKey:QCCSchemaAttachedSourceKey];
}

- (NSInteger) numberOfPhaseForActionKey:(nonnull NSString *) key {
    return [[self phaseListForActionKey:key] count];
}

#pragma mark - Dependency

- (NSSet<NSString *> *)dependencyPackageIdentifierSet {
    
    static NSMutableSet *packagesIdentefiers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        packagesIdentefiers = [NSMutableSet new];
        
        // Shared Property
        [packagesIdentefiers addObjectsFromArray:[self packageIdentefiersFromPropertyList:[self sharedPropertyList]]];
        
        for (NSString *actionKey in [self availableActionKeys]) {
            
            NSArray *rawPhaseList = [self phaseListForActionKey:actionKey];
            
            for (NSDictionary *rawPhase in rawPhaseList) {
                [packagesIdentefiers addObjectsFromArray:[self packageIdentefiersFromPropertyList:[self propertyListForPhase:rawPhase]]];
                
                // Tools
                for (NSString *toolPath in [[self processingToolsForPhase:rawPhase] allValues]) {
                    QCComplexURL *packageURL = [[QCComplexURL alloc] initWithString:toolPath packageManager:^QCCPackage * _Nullable(NSString * _Nonnull identifier) {
                        return nil;
                    }];
                    if (packageURL.packageIdentifier)
                        [packagesIdentefiers addObject:packageURL.packageIdentifier];
                }
            }
        }
    });
    
    return packagesIdentefiers;
}


- (NSArray *) packageIdentefiersFromPropertyList:(NSArray <NSDictionary <NSString *, id> *> *) propertyList {
    NSMutableArray *packagesIdentefiers = [NSMutableArray new];
    for (NSDictionary *rawProperty in propertyList) {
        
        if ([rawProperty[@"QCCBaseConfigurationElementType"] isEqualToString:@"QCConfigurationProperty"] /* && [rawProperty[@"QCConfigurationPropertyIsComplicatedValue"] boolValue] */) {
            NSString *value = rawProperty[@"QCConfigurationPropertyValue"];
            QCComplexURL *packageURL = [[QCComplexURL alloc] initWithString:value packageManager:^QCCPackage * _Nullable(NSString * _Nonnull identifier) {
                return nil;
            }];
            if (packageURL.packageIdentifier)
                [packagesIdentefiers addObject:packageURL.packageIdentifier];
        }
    }
    return packagesIdentefiers;
}


@end
