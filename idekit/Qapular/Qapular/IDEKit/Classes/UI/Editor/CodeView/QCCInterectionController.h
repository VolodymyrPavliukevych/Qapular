//
//  QCCInterectionController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class QCCodeView;


@interface QCCInterectionController : NSObject <NSTextViewDelegate>

- (instancetype) initWithCodeView:(QCCodeView *) codeView;
- (BOOL) mouseDownInterception:(NSEvent *)theEvent;

@end
