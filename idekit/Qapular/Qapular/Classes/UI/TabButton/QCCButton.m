//
//  QCCButton.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCButton.h"
#import "QCCGeometry.h"

@implementation QCCButton
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {}
    return self;
}

-(void)drawCell:(NSCell *)aCell {
    [super drawCell:aCell];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (!_tintColor || !_selectedTintColor) {
        [super drawRect:dirtyRect];
        return;
    }
    
    
    if (self.backgroundColor) {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
    
    NSColor *color = (self.state ? _selectedTintColor : _tintColor);
    
    CGSize size = [self.image size];
    
    CGFloat originX =  (dirtyRect.size.width - size.width) / 2;
    CGFloat originY =  (dirtyRect.size.height - size.height) / 2;
    
    [self.image lockFocus];
    [color set];
    NSRect drawRect = NSMakeRect(0,
                                 0,
                                 size.width,
                                 size.height);
    
    NSRectFillUsingOperation(drawRect, NSCompositeSourceAtop);
    
    [self.image unlockFocus];
    
    
    [self.image drawInRect:NSMakeRect(truncCGFloat(originX),
                                      truncCGFloat(originY),
                                      size.width,
                                      size.height)];

    
}



@end
