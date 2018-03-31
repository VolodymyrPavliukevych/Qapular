//
//  QCCAnalyser.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class QCCHighlighter;
@class QCCodeStorage;
@class QCCThemaManager;


@interface QCCAnalyser : NSObject <NSTextStorageDelegate> {
    
    QCCHighlighter  *_highlighter;
    QCCodeStorage   *_codeStorage;
    QCCThemaManager *_themaManager;
    NSOperationQueue    *_analyserOperationQueue;
        
}

- (instancetype) initForCodeStorage:(QCCodeStorage *) codeStorage
                       themaManager:(QCCThemaManager *) themaManager;


// only for subclasses
- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlock:(void (^)(void)) completeBlock;
- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlock:(void (^)(void)) completeBlock waitUntilFinished:(BOOL) waitUntilFinished;

- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlockOnMainQueue:(void (^)(void)) completeBlock;
- (BOOL) analyzeExecutionBlock:(void (^)(void))executionBlock completeBlockOnMainQueue:(void (^)(void)) completeBlock waitUntilFinished:(BOOL) waitUntilFinished;


@end
