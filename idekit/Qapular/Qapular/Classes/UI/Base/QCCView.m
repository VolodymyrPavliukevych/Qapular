//
//  QCCView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCView.h"

@implementation QCCView

- (void)drawRect:(NSRect)dirtyRect {

    [self drawBackground];
    
    NSRectFill(dirtyRect);
    
    [self drawBorder];

}

- (void) drawBorder {
    if (self.borderColor) {
        [self.borderColor setStroke];
        [[NSBezierPath bezierPathWithRect:self.bounds] stroke];
    }
}

- (void) drawBackground {
    if (self.backgroundColor)
        [self.backgroundColor setFill];
    else
        [[NSColor whiteColor] setFill];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}


-(void) setBorderColor:(NSColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay:YES];
}

@end
