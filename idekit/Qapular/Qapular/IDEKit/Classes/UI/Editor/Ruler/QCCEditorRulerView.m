//
//  QCCEditorRulerView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCEditorRulerView.h"
#import "QCCodeView.h"
#import "QCCThemaManager.h"
#import "QCCodeLayoutManager.h"
#import "QCCodeStorage.h"

#import "QCCGeometry.h"
#import "QCCodeRepresentation.h"
#import "QCCBracketMachine.h"


@interface QCCEditorRulerView() {

    QCCodeView          *_codeView;
    QCCThemaManager     *_themaManager;
    NSFont              *_lineNumberingFont;
    
    NSColor *_lineNumberColor;
    NSColor *_caretBorderColor;
    NSColor *_caretBackgroundColor;
    NSColor *_borderColor;
    NSColor *_backgroundColor;
    
    NSDictionary        *_lineNumberingAttributes;
    NSMutableArray      *_bracketPairs;
    
    NSRect              _selectedBracketsRect;
    NSTrackingRectTag   _trackingRectTag;
}



@end


@implementation QCCEditorRulerView

const static CGFloat QCCEditorRulerLineNumberingPadding = 2.0f;
const static CGFloat QCCEditorRulerLineNumberingMultiplicator = 3.0f;
const static CGFloat QCCEditorRulerBracketsViewPadding = 3.0f;
const static CGFloat QCCEditorRulerBracketsViewBorderWidth = 1.0;
const static CGFloat QCCEditorRulerBracketsViewWidth = 7.0;
const static CGFloat QCCEditorRulerBorderWidth = 1.0;
const static CGFloat QCCEditorRulerLongLineMarkerMultiplicator = 0.8333f;
const static CGFloat QCCEditorRulerBracketMarkerWidth = 1.0;

static NSString *const QCCEditorRulerOpenMarkerBackgroundRectKey = @"QCCEditorRulerOpenMarkerBackgroundRect";
static NSString *const QCCEditorRulerClosedMarkerBackgroundRectKey = @"QCCEditorRulerClosedMarkerBackgroundRect";
static NSString *const QCCEditorRulerMarkerRectKey = @"QCCEditorRulerMarkerRect";
static NSString *const QCCEditorRulerOpenMarkerRectKey = @"QCCEditorRulerOpenMarkerRect";
static NSString *const QCCEditorRulerVerticalMarkerRectKey = @"QCCEditorRulerVerticalMarkerRect";
static NSString *const QCCEditorRulerClosedMarkerRectKey = @"QCCEditorRulerClosedMarkerRect";


#pragma mark - Init
- (instancetype)initWithScrollView:(NSScrollView *)scrollView forCodeView:(QCCodeView *)codeView andThemaManager:(QCCThemaManager *)themaManager{
    
    self = [super initWithScrollView:scrollView orientation:NSVerticalRuler];
    if (self){
        _codeView = codeView;
        _themaManager = themaManager;
        CGFloat fontSize = [_themaManager fontSizeForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
        _lineNumberingFont = [_themaManager rulerFontWithSize:fontSize];

        [self setRuleThickness:[self requiredThickness]];
        
        [self subscribe];
        
        self.layer.drawsAsynchronously = YES;

    }

    return  self;
}


- (void) updateTrackingAreas {

    [self removeTrackingRect:_trackingRectTag];
    CGFloat borderViewOriginX = QCCEditorRulerLineNumberingPadding + [self lineNumberingWidth] + QCCEditorRulerBracketsViewPadding;
    NSRect rect = NSMakeRect(borderViewOriginX, 0, QCCEditorRulerBracketsViewWidth + QCCEditorRulerBracketsViewBorderWidth, self.bounds.size.height);
    _trackingRectTag = [self addTrackingRect:rect
                                       owner:self
                                    userData:NULL
                                assumeInside:NO];
}

- (void) subscribe {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsUpdateRuller:)
                                                 name:QCCLineSignatureUpdatedNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsUpdateRuller:)
                                                 name:NSTextStorageDidProcessEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsUpdateRuller:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themaReplaced)
                                                 name:QCCThemaManagerReplacedNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsUpdateBracketsForNotification:)
                                                 name:QCCBracketMachineUpdatedNotification
                                               object:nil];
}

