//
//  QCCodeRepresentation.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeRepresentation.h"
#import "QCCodeStorage.h"
#import "QCCodeLayoutManager.h"
#import "QCCodeView.h"
#import "QCCGeometry.h"
#import "QCCBracketMachine.h"

@interface QCCodeRepresentation() {
    
    QCCodeView  *_codeView;
    BOOL        _needsUpdate;

}

@end

@implementation QCCodeRepresentation

@synthesize bracketPairs = _bracketPairs;

NSString *const QCCEditorRulerOpenBracketIndexKey = @"QCCEditorRulerOpenBracketIndexKey";
NSString *const QCCEditorRulerClosedBracketIndexKey = @"QCCEditorRulerClosedBracketIndexKey";
NSString *const QCCEditorRulerOpenBracketRectKey = @"QCCEditorRulerOpenBracketRectKey";
NSString *const QCCEditorRulerClosedBracketRectKey = @"QCCEditorRulerClosedBracketRectKey";

- (instancetype) initForCodeView:(QCCodeView *) codeView {

    self = [super init];
    if (self) {
        _codeView = codeView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsUpdateForNotification:)
                                                     name:QCCBracketMachineUpdatedNotification
                                                   object:nil];
    }
    return self;
}

- (void) invalidateBracketPairs {
    
    NSMutableArray *pairs = [NSMutableArray new];
    
    QCCodeLayoutManager *layoutManager = [_codeView codeLayoutManager];
    
    NSArray * bracketPairs = [_codeView.codeStorage signatureForType:QCCodeStorageSignatureForBracketPairs];
    
    for (NSDictionary *pair in [bracketPairs reverseObjectEnumerator]) {
        
        NSInteger openBracketCharIndex = [pair[@(QCCodeStorageSignatureForOpenBrackets)] integerValue];
        NSInteger closedBracketCharIndex = [pair[@(QCCodeStorageSignatureForClosedBrackets)] integerValue];
        
        NSRect openBracketRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(openBracketCharIndex, 1) inTextContainer:_codeView.textContainer];
        NSRect closedBracketRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(closedBracketCharIndex, 1) inTextContainer:_codeView.textContainer];
        
        
        NSRect openBracketRectWithInset = CGRectOffset(openBracketRect, QCCodeViewInset.width, QCCodeViewInset.height);
        NSRect closedBracketRectWithInset = CGRectOffset(closedBracketRect, QCCodeViewInset.width, QCCodeViewInset.height);
        
        [pairs addObject:@{QCCEditorRulerOpenBracketIndexKey: @(openBracketCharIndex),
                           QCCEditorRulerOpenBracketRectKey: [NSValue valueWithRect:truncNSRect(openBracketRectWithInset)],
                           QCCEditorRulerClosedBracketIndexKey: @(closedBracketCharIndex),
                           QCCEditorRulerClosedBracketRectKey: [NSValue valueWithRect:truncNSRect(closedBracketRectWithInset)]}];
    }
    _needsUpdate = NO;
    _bracketPairs = pairs;
}

- (void) needsUpdateForNotification:(NSNotification *) notification {
    if (notification.object == _codeView.codeStorage)
        _needsUpdate = YES;
    
}

- (NSArray *) bracketPairs {
    if (_needsUpdate)
        [self invalidateBracketPairs];
    
    return _bracketPairs;
}

@end
