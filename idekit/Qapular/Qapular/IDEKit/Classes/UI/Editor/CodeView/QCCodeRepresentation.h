//
//  QCCodeRepresentation.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCodeView;

@interface QCCodeRepresentation : NSObject

@property (nonatomic, readonly) NSArray *bracketPairs;


extern NSString *const QCCEditorRulerOpenBracketIndexKey;
extern NSString *const QCCEditorRulerClosedBracketIndexKey;
extern NSString *const QCCEditorRulerOpenBracketRectKey;
extern NSString *const QCCEditorRulerClosedBracketRectKey;

- (instancetype) initForCodeView:(QCCodeView *) codeView;

@end
