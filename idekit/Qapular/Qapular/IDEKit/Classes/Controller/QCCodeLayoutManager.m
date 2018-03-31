//
//  QCCodeLayoutManager.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeLayoutManager.h"
#import "QCCodeGlyphGenerator.h"
#import "QCCodeTypesetter.h"
#import "QCCodeStorage.h"
#import "QCCGeometry.h"

@implementation QCCLineSignature

NSString *const QCCLineSignatureUpdatedNotification = @"QCCLineSignatureUpdatedNotification";

-(NSString *)description {
    
    NSString *hasSoftBreak = (self.hasSoftBreak ? @"YES" : @"NO");
    NSString *rect = NSStringFromRect(self.rect);
    NSString *containsCharRange = NSStringFromRange(self.containsCharRange);
    
    return [NSString stringWithFormat:@"<QCCLineSignature: %p, hasSoftBreak:%@, rect:%@, containsCharRange:%@, countOfChars:%lu > ",
            self, hasSoftBreak, rect, containsCharRange, self.countOfChars];
}

@end

@interface QCCodeLayoutManager() {
    
    NSMutableArray      *_lineSignatureMutableArray;
    NSDictionary        *_markerMessageAttributes;

}
- (void) invalidatedLineSignatureForRange:(NSRange) changedRange;

@end

const static CGFloat    QCCLineMarkerBackgroundAlphaValue   =   0.2f;
const static CGFloat    QCCLineMarkerMessageAlphaValue      =   0.9f;
const static CGFloat    QCCLineMarkerMessageLeftPadding     =   20.0f;
//const static CGFloat    QCCLineMarkerMessageRightPadding    =   40.0f;
const static CGFloat    QCCLineMarkerMessageArrowWidth      =   40.0f;
const static CGFloat    QCCLineMarkerWavyLineHeight         =   3.0f;
const static CGFloat    QCCLineMarkerWavyLineStep           =   3.0f;

@implementation QCCodeLayoutManager

const static unichar QCCodeLayoutManagerSoftNewLineChar = '\n';

-(instancetype)init {

    self = [super init];
    if (self) {
        
        _lineSignatureMutableArray = [NSMutableArray new];
        
        [self setTypesetter:[[QCCodeTypesetter alloc] init]];
        [self setGlyphGenerator:[[QCCodeGlyphGenerator alloc] init]];
/*
#warning Do I need that properties ?
        [self setAllowsNonContiguousLayout:NO];
        [self setBackgroundLayoutEnabled:YES];
  */      
    }
    return self;
}


-(void)setTextStorage:(NSTextStorage *)textStorage {
    [super setTextStorage:textStorage];
    if (textStorage.string.length > 0)
        [self invalidatedLineSignatureForRange:NSMakeRange(0, textStorage.string.length)];
}

#pragma mark - Folding feature
- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
    
    QCCodeStorage *codeStorage = [self relatedCodeStorage];
    
    codeStorage.lineFoldingEnabled = YES;
    
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    
    codeStorage.lineFoldingEnabled = NO;
    
}

- (QCCodeStorage *) relatedCodeStorage {
    QCCodeStorage *codeStorage;
    
    NSTextStorage *textStorage = [self textStorage];
    if ([textStorage isKindOfClass:[QCCodeStorage class]]) {
        codeStorage = (QCCodeStorage *) textStorage;
    }
    return codeStorage;
}

