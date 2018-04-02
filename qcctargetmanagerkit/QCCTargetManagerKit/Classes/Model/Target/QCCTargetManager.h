//
//  QCCTargetManager.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@class QCComplexURL;
@class QCCTarget;
@class QCCPackage;

NS_ASSUME_NONNULL_BEGIN
extern NSString *const QCCTargetManagerKnownTargetsKey;
extern NSString *const QCCTargetManagerUnknownTargetsKey;
NS_ASSUME_NONNULL_END

@interface QCCTargetManager : NSObject

+ (nonnull instancetype) defaultManager;
- (nonnull instancetype) initWithFileURL:(nonnull NSURL *) optionsFileURL;

- (nonnull NSDictionary <NSString *, QCCPackage *> *) packages;
- (nonnull NSDictionary <NSString *, QCCTarget *> *) targets;

// Returnd Dictionary or QCCTarget by key
- (nonnull NSDictionary <NSString *, NSDictionary <NSString *, id> *> *) attachedTargets;
- (nonnull QCComplexURL *) processPackagePath:(nonnull NSString *) path;

- (nullable NSViewController *) serialConsoleViewController;
- (void) consoleWithBSDName:(nonnull NSString *) BSDname pause:(BOOL) pause;
@end
