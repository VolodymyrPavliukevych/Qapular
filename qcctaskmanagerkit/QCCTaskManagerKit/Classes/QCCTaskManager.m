//
//  QCCTaskManager.m
//  QCCTaskManagerKit
//
//  Created by Volodymyr Pavliukevych
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCTaskManager.h"
#import "QCCTask.h"


@interface QCCTaskManager() {
    NSMutableDictionary      *_tasksDictionary;
    BOOL                       _serialTasks;
    
    NSMutableArray          *_serialTaskQueue;
    
}

@property (nonatomic, strong) void (^ __nullable outputDataCallbackBlock)(NSUInteger length, QCCTask * __nonnull task);
@property (nonatomic, strong) void (^ __nullable errorDataCallbackBlock)(NSUInteger length, QCCTask *__nonnull task);
@property (nonatomic, strong) void (^ __nullable finishedCallbackBlock)(QCCTask *__nonnull task);


@end

@implementation QCCTaskManager



- (nonnull instancetype) init {
    self = [super init];
    if (self) {
        _tasksDictionary = [NSMutableDictionary new];
        _serialTasks = NO;
    
    }
    return self;
}
- (nonnull instancetype) initForSerialTasks {
    self = [super init];
    if (self) {
        _tasksDictionary = [NSMutableDictionary new];
        _serialTaskQueue = [NSMutableArray new];
        _serialTasks = YES;
    }
    return self;
}
-(BOOL)isSerial {
    return _serialTasks;
}


- (nullable NSString *) launch:(BOOL) launch
                          path:(NSString * __nonnull) path
                      withArgs:(NSArray * __nullable) args
                    fromFolder:(NSString * __nullable) folder {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return nil;
    
    NSString *identefier = [[NSUUID UUID] UUIDString];
    
    QCCTask *task = [[QCCTask alloc] init];

    BOOL serialLaunch = NO;
    if (_serialTasks)
        serialLaunch = YES;
    
    [task launchedTask:(_serialTasks ? NO : launch)
        withLaunchPath:path
             arguments:args
     fromDirectoryPath:folder];
    
    task.finishedCallbackBlock = self.finishedCallbackBlock;
    task.outputDataCallbackBlock = self.outputDataCallbackBlock;
    task.errorDataCallbackBlock = self.errorDataCallbackBlock;


    _tasksDictionary[identefier] = task;
    
    if (_serialTasks && launch)
        [_serialTaskQueue addObject:identefier];
    
    
    return identefier;
}


- (BOOL) launchTaskWithIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return NO;
    
    QCCTask *task = _tasksDictionary[idenefier];
    
    if (_serialTasks && task && [[self runingTaskIdentefiers] count] != 0)
        [_serialTaskQueue addObject:idenefier];
    else
        [task launch];
    
    if (task)
        return YES;
    else
        return NO;
}

- (void) launchNextTask {
    if ([_serialTaskQueue count] == 0)
        return;
    
    NSString *idenefier = [_serialTaskQueue firstObject];
    [_serialTaskQueue removeObject:idenefier];
    
    [self launchTaskWithIdenefier:idenefier];
    
}

- (nullable NSData *) outputDataForTaskIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return nil;
    
    QCCTask *task = _tasksDictionary[idenefier];

    return [task outputData];
}

- (nullable NSData *) errorDataForTaskIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return nil;
    
    QCCTask *task = _tasksDictionary[idenefier];
    
    return [task errorData];

}

- (nonnull NSArray *) taskIdentefiers {
    return [_tasksDictionary allKeys];
}

- (nonnull NSArray *) finishedTaskIdentefiers {
    
    NSMutableArray *identefiers = [NSMutableArray new];
    for (NSString *key in [_tasksDictionary allKeys]) {
        QCCTask *task = _tasksDictionary[key];
        if(task.isFinished)
            [identefiers addObject:key];
    }
    
    return identefiers;
}

- (nonnull NSArray *) runingTaskIdentefiers {

    NSMutableArray *identefiers = [NSMutableArray new];
    for (NSString *key in [_tasksDictionary allKeys]) {
        QCCTask *task = _tasksDictionary[key];
        if(task.isRuning)
            [identefiers addObject:key];
    }
    
    return identefiers;
}

#pragma mark - Task Callbacks
-(void (^ __nullable)(NSUInteger lenght, QCCTask *__nonnull task))outputDataCallbackBlock {
    return ^(NSUInteger lenght, QCCTask *__nonnull task) {
        for (NSString *identefier in [_tasksDictionary allKeysForObject:task])
            if (self.taskReceiveOutputDataBlock)
                self.taskReceiveOutputDataBlock(self, identefier, lenght);
    };
}


-(void (^ __nullable)(NSUInteger lenght, QCCTask *__nonnull task))errorDataCallbackBlock {

    return ^(NSUInteger lenght, QCCTask *__nonnull task) {
        for (NSString *identefier in [_tasksDictionary allKeysForObject:task])
            if (self.taskReceiveErrorOutputDataBlock)
                self.taskReceiveErrorOutputDataBlock(self, identefier, lenght);
    };
}


-(void (^ __nullable)(QCCTask *__nonnull task))finishedCallbackBlock {
    return ^(QCCTask *__nonnull task) {
        for (NSString *identefier in [_tasksDictionary allKeysForObject:task]) {
            if (_serialTasks)
                [self launchNextTask];
            
            if (self.taskFinishedBlock)
                self.taskFinishedBlock(self, identefier);
        }
    };
}

- (nonnull NSString *) launchPathForTaskIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return nil;
    QCCTask *task = _tasksDictionary[idenefier];
    return [task launchPath];
}

- (nullable NSArray *) argsForTaskIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return nil;
    QCCTask *task = _tasksDictionary[idenefier];
    return [task args];
    
}

- (nullable NSString *) launchFolderForTaskIdenefier:(NSString * __nonnull) idenefier {
    if (!idenefier)
        return nil;
    QCCTask *task = _tasksDictionary[idenefier];
    return [task launchFolder];
    
}

@end
