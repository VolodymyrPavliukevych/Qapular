//
//  QCCEditorRulerView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCThemaManager;
@class QCCodeView;

@interface QCCEditorRulerView : NSRulerView {
}
@property (nonatomic) BOOL shouldShowLineNumber;

- (instancetype)initWithScrollView:(NSScrollView *)scrollView
                       forCodeView:(QCCodeView *) codeView
                   andThemaManager:(QCCThemaManager *) themaManager;



@end
