//
//  QCCBaseToolView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseToolView.h"
#import "QCCThemaManager.h"

@implementation QCCBaseToolView
-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self = [super awakeAfterUsingCoder:aDecoder];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themaReplaced)
                                                     name:QCCThemaManagerReplacedNotification
                                                   object:nil];
    }
    
    return self;
}

-(void) themaReplaced {
    [self updateColors];
    [self setNeedsDisplay:YES];
}

-(void) setThemaManager:(QCCThemaManager *) themaManager {
    _themaManager = themaManager;
    [self updateColors];

}

- (void) updateColors {
    switch ([_themaManager spectrum]) {
            
        case QCCThemaSpectrumUnknown:
            _backgroundColor = [NSColor darkGrayColor];
            _gradientColor = [NSColor grayColor];
            
            _darkLineColor = [NSColor lightGrayColor];
            _lightLineColor = [NSColor whiteColor];
            break;
            
        case QCCThemaSpectrumLight:
            _backgroundColor = [NSColor colorWithRed:0.9607 green:0.9607 blue:0.9607 alpha:1.0f];
            _gradientColor = [NSColor colorWithRed:0.9921 green:0.9921 blue:0.9921 alpha:1.0f];
            
            _darkLineColor = [NSColor lightGrayColor];
            _lightLineColor = [NSColor whiteColor];
            break;
            
        case QCCThemaSpectrumDark:
            
            _darkLineColor = [NSColor blackColor];
            _lightLineColor = [NSColor grayColor];
            
            _backgroundColor = [NSColor colorWithRed:0.2888 green:0.2888 blue:0.2888 alpha:1.0];
            
            _gradientColor = [NSColor colorWithRed:0.3900 green:0.3900 blue:0.3900 alpha:1.0];
            
            break;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:_gradientColor
                                                          endingColor:_backgroundColor];
    CGFloat gradientHeight = [self bounds].size.height;
    CGFloat viewHeight = [self bounds].size.height;
    NSRect gradientRect = [self bounds];
    gradientRect.size.height = gradientHeight;
    gradientRect.origin.y += viewHeight - gradientHeight;
    
    [aGradient drawInRect:gradientRect angle:270];
    
    
    
//    // line
//    NSPoint lightPointsArray[4];
//    
//    lightPointsArray[0] = NSMakePoint(0, self.bounds.size.height - 2);
//    lightPointsArray[1] = NSMakePoint(self.bounds.size.width, self.bounds.size.height - 2);
//    lightPointsArray[2] = NSMakePoint(self.bounds.size.width, self.bounds.size.height-1);
//    lightPointsArray[3] = NSMakePoint(0, self.bounds.size.height-1 );
//    
//    
//    
//    NSBezierPath *lightPath = [NSBezierPath bezierPath];
//    [lightPath appendBezierPathWithPoints:lightPointsArray count:4];
//    
//    
    NSPoint darkPointsArray[4];
//    darkPointsArray[0] = NSMakePoint(0, self.bounds.size.height - 1);
//    darkPointsArray[1] = NSMakePoint(self.bounds.size.width, self.bounds.size.height - 1);
//    darkPointsArray[2] = NSMakePoint(self.bounds.size.width, self.bounds.size.height);
//    darkPointsArray[3] = NSMakePoint(0, self.bounds.size.height);
//    
//    
//    NSBezierPath *darkPath = [NSBezierPath bezierPath];
//    [darkPath appendBezierPathWithPoints:darkPointsArray count:4];
//    
//    [[NSColor redColor] setFill];
//    [lightPath fill];
//    
//    [_darkLineColor setFill];
//    [darkPath fill];
//    
    darkPointsArray[0] = NSMakePoint(0, 1);
    darkPointsArray[1] = NSMakePoint(self.bounds.size.width, 1);
    darkPointsArray[2] = NSMakePoint(self.bounds.size.width, 0);
    darkPointsArray[3] = NSMakePoint(0, 0);
    
    NSBezierPath *darkButtomPath = [NSBezierPath bezierPath];
    [darkButtomPath appendBezierPathWithPoints:darkPointsArray count:4];
    
    [_darkLineColor setFill];
    [darkButtomPath fill];

    
    [super drawRect:dirtyRect];
    
}
- (void) prepareAppearence {
    // It should be reloaded in sucblasses.
}

@end