- (void) unsubscribe {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) themaReplaced {
    
    _lineNumberColor = nil;
    _caretBorderColor = nil;
    _caretBackgroundColor = nil;
    _borderColor = nil;
    _backgroundColor = nil;
    _lineNumberingAttributes = nil;
    
    CGFloat fontSize = [_themaManager fontSizeForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    _lineNumberingFont = [_themaManager rulerFontWithSize:fontSize];

    [self setNeedsDisplay:YES];
}

#pragma mark - Brackets
- (void) needsUpdateBracketsForNotification:(NSNotification *) notification {
    if (notification.object == _codeView.codeStorage)
        _bracketPairs = nil;
}

- (NSArray *) bracketPairs {

    if (!_bracketPairs) {
        
        _bracketPairs = [NSMutableArray new];
        
        NSArray * bracketPairs = [_codeView.codeRepresentation bracketPairs];
        CGFloat borderViewOriginX = QCCEditorRulerLineNumberingPadding + [self lineNumberingWidth] + QCCEditorRulerBracketsViewPadding + QCCEditorRulerBorderWidth;
        CGFloat borderViewCenterX = truncCGFloat(borderViewOriginX + QCCEditorRulerBracketsViewWidth / 2);

        for (NSDictionary *pair in bracketPairs) {
            
            // Background
            NSRect openBracketRect = [pair[QCCEditorRulerOpenBracketRectKey] rectValue];
            CGFloat openBracketOriginY = truncCGFloat(openBracketRect.origin.y);
            CGFloat openBracketSizeHeight = openBracketRect.size.height;
            
            NSRect closedBracketRect = [pair[QCCEditorRulerClosedBracketRectKey] rectValue];
            CGFloat closedBracketOriginY = truncCGFloat(closedBracketRect.origin.y);
            CGFloat closedBracketSizeHeight = closedBracketRect.size.height;
            
            
            CGRect openMarkerBackgroundRect = NSMakeRect(borderViewCenterX, openBracketOriginY, QCCEditorRulerBracketMarkerWidth, openBracketSizeHeight);
            CGRect closedMarkerBackgroundRect = NSMakeRect(borderViewCenterX, closedBracketOriginY,QCCEditorRulerBracketMarkerWidth, closedBracketSizeHeight);
            
            //Lines
            CGRect openMarkerRect = NSMakeRect(borderViewOriginX,
                                               truncCGFloat(openBracketOriginY + openBracketSizeHeight / 2),
                                               QCCEditorRulerBracketsViewWidth,
                                               QCCEditorRulerBracketMarkerWidth);
            
            CGRect closedMarkerRect = NSMakeRect(borderViewOriginX,
                                                 truncCGFloat(closedBracketOriginY + closedBracketSizeHeight / 2),
                                                 QCCEditorRulerBracketsViewWidth,
                                                 QCCEditorRulerBracketMarkerWidth);
            
            
            CGRect verticalMarkerRect = NSMakeRect(borderViewCenterX, CGRectGetMinY(openMarkerRect), QCCEditorRulerBracketMarkerWidth, CGRectGetMaxY(closedMarkerRect) - CGRectGetMinY(openMarkerRect));
            CGRect markerRect = NSMakeRect(borderViewOriginX, CGRectGetMinY(openMarkerRect), QCCEditorRulerBracketsViewWidth, CGRectGetMaxY(closedMarkerRect) - CGRectGetMinY(openMarkerRect));
            
            
            NSMutableDictionary *ruletPairDictionary = [[NSMutableDictionary alloc] initWithDictionary:pair];
            [ruletPairDictionary setObject:[NSValue valueWithRect:openMarkerRect] forKey:QCCEditorRulerOpenMarkerRectKey];
            [ruletPairDictionary setObject:[NSValue valueWithRect:closedMarkerRect] forKey:QCCEditorRulerClosedMarkerRectKey];
            [ruletPairDictionary setObject:[NSValue valueWithRect:markerRect] forKey:QCCEditorRulerMarkerRectKey];
            
            [ruletPairDictionary setObject:[NSValue valueWithRect:verticalMarkerRect] forKey:QCCEditorRulerVerticalMarkerRectKey];
            
            [ruletPairDictionary setObject:[NSValue valueWithRect:openMarkerBackgroundRect] forKey:QCCEditorRulerOpenMarkerBackgroundRectKey];
            [ruletPairDictionary setObject:[NSValue valueWithRect:closedMarkerBackgroundRect] forKey:QCCEditorRulerClosedMarkerBackgroundRectKey];
            
            [_bracketPairs addObject:ruletPairDictionary];
            
        }

    }

    return _bracketPairs;
}




#pragma mark - Editing event
- (void) needsUpdateRuller:(NSNotification *) notification {
    if ([notification.name isEqualToString:QCCLineSignatureUpdatedNotification] && (notification.object != _codeView.codeLayoutManager))
        return;
    
    [self setNeedsDisplay:YES];
}
#pragma mark - Ruler geometry

- (CGFloat) baselineLocation {
    NSLog(@"error:%s", __FUNCTION__);
    return 0;
}
// Returns the location of the baseline.  The location is a y position for horizontal rulers and an x position for vertical ones.  The value is based on the sizes of the various areas of the ruler, some of which can be set below.

- (CGFloat) requiredThickness {
    return  QCCEditorRulerLineNumberingPadding + [self lineNumberingWidth] + QCCEditorRulerBracketsViewPadding + QCCEditorRulerBracketsViewBorderWidth + QCCEditorRulerBracketsViewWidth + QCCEditorRulerBorderWidth;
}

- (CGFloat) reservedThicknessForMarkers {
    NSLog(@"error:%s", __FUNCTION__);
    return 0;
}

- (CGFloat) reservedThicknessForAccessoryView {
        NSLog(@"error:%s", __FUNCTION__);
    return 0;
}

- (CGFloat) lineNumberingWidth {
    return roundCGFloat([_codeView.codeStorage defaultCharSize].width * QCCEditorRulerLineNumberingMultiplicator);
}


#pragma mark - Drawing
- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect {
    CGRect visibleRect = [[[self scrollView] contentView] bounds];
    CGFloat scrollOffset = visibleRect.origin.y;
    CGFloat scrollOffsetWithCodeViewInset = visibleRect.origin.y - QCCodeViewInset.height;
    

    
    // Main background
    [self drawBackgroundInRect:aRect];
    
    //Bracket view borders
    [self drawBracketViewBordersInRect:aRect];
    
    // Draw caret marker
    [self drawCaretWithScrollOffset:scrollOffsetWithCodeViewInset];
    
    // Line numbers
    [self drawLineNumbersOnVisibleRect:visibleRect];

    [self drawBracketViewWithOffset:scrollOffset];


}


#pragma mark Background
- (void) drawBackgroundInRect:(NSRect)aRect {
    [[self backgroundColor] setFill];
    NSRectFill(aRect);
}


#pragma mark Caret
- (void) drawCaretWithScrollOffset:(CGFloat) scrollOffsetWithCodeViewInset {
    QCCodeLayoutManager *layoutManager = [_codeView codeLayoutManager];
    
    NSRange selectedCharacterRange = [[_codeView.selectedRanges firstObject] rangeValue];
    NSRect selectedGlyphRect = [layoutManager boundingRectForGlyphRange:selectedCharacterRange inTextContainer:_codeView.textContainer];
    
    NSRect caretRect = NSMakeRect(0,
                                  truncCGFloat(selectedGlyphRect.origin.y - scrollOffsetWithCodeViewInset),
                                  [self requiredThickness],
                                  truncCGFloat(selectedGlyphRect.size.height));
    
    
    NSBezierPath* caretBackgroundBezierPath = [NSBezierPath bezierPath];
    [caretBackgroundBezierPath appendBezierPathWithRect:caretRect];
    [[self caretBackgroundColor] setFill];
    [caretBackgroundBezierPath fill];
    
    NSRect caretHeaderBorderRect = NSMakeRect(0, CGRectGetMinY(caretRect), [self requiredThickness], 1);
    NSRect caretFooterBorderRect = NSMakeRect(0, CGRectGetMaxY(caretRect), [self requiredThickness], 1);;
    
    NSBezierPath* caretBorderBezierPath = [NSBezierPath bezierPath];
    [caretBorderBezierPath appendBezierPathWithRect:caretHeaderBorderRect];
    [caretBorderBezierPath appendBezierPathWithRect:caretFooterBorderRect];
    [[self caretBorderColor] setFill];
    [caretBorderBezierPath fill];
}


#pragma mark Line numbering
- (void) drawLineNumbersOnVisibleRect:(CGRect) visibleRect {
    // Draw line numbers
    if (!_shouldShowLineNumber)
        return;
    
    QCCodeLayoutManager *layoutManager = [_codeView codeLayoutManager];
    CGFloat scrollOffsetWithCodeViewInset = visibleRect.origin.y - QCCodeViewInset.height;

    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    
    // First line number is 1
    NSUInteger lineNumber = 1;
    
    BOOL previousLineHasSoftBreak = YES;
    for (QCCLineSignature *lineSignature in layoutManager.lineSignatureArray) {
        BOOL doNotShowLine = NO;
        
        // Looking for diagnostic
        for (NSValue *rangeNSValue in [_codeView.codeStorage markerSortedKeys]) {
            NSRange range = [rangeNSValue rangeValue];
            if (NSLocationInRange(range.location, lineSignature.containsCharRange)) {
                doNotShowLine = YES;
            }
        }
        
        
        // Check. should I render that part of view:
        CGPoint topLeftLinePoint = CGPointMake(0, CGRectGetMinY(lineSignature.rect) - lineSignature.rect.size.height / 2 );
        CGPoint rightButtomLinePoint = CGPointMake(0, CGRectGetMaxY(lineSignature.rect) + lineSignature.rect.size.height / 2);
        
        if (CGRectContainsPoint(visibleRect, topLeftLinePoint) || CGRectContainsPoint(visibleRect, rightButtomLinePoint)){
            NSString *lineNumberString = [NSString stringWithFormat:@"%lu", (unsigned long)lineNumber];
            
            NSRect numberRect = NSMakeRect(QCCEditorRulerLineNumberingPadding,
                                           lineSignature.rect.origin.y - scrollOffsetWithCodeViewInset,
                                           [self lineNumberingWidth],
                                           lineSignature.rect.size.height);
            
            if (previousLineHasSoftBreak) {
#warning (NeedsBetterSolution) [NSString drawInRect] is havi for CPU & GPU so we will need to cache numbers as image buffer pixels. 
                if (!doNotShowLine)
                [lineNumberString drawInRect:numberRect withAttributes:[self lineNumberingAttributes]];
                else {
                    [[NSColor yellowColor] setFill];
                    [[NSColor brownColor] setStroke];
                    
                    NSRect buttonRect = NSMakeRect(numberRect.origin.x + 3, numberRect.origin.y + 3 , 9, 9);
                    NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRoundedRect:buttonRect xRadius:2 yRadius:2];
                    [buttonPath stroke];
                    [buttonPath fill];
                    
                    [[NSColor whiteColor] setFill];
                    NSBezierPath *buttonImagePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(buttonRect, 3, 3)  xRadius:0 yRadius:0];
                    [buttonImagePath stroke];
                    [buttonImagePath fill];
                }
                
                lineNumber++;
                
            }else {
                [circlePath appendBezierPathWithOvalInRect:NSMakeRect( QCCEditorRulerLineNumberingPadding + ( QCCEditorRulerLongLineMarkerMultiplicator * [self lineNumberingWidth]),
                                                                      lineSignature.rect.origin.y - scrollOffsetWithCodeViewInset + lineSignature.rect.size.height / 2,
                                                                      2,
                                                                      2)];
            }
            
        }else {
            if (previousLineHasSoftBreak)
                lineNumber++;
        }
        
        previousLineHasSoftBreak = lineSignature.hasSoftBreak;
    }
    
    [[self lineNumberColor] setStroke];
    [circlePath stroke];
}

