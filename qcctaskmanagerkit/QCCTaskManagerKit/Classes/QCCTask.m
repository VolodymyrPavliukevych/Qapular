//
//  QCCTask.m
//  QCCTaskManagerKit
//
//  Created by Volodymyr Pavliukevych
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCTask.h"

@interface QCCTask() {
    NSMutableData       *_standardOutputData;
    NSMutableData       *_errorOutputData;
    
    NSPipe              *_standardInputPipe;
    NSPipe              *_standardOutputPipe;

    NSPipe              *_errorPipe;
    
    NSTask              *_systemTask;

    dispatch_queue_t    _systemTaskQueue;
    dispatch_queue_t    _systemTaskMainQueue;
    
    BOOL                _isFinished;
    BOOL                _isRuned;
    
}


@property(nonatomic, strong) void (^ standardInputBlock)(NSFileHandle * fileHandle);
@property(nonatomic, strong) void (^ standardOutputBlock)(NSFileHandle * fileHandle);
@property(nonatomic, strong) void (^ errorOutputBlock)(NSFileHandle * fileHandle);


@end

static const char *QCCTaskQueueLabel = "com.qapular.QCCTaskManagerKit.QCCTask.dataQueue";
static const char *QCCTaskMainQueueLabel = "com.qapular.QCCTaskManagerKit.QCCTask.mainQueue";

@implementation QCCTask

- (instancetype) init {

    self = [super init];
    if(self) {
        _systemTask = [[NSTask alloc] init];
        if (!_systemTask)
            return nil;
        
        _systemTaskQueue = dispatch_queue_create(QCCTaskQueueLabel, NULL);
        _systemTaskMainQueue = dispatch_queue_create(QCCTaskMainQueueLabel, NULL);
        
        _standardOutputData = [NSMutableData new];
        _errorOutputData = [NSMutableData new];
        
        _standardInputPipe = [NSPipe pipe];
        _standardOutputPipe = [NSPipe pipe];

        _errorPipe = [NSPipe pipe];
        
        _systemTask.standardError = _errorPipe;
        _systemTask.standardInput = _standardInputPipe;
        _systemTask.standardOutput = _standardOutputPipe;
        
        
        _standardOutputPipe.fileHandleForReading.readabilityHandler = self.standardOutputBlock;

        /*
         Not using ight now.
        _standardInputPipe.fileHandleForWriting.writeabilityHandler = self.standardInputBlock;
         */
        
        _errorPipe.fileHandleForReading.readabilityHandler = self.errorOutputBlock;
        
    }
    
    return self;
}

- (void) launchedTask:(BOOL)launche
       withLaunchPath:(NSString * __nonnull)path
            arguments:(NSArray * __nullable)arguments
    fromDirectoryPath:(NSString * __nullable) directoryPath {
    
    if (!path)
        return;

    _systemTask.launchPath = path;
    _systemTask.arguments = arguments;

    if (directoryPath)
        _systemTask.currentDirectoryPath = directoryPath;
    
    if (launche)
        [self launch];
}

- (void) launch {
    if (_systemTask.launchPath && !_systemTask.isRunning) {
        _isRuned = YES;
        dispatch_async(_systemTaskMainQueue, ^{

            [_systemTask launch];
            
            _systemTask.terminationHandler = ^(NSTask * task) {
                NSPipe *pipe = task.standardOutput;
                [pipe.fileHandleForReading closeFile];
                
                [task.standardOutput fileHandleForReading].readabilityHandler = nil;
                [task.standardError fileHandleForReading].readabilityHandler = nil;
            };
            
            [_systemTask waitUntilExit];

            _isRuned = NO;
            _isFinished = YES;
            if (self.finishedCallbackBlock)
                self.finishedCallbackBlock(self);
        });
    }
}

- (void) terminate {
    [_systemTask terminate];
}

- (BOOL) isRuning {
    return _isRuned;
}

- (BOOL) isFinished {
    return _isFinished;
}

-(void (^)(NSFileHandle * fileHandle))errorOutputBlock {
    return ^(NSFileHandle * fileHandle) {
        NSData *availableData = [fileHandle availableData];        
        dispatch_sync(_systemTaskQueue, ^{
            [_errorOutputData appendData:availableData];
        });


        if (self.errorDataCallbackBlock)
            self.errorDataCallbackBlock(availableData.length, self);
    };
}

-(void (^)(NSFileHandle *))standardOutputBlock {
    return ^(NSFileHandle *fileHandle) {
        NSData *availableData = [fileHandle availableData];
        dispatch_sync(_systemTaskQueue, ^{
            [_standardOutputData appendData:availableData];
        });
        
        if (self.outputDataCallbackBlock)
            self.outputDataCallbackBlock(availableData.length, self);
    };
}


/*
 Not using ight now.
 */
-(void (^)(NSFileHandle *))standardInputBlock {
    return ^(NSFileHandle *fileHandle) {
        [fileHandle writeData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
        //fileHandle.writeabilityHandler = nil;
        [fileHandle closeFile];
    };
}

#pragma mark - Public
-(BOOL)writeData:(NSData * __nonnull) data {
    if (data && _standardInputPipe && _systemTask.isRunning) {
        [_standardInputPipe.fileHandleForWriting writeData:data];
        [_standardInputPipe.fileHandleForWriting closeFile];
        return YES;
    }
    return NO;
}

-(NSData * __nullable) outputData {
    __block NSData *returnedData;
    dispatch_sync(_systemTaskQueue, ^{
        returnedData = [NSData dataWithData:_standardOutputData];
    });
    return returnedData;
}

-(NSData * __nullable)errorData {
    
    __block NSData *returnedData;
    
    dispatch_sync(_systemTaskQueue, ^{
        returnedData = [_errorOutputData copy];
    });
    
    return returnedData;
}

- (nonnull NSString *) launchPath {
    return _systemTask.launchPath;
}
- (nullable NSArray *) args {
    return _systemTask.arguments;
}
- (nullable NSString *) launchFolder {
    return _systemTask.currentDirectoryPath;
}

@end
