//
//  QCCInterectionController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCInterectionController.h"
#import "QCCodeStorage.h"
#import "QCCodeView.h"



@interface QCCInterectionController() {

    QCCodeView  *_codeView;
    
}

@end

@implementation QCCInterectionController

const static NSUInteger doubleClickCount    = 2;

- (instancetype) initWithCodeView:(QCCodeView *) codeView {

    self = [super init];
    if (self) {
        
        _codeView = codeView;

    }

    return self;
}


#pragma mark - NSTextViewDelegate
- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange {
    
    NSRange charRange = oldSelectedCharRange;
    if (oldSelectedCharRange.location < newSelectedCharRange.location) {
        
        if (charRange.length == 0 && textView.string.length > charRange.length + charRange.location) {
            if ([[_codeView.codeStorage signatureForType:QCCodeStorageSignatureForClosedBrackets] containsObject:@(charRange.location)])
                for (NSDictionary *pair in [_codeView.codeStorage signatureForType:QCCodeStorageSignatureForBracketPairs]) {
                    if ([pair[@(QCCodeStorageSignatureForClosedBrackets)] integerValue] == charRange.location ) {
                        NSUInteger openBracketIndex = [pair[@(QCCodeStorageSignatureForOpenBrackets)] integerValue];
                        [_codeView showFindIndicatorForRange:NSMakeRange(openBracketIndex , 1)];
                    }
                }
        }
    }
    
    return newSelectedCharRange;
    
}
- (void)textView:(NSTextView *)textView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    NSLog(@"clickedOnCell :%@ frame:%@ char Index:%lu", cell, NSStringFromRect(cellFrame), charIndex);
}


- (void)textView:(NSTextView *)textView doubleClickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    NSLog(@"doubleClickedOnCell :%@ frame:%@ char Index:%lu", cell, NSStringFromRect(cellFrame), charIndex);
    
}

- (void)textView:(NSTextView *)view draggedCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)rect event:(NSEvent *)event atIndex:(NSUInteger)charIndex {
    
    NSLog(@"draggedCell :%@ frame:%@ char Index:%lu", cell, NSStringFromRect(rect), charIndex);
    
}


#pragma mark - Mouse Event Interection
- (BOOL) mouseDownInterception:(NSEvent *)theEvent {
    
    NSUInteger glyphIndex = [self glyphIndexForEvent:theEvent];
    if (glyphIndex != NSNotFound) {
        
        NSUInteger charIndex = [_codeView.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        NSRange effectiveRange = [self effectiveRangeForFoldedStringAtIndex:charIndex];
        
        if (effectiveRange.location != NSNotFound){
            _codeView.codeStorage.lineFoldingEnabled = YES;
            NSTextAttachment *attachment = [_codeView.textStorage attribute:NSAttachmentAttributeName atIndex:effectiveRange.location effectiveRange:NULL];
            if ([attachment.attachmentCell wantsToTrackMouse]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self interceptedMouseDownEvent:theEvent forAttachment:attachment];
                });
            }
            _codeView.codeStorage.lineFoldingEnabled = NO;
            
            return YES;
        }
    }

    return NO;
}

- (NSUInteger) glyphIndexForEvent:(NSEvent *)theEvent {
   
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint localPoint = [_codeView convertPoint:eventLocation fromView:nil];
    localPoint.x -= _codeView.textContainerInset.width;
    localPoint.y -= _codeView.textContainerInset.height;
    
    CGFloat fractionOfDistanceBetweenInsertion;
    NSUInteger glyphIndex = [_codeView.layoutManager glyphIndexForPoint:localPoint inTextContainer:_codeView.textContainer fractionOfDistanceThroughGlyph:&fractionOfDistanceBetweenInsertion];
    
    // Is valid char index
    if (glyphIndex < [_codeView.layoutManager numberOfGlyphs]) {
        CGRect glyphRect = [_codeView.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:_codeView.textContainer];
        if (CGRectContainsPoint(glyphRect, localPoint)) {
            return glyphIndex;
        }
    }
    return NSNotFound;
}

- (NSRange) effectiveRangeForFoldedStringAtIndex:(NSUInteger) charIndex {
    NSRange effectiveRange;
    
    NSNumber *attributeValue = [_codeView.textStorage attribute:QCCFoldedAttributeName
                                                        atIndex:charIndex
                                          longestEffectiveRange:&effectiveRange
                                                        inRange:NSMakeRange(0, [_codeView.textStorage length])];
    
    if (attributeValue && [attributeValue boolValue])
        return effectiveRange;
    
    return NSMakeRange(NSNotFound, 0);
}



#pragma mark - Attachment Interection
- (void) interceptedMouseDownEvent:(NSEvent *)theEvent forAttachment:(NSTextAttachment *) attachment {
    if (!(theEvent.type == NSLeftMouseDown) || (theEvent.clickCount != doubleClickCount))
        return;
    
    NSUInteger glyphIndex = [self glyphIndexForEvent:theEvent];
    
    if (glyphIndex != NSNotFound) {
        NSUInteger charIndex = [_codeView.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        [_codeView.codeStorage unfoldAtCharIndex:charIndex];
    }
}

@end
