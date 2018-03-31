//
//  QCCAnalyser.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCAnalyser.h"
#import "QCCHighlighter.h"

@implementation QCCAnalyser

static NSString *const AnalyserOperationQueueName = @"AnalyserOperationQueue";

- (instancetype) initForCodeStorage:(QCCodeStorage *) codeStorage
                       themaManager:(QCCThemaManager *) themaManager  {

    self = [super init];
    
    if (self) {
        _themaManager = themaManager;
        _codeStorage = codeStorage;
        _analyserOperationQueue = [[NSOperationQueue alloc] init];
        _analyserOperationQueue.name = AnalyserOperationQueueName;
        _analyserOperationQueue.maxConcurrentOperationCount = 1;
    }

    return self;
}



#pragma mark - NSTextStorageDelegate

- (void)textStorageWillProcessEditing:(NSNotification *)notification {
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    
}

- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlockOnMainQueue:(void (^)(void)) completeBlock waitUntilFinished:(BOOL) waitUntilFinished {
    if (!_analyserOperationQueue)
        return NO;
    
    NSBlockOperation *analyzeOperation = [[NSBlockOperation alloc] init];
    [analyzeOperation setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock();
        });
    }];
    
    [analyzeOperation addExecutionBlock:executionBlock];
    [_analyserOperationQueue addOperations:@[analyzeOperation] waitUntilFinished:waitUntilFinished];
    return YES;
}

- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlock:(void (^)(void)) completeBlock waitUntilFinished:(BOOL) waitUntilFinished{
    if (!_analyserOperationQueue)
        return NO;

    NSBlockOperation *analyzeOperation = [[NSBlockOperation alloc] init];
    [analyzeOperation setCompletionBlock:completeBlock];
    [analyzeOperation addExecutionBlock:executionBlock];
    [_analyserOperationQueue addOperations:@[analyzeOperation] waitUntilFinished:waitUntilFinished];
    
    return YES;
}

- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlockOnMainQueue:(void (^)(void)) completeBlock {
    return [self analyzeExecutionBlock:executionBlock completeBlockOnMainQueue:completeBlock waitUntilFinished:YES];
}
- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlock:(void (^)(void)) completeBlock {
    
    return [self analyzeExecutionBlock:executionBlock completeBlock:completeBlock waitUntilFinished:YES];
}


@end
