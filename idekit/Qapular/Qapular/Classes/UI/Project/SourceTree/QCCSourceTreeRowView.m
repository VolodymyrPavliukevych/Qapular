//
//  QCCSourceTreeRowView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCSourceTreeRowView.h"

@implementation QCCSourceTreeRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)drawBackgroundInRect:(NSRect)dirtyRect {
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (!_selectedBackgroundColor)
        return;
    
    [_selectedBackgroundColor setFill];
    [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
}


@end
