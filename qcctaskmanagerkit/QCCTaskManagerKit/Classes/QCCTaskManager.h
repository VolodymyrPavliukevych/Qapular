//
//  QCCTaskManager.h
//  QCCTaskManagerKit
//
//  Created by Volodymyr Pavliukevych
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCTaskManager : NSObject

@property (nonatomic, copy) void (^ __nullable taskFinishedBlock)(QCCTaskManager *__nonnull manager, NSString * __nonnull identefier);
@property (nonatomic, copy) void (^ __nullable taskReceiveOutputDataBlock)(QCCTaskManager *__nonnull manager, NSString * __nonnull identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^ __nullable taskReceiveErrorOutputDataBlock)(QCCTaskManager *__nonnull manager, NSString * __nonnull identefier, NSUInteger lenght);
@property (nonatomic, readonly) BOOL isSerial;

- (nonnull instancetype) init;
- (nonnull instancetype) initForSerialTasks;

// Returns task identefier
- (nullable NSString *) launch:(BOOL) launch
                         path:(NSString * __nonnull) path
                     withArgs:(NSArray * __nullable) args
                   fromFolder:(NSString * __nullable) folder;


- (BOOL) launchTaskWithIdenefier:(NSString * __nonnull) idenefier;

- (nullable NSData *) outputDataForTaskIdenefier:(NSString * __nonnull) idenefier;
- (nullable NSData *) errorDataForTaskIdenefier:(NSString * __nonnull) idenefier;

- (nonnull NSArray <NSString *> *) taskIdentefiers;
- (nonnull NSArray <NSString *> *) finishedTaskIdentefiers;
- (nonnull NSArray <NSString *> *) runingTaskIdentefiers;

- (nonnull NSString *) launchPathForTaskIdenefier:(NSString * __nonnull) idenefier;
- (nullable NSArray *) argsForTaskIdenefier:(NSString * __nonnull) idenefier;
- (nullable NSString *) launchFolderForTaskIdenefier:(NSString * __nonnull) idenefier;

@end
