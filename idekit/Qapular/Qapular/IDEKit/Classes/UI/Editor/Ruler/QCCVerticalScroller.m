//
//  QCCVerticalScroller.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCVerticalScroller.h"


#define SCROLLER_WIDTH 300.0

@implementation QCCVerticalScroller

+ (CGFloat)scrollerWidth {
    return SCROLLER_WIDTH;
}

+ (CGFloat)scrollerWidthForControlSize: (NSControlSize)controlSize {
    return SCROLLER_WIDTH;
}

@end
