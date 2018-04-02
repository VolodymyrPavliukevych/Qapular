//
//  QCCTask.h
//  QCCTaskManagerKit
//
//  Created by Volodymyr Pavliukevych
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCTask : NSObject

@property (nonatomic, strong) NSData * __nullable outputData;
@property (nonatomic, copy) void (^ __nullable outputDataCallbackBlock)(NSUInteger length, QCCTask * __nonnull task);

@property (nonatomic, strong) NSData * __nullable errorData;
@property (nonatomic, copy) void (^ __nullable errorDataCallbackBlock)(NSUInteger length, QCCTask * __nonnull task);

@property (nonatomic, copy) void (^ __nullable finishedCallbackBlock)(QCCTask * __nonnull task );


- (void) launchedTask:(BOOL)launche
       withLaunchPath:(NSString * __nonnull)path
            arguments:(NSArray * __nullable)arguments
    fromDirectoryPath:(NSString * __nullable) directoryPath;

- (void) terminate;
- (BOOL) isRuning;
- (BOOL) isFinished;
- (void) launch;
- (BOOL) writeData:(NSData * __nonnull) data;

- (nonnull NSString *) launchPath;
- (nullable NSArray *) args;
- (nullable NSString *) launchFolder;

@end
