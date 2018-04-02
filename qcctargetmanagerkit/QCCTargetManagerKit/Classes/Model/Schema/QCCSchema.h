//
//  QCCSchema.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych on 2015
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <QCCTargetManagerKit/QCCTargetManagerKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const QCCPhaseObjectPathPatternKey;
extern NSString *const QCCPhaseObjectNamingPatternKey;
extern NSString *const QCCPhasePatternKey;

extern NSString *const QCCPhaseArtefactNamingPatternKey;
extern NSString *const QCCPhaseArtefactObjectPatternKey;

extern NSString *const QCCPhaseArtefactPostfixKey;
extern NSString *const QCCPhaseArtefactPrefixKey;

extern NSString *const QCCPhaseDescriptionKey;
extern NSString *const QCCPhaseExtendableByUserKey;
extern NSString *const QCCPhaseIdentifierKey;
extern NSString *const QCCPhaseObjectPostfixKey;
extern NSString *const QCCPhaseObjectPrefixKey;
extern NSString *const QCCPhaseProcessingArtefactSourceIdentifiersKey;
extern NSString *const QCCPhaseProcessingObjectKey;
extern NSString *const QCCPhaseProcessingObjectSourceKey;
extern NSString *const QCCPhasePropertyKey;
extern NSString *const QCCPhaseShouldReverseObjectAndArtefactSectionKey;
extern NSString *const QCCPhaseShouldUseSharedPropertyKey;

extern NSString *const QCCSchemaActionPhase;
extern NSString *const QCCSchemaActionIdentifier;

extern NSString *const QCCSchemaActionAnalyzeKey;
extern NSString *const QCCSchemaActionClearKey;
extern NSString *const QCCSchemaActionCompileKey;
extern NSString *const QCCSchemaActionDebugKey;
extern NSString *const QCCSchemaActionEraceKey;
extern NSString *const QCCSchemaActionIndexKey;
extern NSString *const QCCSchemaActionRunKey;
extern NSString *const QCCSchemaActionsKey;
extern NSString *const QCCSchemaActionUploadKey;

extern NSString *const QCCSchemaIdentifierKey;

extern NSString *const QCCSchemaSharedPropertyKey;

//extern NSString *const QCCObjectProcessingQueueType;
//extern NSString *const QCCPhaseProcessingQueueType;

extern NSString *const QCCSchemaAttachedIncludeKey;
extern NSString *const QCCSchemaAttachedLibraryKey;
extern NSString *const QCCSchemaAttachedSourceKey;
extern NSString *const QCCSchemaAttachedCommandKey;

extern NSString *const QCCPhaseObjectTypePostPhaseArtefactKey;
extern NSString *const QCCPhaseObjectTypeProjectSourceKey;
extern NSString *const QCCPhaseObjectTypeAttachedSourceKey;
extern NSString *const QCCPhaseObjectTypeCommandKey;

NS_ASSUME_NONNULL_END

@interface QCCSchema : QCCBaseSchema

@property (nonnull, nonatomic, readonly) NSSet<NSString *>   *dependencyPackageIdentifierSet;

- (nonnull NSDictionary<NSString *, NSDictionary *> *) availableActions;
- (nonnull NSArray <NSString *> *) availableActionKeys;
- (nullable NSDictionary<NSString *, id> *) actionDictionaryForKey:(nonnull NSString *) key;
- (nullable NSString *) actionIdentifierForActionKey:(nonnull NSString *) actionKey;
- (nonnull NSDictionary <NSString *, NSArray <NSString *> *> *) phaseIdentefiersForActionKey;
- (nullable NSArray <NSDictionary *> *) phaseListForActionKey:(nonnull NSString *) actionKey;
- (nullable NSArray <NSDictionary *> *) phaseListForActionIdentifier:(nonnull NSString *) actionIdentifier;

- (nullable NSString *) phaseProcessingQueueTypeForActionKey:(nonnull NSString *) actionKey;

- (nullable NSDictionary<NSString *, id> *) phaseForActionIdentifier:(nonnull NSString *) actionIdentifier forIndex:(NSInteger) index;
- (nullable NSDictionary<NSString *, id> *) phaseForActionIdentifier:(nonnull NSString *) actionIdentifier forIdentifier:(nonnull NSString *) phaseIdentifier;

- (nullable NSString *) phaseIdentifierForPhase:(nonnull NSDictionary<NSString *, id> *) phase;

- (nullable NSString *) objectProcessingQueueTypeForPhase:(nonnull NSDictionary<NSString *, id> *) phase;
- (nullable NSArray <NSString *> *) phaseObjectTypeForPhase:(nonnull NSDictionary *) phase;

/* It could be String path or QCCPackageURL path */
- (nullable NSArray <NSString *> *) attachedSourceListForPhase:(nonnull NSDictionary *) phase;

- (nullable NSArray <NSString *> *) attachedCommandListForPhase:(nonnull NSDictionary *) phase;

- (nullable NSArray <NSString *> *) objectProducingPhaseIdentifiersForPhase:(nonnull NSDictionary *) phase;
- (nullable NSDictionary<NSString *, NSString *> *) processingToolsForPhase:(nonnull NSDictionary *) phase;
- (nullable NSString *) phaseDescriptionForPhase:(nonnull NSDictionary *) phase;
- (BOOL) isExtendablePhase:(nonnull NSDictionary *) phase;
- (BOOL) shouldUseSharedPropertyForPhase:(nonnull NSDictionary *) phase;
- (BOOL) shouldReverseObjectAndArtefactSectionForPhase:(nonnull NSDictionary *) phase;

- (nullable NSString *) artefactNamingPatternForPhase:(nonnull NSDictionary *) phase;
- (nullable NSString *) objectPathPatternForPhase:(nonnull NSDictionary *) phase;

- (nullable NSArray <NSDictionary <NSString *, id> *> *) propertyListForPhase:(nonnull NSDictionary *) phase;
- (nullable NSArray <NSDictionary <NSString *, id> *> *) objectPrefixPropertyListForPhase:(nonnull NSDictionary *) phase;
- (nullable NSArray <NSDictionary <NSString *, id> *> *) objectPostfixPropertyListForPhase:(nonnull NSDictionary *) phase;
- (nullable NSArray <NSDictionary <NSString *, id> *> *) artefactPrefixPropertyListForPhase:(nonnull NSDictionary *) phase;
- (nullable NSArray <NSDictionary <NSString *, id> *> *) artefactPostfixPropertyListForPhase:(nonnull NSDictionary *) phase;
- (nullable NSArray <NSDictionary <NSString *, id> *> *) sharedPropertyList;

- (nullable NSArray <NSString *> *) attachedInclude;
- (nullable NSArray <NSString *> *) attachedLibrary;
- (nullable NSArray <NSString *> *) attachedSource;
- (NSInteger) numberOfPhaseForActionKey:(nonnull NSString *) key;

@end
