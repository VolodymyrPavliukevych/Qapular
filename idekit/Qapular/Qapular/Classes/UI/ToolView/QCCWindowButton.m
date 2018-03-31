//
//  QCCWindowButton.m
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCWindowButton.h"

@interface QCCWindowButton() {

    QCCButtonColor  _buttonColor;
    BOOL            _highlighted;
    BOOL            _interected;
    
}

@end

@implementation QCCWindowButton

const QCCButtonColor RedButtonColor =       {{0.8863, 0.2745, 0.2745, 1.0}, {0.8314, 0.1451, 0.1765, 1.0}};
const QCCButtonColor YellowButtonColor =    {{0.9412, 0.6902, 0.1451, 1.0}, {0.8392, 0.5608, 0.1412, 1.0}};
const QCCButtonColor GreenButtonColor =     {{0.3216, 0.7647, 0.1961, 1.0}, {0.2706, 0.6275, 0.1059, 1.0}};
const QCCButtonColor GrayButtonColor =      {{0.3000, 0.3000, 0.3000, 1.0}, {0.3000, 0.3000, 0.3000, 1.0}};


const NSRect ButtonFillColoredRect  = {{4, 4}, {12, 12}};
const NSRect ButtonStrokeColoredRect  = {{5, 5}, {10, 10}};

const float SelectedDiffValue = 0.2f;

- (void) setWindowButtonType:(NSWindowButton) type {

    switch (type) {
        case NSWindowCloseButton:
            _buttonColor = RedButtonColor;
            break;
        case NSWindowMiniaturizeButton:
            _buttonColor = YellowButtonColor;
            break;
        case NSWindowFullScreenButton:
            _buttonColor = GreenButtonColor;
            break;
        default:
            _buttonColor = GrayButtonColor;
            break;
    }
    

}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    _highlighted = NO;
    _interected = NO;
    
    return self;
}


-(id) awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [super awakeAfterUsingCoder:aDecoder];
}


-(void)awakeFromNib {
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:[self bounds]
                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                    owner:self userInfo:nil];
    
    [self addTrackingArea:trackingArea];
     
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
    [graphicsContext saveGraphicsState];
    
    NSColor *firstColor = [self strokeColor:_highlighted];
    NSColor *secondColor = [self fillColor:_highlighted];
    
    //[bezierPath setLineCapStyle: NSSquareLineCapStyle];
    //[bezierPath setLineJoinStyle: NSRoundLineJoinStyle];
    
    [firstColor setFill];
    
    NSBezierPath* firstCirclePath = [NSBezierPath bezierPath];
    [firstCirclePath appendBezierPathWithOvalInRect: ButtonFillColoredRect];
    
    [firstCirclePath fill];

    
    [secondColor setFill];

    NSBezierPath* secondCirclePath = [NSBezierPath bezierPath];
    [secondCirclePath appendBezierPathWithOvalInRect: ButtonStrokeColoredRect];
    
    [secondCirclePath fill];
    
    if (_interected) {
        
        [[self strokeColor:YES] setFill];
        NSBezierPath *iconPath = [NSBezierPath bezierPath];
        [iconPath appendBezierPathWithOvalInRect:CGRectMake(8, 8, 4, 4)];
        [iconPath fill];
        
    
    }
    
    [graphicsContext restoreGraphicsState];
    
    //[super drawRect:dirtyRect];

}

- (NSColor *) fillColor:(BOOL) selected {
    QCCStructColor  color = _buttonColor.backgroundColor;
    float selectedValue = (selected ? SelectedDiffValue : 0);
    return [NSColor colorWithRed:color.red - selectedValue
                           green:color.green - selectedValue
                            blue:color.blue - selectedValue
                           alpha:color.alpha];

}

- (NSColor *) strokeColor:(BOOL) selected {
    QCCStructColor  color = _buttonColor.strokeColor;
    float selectedValue = (selected ? SelectedDiffValue : 0);
    return [NSColor colorWithRed:color.red - selectedValue
                           green:color.green - selectedValue
                            blue:color.blue - selectedValue
                           alpha:color.alpha];
}


- (void)mouseEntered:(NSEvent *)theEvent{
    _interected = YES;
    [self setNeedsDisplay:YES];
    
}

- (void)mouseExited:(NSEvent *)theEvent{
    _interected = NO;
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent {
    _highlighted = YES;
    [self setNeedsDisplay:YES];
    
    while ((theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSKeyDownMask])) {
        
        if ([theEvent type] == NSLeftMouseUp) {
            
            [self mouseUp:theEvent];
            break;
        }
        
        else if ([theEvent type] == NSKeyDown) {
            NSBeep ();
            continue;
        }
    }

    [super mouseDown:theEvent];

}



-(void)mouseUp:(NSEvent *)theEvent {
    _highlighted = NO;
    [self setNeedsDisplay:YES];
    [super mouseUp:theEvent];
}



@end