#pragma mark Bracket view
- (void) drawBracketViewBordersInRect:(NSRect)aRect {
    // Border for bracket view
    NSBezierPath* borderBezierPath = [NSBezierPath bezierPath];
    
    CGFloat borderViewOriginX = QCCEditorRulerLineNumberingPadding + [self lineNumberingWidth] + QCCEditorRulerBracketsViewPadding;
    
    NSRect leftBorderRect = NSMakeRect(borderViewOriginX,
                                       0,
                                       QCCEditorRulerBracketsViewBorderWidth,
                                       aRect.size.height);
    
    NSRect rightBorderRect = NSMakeRect(borderViewOriginX + QCCEditorRulerBracketsViewWidth + QCCEditorRulerBracketsViewBorderWidth,
                                        0,
                                        QCCEditorRulerBracketsViewBorderWidth,
                                        aRect.size.height);
    
    [borderBezierPath appendBezierPathWithRect:leftBorderRect];
    [borderBezierPath appendBezierPathWithRect:rightBorderRect];
    [[self borderColor] setFill];
    [borderBezierPath fill];

}


- (void) drawBracketViewWithOffset:(CGFloat) scrollOffset {

    
    for (NSDictionary *pair in [self bracketPairs]) {
        
        NSBezierPath* bracketMarkerBackgroundBezierPath = [NSBezierPath bezierPath];
        NSBezierPath* bracketMarkerBezierPath = [NSBezierPath bezierPath];

        CGRect openMarkerBackgroundRect = [pair[QCCEditorRulerOpenMarkerBackgroundRectKey] rectValue];
        CGRect closedMarkerBackgroundRect = [pair[QCCEditorRulerClosedMarkerBackgroundRectKey] rectValue];

        CGRect openMarkerRect = [pair[QCCEditorRulerOpenMarkerRectKey] rectValue];
        CGRect verticalMarkerRect = [pair[QCCEditorRulerVerticalMarkerRectKey] rectValue];
        CGRect closedMarkerRect = [pair[QCCEditorRulerClosedMarkerRectKey] rectValue];

        [bracketMarkerBackgroundBezierPath appendBezierPathWithRect:CGRectOffset(openMarkerBackgroundRect, 0, -scrollOffset)];
        [bracketMarkerBackgroundBezierPath appendBezierPathWithRect:CGRectOffset(closedMarkerBackgroundRect, 0, -scrollOffset)];

        [bracketMarkerBezierPath appendBezierPathWithRect:CGRectOffset(openMarkerRect, 0, -scrollOffset)];
        [bracketMarkerBezierPath appendBezierPathWithRect:CGRectOffset(verticalMarkerRect, 0, -scrollOffset)];
        [bracketMarkerBezierPath appendBezierPathWithRect:CGRectOffset(closedMarkerRect, 0, -scrollOffset)];
        
        [[self backgroundColor] setFill];
        [bracketMarkerBackgroundBezierPath fill];
        
        [[self lineNumberColor] setFill];
        [bracketMarkerBezierPath fill];
        
    }
}

