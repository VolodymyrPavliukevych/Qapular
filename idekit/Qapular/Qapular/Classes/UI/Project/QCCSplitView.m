//
//  QCCSplitView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCSplitView.h"

@implementation QCCSplitView

static const CGFloat MinSplitedViewWidth = 200.0f;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
}


+ (CGFloat) minSplitedViewWidth {
    return MinSplitedViewWidth;
}



@end