// -textStorage:edited:range:changeInLength:invalidatedRange: delegate method invoked from NSTextStorage notifies layout managers whenever there was a modifications.  Based on the notification, NSLayoutManager invalidates cached internal information.  With normal circumstances, NSLayoutManager extends the invalidated range to nearest paragraph boundaries.  Since -[LineFoldingTypesetter actionForCharacterAtIndex:] might change the paragraph separator behavior, we need to make sure that the invalidation is covering the visible line range.
- (void)textStorage:(NSTextStorage *) textStorage
             edited:(NSTextStorageEditedOptions) editedMask
              range:(NSRange)newCharRange
     changeInLength:(NSInteger)delta
   invalidatedRange:(NSRange)invalidatedCharRange {
    
    NSUInteger length = [textStorage length];
    NSNumber *value;
    NSRange effectiveRange, range;
    
    // it's at the end. check if the last char is in lineFoldingAttributeName
    if ((invalidatedCharRange.location == length) && (invalidatedCharRange.location != 0)) {
        value = [textStorage attribute:QCCFoldedAttributeName atIndex:invalidatedCharRange.location - 1 effectiveRange:&effectiveRange];
        
        if (value && [value boolValue])
            invalidatedCharRange = NSUnionRange(invalidatedCharRange, effectiveRange);
    }
    
    if (invalidatedCharRange.location < length) {
        NSString *string = [textStorage string];
        NSUInteger start, end;
        
        if (delta > 0) {
            NSUInteger contentsEnd;
            
            [string getParagraphStart:NULL end:&end contentsEnd:&contentsEnd forRange:newCharRange];
            
            
            // there was para sep insertion. extend to both sides
            if ((contentsEnd != end) && (invalidatedCharRange.location > 0) && (NSMaxRange(newCharRange) == end)) {
                if (newCharRange.location <= invalidatedCharRange.location) {
                    invalidatedCharRange.length = (NSMaxRange(invalidatedCharRange) - (newCharRange.location - 1));
                    invalidatedCharRange.location = (newCharRange.location - 1);
                }
                
                if ((end < length) && (NSMaxRange(invalidatedCharRange) <= end)) {
                    invalidatedCharRange.length = ((end + 1) - invalidatedCharRange.location);
                }
            }
        }
        
        range = invalidatedCharRange;
        
        while ((range.location > 0) || (NSMaxRange(range) < length)) {
            [string getParagraphStart:&start end:&end contentsEnd:NULL forRange:range];
            range.location = start;
            range.length = (end - start);
            
            // Extend backward
            value = [textStorage attribute:QCCFoldedAttributeName
                                   atIndex:range.location
                     longestEffectiveRange:&effectiveRange
                                   inRange:NSMakeRange(0, range.location + 1)];
            
            if (value && [value boolValue] && (effectiveRange.location < range.location)) {
                range.length += (range.location - effectiveRange.location);
                range.location = effectiveRange.location;
            }
            
            // Extend forward
            if (NSMaxRange(range) < length) {
                value = [textStorage attribute:QCCFoldedAttributeName
                                       atIndex:NSMaxRange(range)
                         longestEffectiveRange:&effectiveRange
                                       inRange:NSMakeRange(NSMaxRange(range), length - NSMaxRange(range))];
                
                if (value && [value boolValue] && (NSMaxRange(effectiveRange) > NSMaxRange(range))) {
                    range.length = NSMaxRange(effectiveRange) - range.location;
                }
            }
            
            if (NSEqualRanges(range, invalidatedCharRange))
                break;
            
            invalidatedCharRange = range;
        }
    }
    
    [super textStorage:textStorage edited:editedMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
    
    if (editedMask & NSTextStorageEditedCharacters) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self invalidatedLineSignatureForRange:invalidatedCharRange];
        });
    }
}


#pragma Line Manager
- (NSArray *)lineSignatureArray {
    return _lineSignatureMutableArray;
}

- (void) addLineSignatureWithRect:(NSRect) rect forCharRange:(NSRange) range hasSoftBreak:(BOOL) hasSoftBreak {
    
    QCCLineSignature *lineSignature = [QCCLineSignature new];
    lineSignature.rect = rect;
    lineSignature.containsCharRange = range;
    lineSignature.hasSoftBreak = hasSoftBreak;
    lineSignature.countOfChars = range.length;
    [_lineSignatureMutableArray addObject:lineSignature];
    
}

- (void) invalidatedLineSignatures {
    [self invalidatedLineSignatureForRange:NSMakeRange(0, self.textStorage.string.length)];
}

