//
//  QCCodeView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class QCCodeStorage;
@class QCCThemaManager;
@class QCCodeLayoutManager;
@class QCCodeRepresentation;

@interface QCCodeView : NSTextView

const extern NSSize QCCodeViewInset;

@property (nonatomic, strong, setter=replaceCodeStorage:) QCCodeStorage *codeStorage;
@property (nonatomic, readonly) QCCodeRepresentation *codeRepresentation;
@property (nonatomic) CGFloat wrapingColumnWidht;


- (void) setThemaManager:(QCCThemaManager *) themaManager;
- (QCCodeLayoutManager *) codeLayoutManager;
- (void) showPopoverForFixIts:(NSArray *) fixIts;
@end
