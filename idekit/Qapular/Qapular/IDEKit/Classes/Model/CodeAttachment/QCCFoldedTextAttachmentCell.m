//
//  QCCFoldedTextAttachmentCell.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFoldedTextAttachmentCell.h"
#import "QCCGeometry.h"

@implementation QCCFoldedTextAttachmentCell

static const CGFloat    CellPadding = 3.0f;
static const CGSize     CellSize = {16.0f, 8.0f};
static const CGFloat    CellRoundConerXRadius = 2.0f;
static const CGFloat    CellRoundConerYRadius = 2.0f;
static const CGRect     CellDotRect = {{0.0, 0.0}, {2.0f, 2.0f}};

- (void)drawWithFrame:(NSRect)cellFrame
               inView:(NSView *)controlView
       characterIndex:(NSUInteger)charIndex
        layoutManager:(NSLayoutManager *) layoutManager {


    CGFloat xOrigin = roundCGFloat(cellFrame.origin.x) + CellPadding;
    CGFloat yOrigin = roundCGFloat(cellFrame.origin.y) + CellPadding;
    CGRect rect = NSMakeRect(xOrigin, yOrigin, CellSize.width, CellSize.height);
    
    NSBezierPath* editedBezierPath = [NSBezierPath bezierPath];
    
    [editedBezierPath appendBezierPathWithRoundedRect:rect xRadius:CellRoundConerXRadius yRadius:CellRoundConerYRadius];
    
    [[NSColor brownColor] setStroke];
    
    [editedBezierPath stroke];
    
    [[NSColor yellowColor] setFill];
    [editedBezierPath fill];
    
    
    NSBezierPath *dotsBezierPath = [NSBezierPath bezierPath];
    
    [dotsBezierPath appendBezierPathWithOvalInRect:CGRectOffset(CellDotRect, xOrigin + CellPadding, yOrigin + CellPadding)];
    [dotsBezierPath appendBezierPathWithOvalInRect:CGRectOffset(CellDotRect, xOrigin + CellPadding + 4, yOrigin + CellPadding)];
    [dotsBezierPath appendBezierPathWithOvalInRect:CGRectOffset(CellDotRect, xOrigin + CellPadding + 8, yOrigin + CellPadding)];
    
    [[NSColor brownColor] setFill];
    [dotsBezierPath fill];

}


- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer
               proposedLineFragment:(NSRect)lineFrag
                      glyphPosition:(NSPoint)position
                     characterIndex:(NSUInteger)charIndex {
    NSRect rect = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    return rect;
    
}

-(BOOL) wantsToTrackMouse {
    return YES;
}

- (BOOL) wantsToTrackMouseForEvent:(NSEvent *)theEvent
                            inRect:(NSRect)cellFrame
                            ofView:(NSView *)controlView
                  atCharacterIndex:(NSUInteger)charIndex {
    NSLog(@"%s", __FUNCTION__);
    NSBeep();
    return YES;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag {
    NSLog(@"%s %@", __FUNCTION__ ,NSStringFromRange(NSMakeRange(charIndex, 0)));
    return YES;
}


-(BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    NSLog(@"%s %@", __FUNCTION__ , NSStringFromRect(cellFrame));

    return YES;
}

-(NSSize)cellSize {
    return NSMakeSize(22, 11);
}

@end