#warning (NeedsBetterSolution) You have to check if we have update only that line or you have to remove all next lines.
- (void) invalidatedLineSignatureForRange:(NSRange) changedRange {
    /*
     NSUInteger firstEditedCharIndex = changedRange.location;
     
     for (QCCLineSignature *lineSignature in _lineSignatureMutableArray) {
     NSRange charRange = lineSignature.containsCharRange;
     NSUInteger lastCharIndexInLine = NSMaxRange(charRange);
     
     if (lastCharIndexInLine >= firstEditedCharIndex) {
     // if edited char befor or equal to last char in that line,
     // it is edited line.
     NSUInteger lineIndex = [_lineSignatureMutableArray indexOfObject:lineSignature];
     
     // Get that line and all line after and remove to make new line signatures for them.
     NSUInteger lastLineIndex = [_lineSignatureMutableArray count] - lineIndex;
     NSLog(@"count: %lu, lineIndex: %lu lastLineIndex:%lu", (unsigned long)[_lineSignatureMutableArray count] ,lineIndex, lastLineIndex);
     
     [_lineSignatureMutableArray removeObjectsInRange:NSMakeRange(lineIndex, lastLineIndex)];
     
     break;
     }
     }
     */
    
    NSRange lineRange;
    NSUInteger lineIndex = 0;
    NSUInteger numberOfGlyphs = [self numberOfGlyphs];
    NSUInteger lastCharIndex = self.textStorage.string.length -1;
    [_lineSignatureMutableArray removeAllObjects];
    
    for  (NSUInteger glyphIndex = 0; glyphIndex < numberOfGlyphs; lineIndex++){
        NSRect lineRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&lineRange];
        // Update index for next line
        glyphIndex = NSMaxRange(lineRange);
        NSUInteger lastCharIndexInLine = [self characterIndexForGlyphAtIndex:glyphIndex - 1];

        if (lastCharIndex > lastCharIndexInLine) {
            unichar lastCharInLine = [self.textStorage.string characterAtIndex:lastCharIndexInLine];
            [self addLineSignatureWithRect:lineRect forCharRange:lineRange hasSoftBreak:(lastCharInLine == QCCodeLayoutManagerSoftNewLineChar)];
    
        }else if (lastCharIndex == lastCharIndexInLine) {
            QCCLineSignature *previousLineSignature = [_lineSignatureMutableArray lastObject];
//            unichar lastCharInLine = [self.textStorage.string characterAtIndex:lastCharIndexInLine];
            [self addLineSignatureWithRect:lineRect forCharRange:lineRange hasSoftBreak:previousLineSignature.hasSoftBreak];
        }else {
            NSLog(@"ERROR%lu %lu", self.textStorage.string.length , lastCharIndexInLine);
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QCCLineSignatureUpdatedNotification object:self];
    
}

#pragma mark - LayoutManager
- (void)textContainerChangedGeometry:(NSTextContainer *)container {
    [super textContainerChangedGeometry:container];
    [self invalidatedLineSignatureForRange:NSMakeRange(0, self.textStorage.string.length)];
}


#pragma mark - Line Marker
-(NSColor *) colorForMarkerType:(QCCLineMarkerType) type alpha:(CGFloat) alpha {
    
    switch (type) {
        case QCCLineMarkerTypeNULL:
            return nil;
            
        case QCCLineMarkerTypeNote:
            return [NSColor colorWithCalibratedRed:0.60f green:0.80f blue:0.99f alpha:alpha];
            
        case QCCLineMarkerTypeIgnored:
            return [NSColor colorWithCalibratedRed:1.00f green:1.00f blue:0.99f alpha:alpha];
            
        case QCCLineMarkerTypeWarning:
            return [NSColor colorWithCalibratedRed:0.99f green:0.95f blue:0.60f alpha:alpha];
            
        case QCCLineMarkerTypeError:
            return [NSColor colorWithCalibratedRed:0.99f green:0.40f blue:0.10f alpha:alpha];
            
        case QCCLineMarkerTypeFatal:
            return [NSColor colorWithCalibratedRed:0.99f green:0.40f blue:0.10f alpha:alpha];
    }
    
    return nil;
}

- (NSDictionary *) markerMessageAttributes {
    
    if (_markerMessageAttributes)
        return _markerMessageAttributes;
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSLeftTextAlignment;
    
    NSColor *numberColor = [NSColor blackColor];
    
    _markerMessageAttributes = @{NSFontAttributeName:[NSFont systemFontOfSize:10.0],
                                 NSForegroundColorAttributeName:numberColor,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return _markerMessageAttributes;
}

- (NSBezierPath *) wavyLinePathForRect:(CGRect) lineRect {

    NSRect rect = truncNSRect(lineRect);
    rect.size.height = QCCLineMarkerWavyLineHeight;
    rect.origin.y = truncCGFloat(CGRectGetMaxY(lineRect)) - rect.size.height;
    
    NSBezierPath *linePath = [NSBezierPath bezierPath];
    [linePath moveToPoint:NSMakePoint(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    
    CGFloat lineLenght = CGRectGetMinX(rect);
    BOOL maxPeak = NO;
    while (lineLenght < CGRectGetMaxX(rect)) {
        lineLenght += QCCLineMarkerWavyLineStep;

        [linePath lineToPoint:NSMakePoint(lineLenght, (maxPeak ? CGRectGetMinY(rect) : CGRectGetMaxY(rect)))];
        maxPeak = !maxPeak;
    }
    
    return linePath;

}

#pragma mark - Drawing Background
-(void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
    
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    
    QCCodeStorage *codeStorage = [self relatedCodeStorage];
    
    
    NSUInteger countOfVisibleMarkers = 10;
    
    
    NSUInteger count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeFatal]
                                  asType:QCCLineMarkerTypeFatal
                    forVisibleGlyphRange:glyphsToShow
                                 atPoint:origin];
    countOfVisibleMarkers -= count;

    if (countOfVisibleMarkers == 0)
        return;

    
    count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeFatal]
                       asType:QCCLineMarkerTypeFatal
         forVisibleGlyphRange:glyphsToShow
                      atPoint:origin];
    
    if (countOfVisibleMarkers == 0)
        return;
    
    count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeError]
                       asType:QCCLineMarkerTypeError
         forVisibleGlyphRange:glyphsToShow
                      atPoint:origin];
    
    if (countOfVisibleMarkers == 0)
        return;
    
    count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeWarning]
                       asType:QCCLineMarkerTypeWarning
         forVisibleGlyphRange:glyphsToShow
                      atPoint:origin];
    
    if (countOfVisibleMarkers == 0)
        return;
    
    count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeNote]
                       asType:QCCLineMarkerTypeNote
         forVisibleGlyphRange:glyphsToShow
                      atPoint:origin];
    
    if (countOfVisibleMarkers == 0)
        return;
    
    count = [self drawMarkers:[codeStorage markersForType:QCCLineMarkerTypeFatal]
                       asType:QCCLineMarkerTypeFatal
         forVisibleGlyphRange:glyphsToShow
                      atPoint:origin];
    
    
}

