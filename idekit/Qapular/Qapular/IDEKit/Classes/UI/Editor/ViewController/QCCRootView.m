//
//  QCCRootView.m
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCRootView.h"

@implementation QCCRootView

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    
    self = [super awakeAfterUsingCoder:aDecoder];
    if (self) {
        /*
        self.wantsLayer            = YES;
        self.layer.frame           = self.frame;
        self.layer.cornerRadius    = 7.0;
        self.layer.masksToBounds   = YES;
         */
    }
    
    return self;
    
}
-(void)awakeFromNib {
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSColor *backgroundColor = [NSColor whiteColor];
    [backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    /*
    [[NSColor redColor] setStroke];
    NSRect windowRect = [[self window] frame]; windowRect.origin = NSMakePoint(0, 0);
    
    float cornerRadius = self.layer.cornerRadius;
    [[NSBezierPath bezierPathWithRoundedRect:windowRect xRadius:cornerRadius yRadius:cornerRadius] addClip];
    [[NSBezierPath bezierPathWithRect:dirtyRect] addClip];
     */
    
}

@end