#pragma mark - Appearance
- (NSDictionary *) lineNumberingAttributes {
    
    if (_lineNumberingAttributes)
        return _lineNumberingAttributes;
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSRightTextAlignment;
    
    NSColor *numberColor = [self lineNumberColor];
    
    _lineNumberingAttributes = @{NSFontAttributeName:_lineNumberingFont,
                                 NSForegroundColorAttributeName:numberColor,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return _lineNumberingAttributes;
}

#pragma mark Colors
- (NSColor *) backgroundColor {
    
    if (!_backgroundColor)
        _backgroundColor = [_themaManager rulerBackgroundColor];
    return _backgroundColor;
}

- (NSColor *) borderColor {
    if (!_borderColor)
        _borderColor = [_themaManager rulerBorderColor];
    return _borderColor;
}
- (NSColor *) caretBackgroundColor {
    if (!_caretBackgroundColor)
        _caretBackgroundColor = [_themaManager rulerCaretBackgroundColor];
    
    return _caretBackgroundColor;
}
- (NSColor *) caretBorderColor {
    
    if (!_caretBorderColor)
        _caretBorderColor =  [_themaManager rulerCaretBorderColor];
    return _caretBorderColor;
}
- (NSColor *) lineNumberColor {
    if (!_lineNumberColor)
        _lineNumberColor = [_themaManager rulerLineNumberColor];
    return _lineNumberColor;
}



#pragma mark - Mouse interection
- (void)mouseEntered:(NSEvent *)theEvent{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
    
    /*
     NSPoint event_location = [theEvent locationInWindow];
     NSPoint local_point = [self convertPoint:event_location fromView:nil];
     [self bracketPairs];
     NSLog(@"mouseEntered: %@", NSStringFromPoint(local_point));
     */
}

- (void)mouseExited:(NSEvent *)theEvent{
    [[self window] setAcceptsMouseMovedEvents:NO];
    [[self window] makeFirstResponder:_codeView];
    
    /*
     NSPoint event_location = [theEvent locationInWindow];
     NSPoint local_point = [self convertPoint:event_location fromView:nil];
     
     NSLog(@"mouseExited: %@", NSStringFromPoint(local_point));
     */
}
-(void)mouseDown:(NSEvent *)theEvent {
    [_codeView showPopoverForFixIts:nil];
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    

    NSDictionary *selectedPair = [self bracketsSignatureForLocation:local_point];
    if (!selectedPair)
        return;
    
    NSUInteger openBracketIndex = [selectedPair[QCCEditorRulerOpenBracketIndexKey] integerValue];
    NSUInteger closedBracketIndex = [selectedPair[QCCEditorRulerClosedBracketIndexKey] integerValue];
    
    NSRange foldingRange = NSMakeRange(openBracketIndex + 1 , closedBracketIndex - openBracketIndex - 1 );
    [_codeView showFindIndicatorForRange:foldingRange];
    [_codeView.codeStorage foldInRange:foldingRange];
    
}



- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];

   NSDictionary *selectedPair = [self bracketsSignatureForLocation:local_point];
    
    if (selectedPair) {
        CGRect selectedBracketsRect = [selectedPair[QCCEditorRulerMarkerRectKey] rectValue];

        if (NSEqualRects(_selectedBracketsRect, selectedBracketsRect)) {
            return;
        }        
        
        NSUInteger openBracketIndex = [selectedPair[QCCEditorRulerOpenBracketIndexKey] integerValue];
        NSUInteger closedBracketIndex = [selectedPair[QCCEditorRulerClosedBracketIndexKey] integerValue];
        
        [_codeView showFindIndicatorForRange:NSMakeRange(openBracketIndex , 1)];
        [_codeView showFindIndicatorForRange:NSMakeRange(closedBracketIndex , 1)];
    
        _selectedBracketsRect = selectedBracketsRect;
    }else {
        _selectedBracketsRect = NSZeroRect;
    }
    
    
}

- (NSDictionary *) bracketsSignatureForLocation:(NSPoint) point {

    CGRect visibleRect = [[[self scrollView] contentView] bounds];
    CGFloat scrollOffset = visibleRect.origin.y;
    
    NSDictionary *selectedPair;
    
    for (NSDictionary *pair in [self bracketPairs]) {
        
        CGRect markerRect = [pair[QCCEditorRulerMarkerRectKey] rectValue];
        CGRect markerRectWithOffset = CGRectOffset(markerRect, 0, -scrollOffset);
        // get latest in order
        if (CGRectContainsPoint(markerRectWithOffset, point)) {
            selectedPair = [[NSDictionary alloc] initWithDictionary:pair];
        }
    }
    // return latest element
    return selectedPair;
}



#pragma mark - Settings
-(void)setShouldShowLineNumber:(BOOL)shouldShowLineNumber {

    _shouldShowLineNumber = shouldShowLineNumber;
    [self setNeedsDisplay:YES];
}


-(void)dealloc {
    [self unsubscribe];
    NSLog(@"Dealloc: %@", [[NSThread callStackSymbols] firstObject]);
}


@end