- (NSUInteger) drawMarkers:(NSArray *) markers asType:(QCCLineMarkerType) type forVisibleGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin{
    NSUInteger countOfVisibleMarkers = 0;
    
    for (NSDictionary *container in markers) {
        NSValue *rangeAsKey = [[container allKeys] firstObject];
        NSString *message = container[rangeAsKey];
        NSRange range = [rangeAsKey rangeValue];
        
        
        NSUInteger glyphIndex = [self glyphIndexForCharacterAtIndex:range.location];
        if (!NSLocationInRange(glyphIndex, glyphsToShow))
            continue;
    
        
        [self drawMarkerForType:type forRange:range withMessage:message atPoint:origin];
        
        countOfVisibleMarkers++;
    }
    
    return countOfVisibleMarkers;
}


- (void) drawMarkerForType:(QCCLineMarkerType) type forRange:(NSRange) range withMessage:(NSString *) message atPoint:(NSPoint)origin {
    
    [[self colorForMarkerType:type alpha:QCCLineMarkerBackgroundAlphaValue] setFill];
    
    NSUInteger glyphIndex = [self glyphIndexForCharacterAtIndex:range.location];
    
    NSRange lineGlyphRange;
    
    NSRect backgroundRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&lineGlyphRange];
    
    NSRect visibleLineRect = [self boundingRectForGlyphRange:NSMakeRange(lineGlyphRange.location, lineGlyphRange.length - 1) inTextContainer:[self.textContainers firstObject]];
    
    NSRect lineRect = CGRectOffset(backgroundRect, origin.x, origin.y);
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    CGFloat radius = lineRect.size.height / 4;
    [bezierPath appendBezierPathWithRoundedRect:lineRect xRadius:radius yRadius:radius];
    [bezierPath fill];
    
    NSRect sliceRect;
    NSRect remainderRect;
    
    CGRectDivide(lineRect, &sliceRect, &remainderRect, visibleLineRect.size.width + QCCLineMarkerMessageLeftPadding, CGRectMinXEdge);
    
    [[self colorForMarkerType:type alpha:QCCLineMarkerMessageAlphaValue] setFill];
    
    NSBezierPath *messageBezierPath = [NSBezierPath bezierPath];
    [messageBezierPath appendBezierPathWithOvalInRect:NSMakeRect(remainderRect.origin.x, remainderRect.origin.y, QCCLineMarkerMessageArrowWidth, remainderRect.size.height)];
    [messageBezierPath appendBezierPathWithRect:CGRectOffset(remainderRect, QCCLineMarkerMessageArrowWidth / 2, 0)];
    [messageBezierPath fill];
    
    [message drawInRect:CGRectOffset(remainderRect, QCCLineMarkerMessageLeftPadding, 0) withAttributes:[self markerMessageAttributes]];
    
//    NSSize messageSize = [message sizeWithAttributes:[self markerMessageAttributes]];
    
    if (range.length < 3 || range.length > 20 || range.length == 0)
        return;

    NSRange markerGlyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    NSRect markerRect = [self boundingRectForGlyphRange:markerGlyphRange inTextContainer:[[self textContainers]firstObject]];
    
    
    [[NSColor redColor] setStroke];
    NSBezierPath * line = [self wavyLinePathForRect:CGRectOffset(markerRect, origin.x, origin.y)];
    [line stroke];

    
    

}

@end
