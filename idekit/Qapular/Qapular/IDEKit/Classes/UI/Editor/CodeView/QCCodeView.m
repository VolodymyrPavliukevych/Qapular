//
//  QCCodeView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeView.h"
#import "QCCThemaManager.h"
#import "QCCodeLayoutManager.h"
#import "QCCodeContainer.h"
#import "QCCodeStorage.h"
#import "QCCodeRepresentation.h"
#import "QCCInterectionController.h"
#import "QCCFixItViewController.h"
#import <QCCodeFormatKit/QCCodeFormatKit.h>

@interface QCCodeView () <NSTextViewDelegate> {
    
    QCCThemaManager         *_themaManager;
    QCCodeLayoutManager     *_codeLayoutManager;
    QCCodeContainer         *_codeContainer;
    QCCodeStorage           *_codeStorage;
    
    QCCInterectionController    *_interectionController;
    NSPopover                   *_fixItPopover;
}


@end

@implementation QCCodeView

const NSSize    QCCodeViewInset = {5, 10};
const CGFloat   QCCodeViewWrapColumnBorderSize  = 1.0f;

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setContinuousSpellCheckingEnabled:NO];
        [self setGrammarCheckingEnabled:NO];
        [self setAutomaticSpellingCorrectionEnabled:NO];
        [self setAutomaticTextReplacementEnabled:NO];
        
        _fixItPopover = [[NSPopover alloc] init];
    
        _fixItPopover.appearance = [NSAppearance appearanceNamed:[_themaManager appearanceName]];
        _fixItPopover.animates = YES;
        
        _interectionController = [[QCCInterectionController alloc] initWithCodeView:self];


        [self setDelegate:_interectionController];
        _codeRepresentation = [[QCCodeRepresentation alloc] initForCodeView:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themaReplaced)
                                                     name:QCCThemaManagerReplacedNotification
                                                   object:nil];
        
    }
    
    return self;
}

- (void) themaReplaced {
    self.backgroundColor = [_themaManager colorForKey:SourceTextBackgroundKey];
    self.insertionPointColor = [_themaManager colorForKey:SourceTextInsertionPointColorKey];
    
    NSColor *selectionColor = [_themaManager colorForKey:SourceTextSelectionColorKey];
    if (selectionColor)
        self.selectedTextAttributes = @{NSBackgroundColorAttributeName:selectionColor  /*, NSForegroundColorAttributeName: [NSColor purpleColor]*/};
    
    self.typingAttributes = [_codeStorage defaultCodeSyntaxAttributes];
    _fixItPopover.appearance = [NSAppearance appearanceNamed:[_themaManager appearanceName]];
}

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [super awakeAfterUsingCoder:aDecoder];
}

-(void)awakeFromNib {
    
}

-(BOOL)mouseDownCanMoveWindow {
    return NO;
}

- (void) loadCodeViewWithCodeStorage:(QCCodeStorage *) codeStorage {

    _codeLayoutManager = [[QCCodeLayoutManager alloc] init];
    _codeContainer = [[QCCodeContainer alloc] init];
    
    [self replaceTextContainer:_codeContainer];
    [_codeContainer replaceLayoutManager:_codeLayoutManager];
    [codeStorage addLayoutManager:_codeLayoutManager];
    
    [self setTextContainerInset:QCCodeViewInset];
    self.typingAttributes = [_codeStorage defaultCodeSyntaxAttributes];

    self.automaticQuoteSubstitutionEnabled = NO;
    self.enabledTextCheckingTypes = 0;
}

-(void)setThemaManager:(QCCThemaManager *)themaManager {
    _themaManager = themaManager;
    [self themaReplaced];
}

- (void) replaceCodeStorage:(QCCodeStorage *)codeStorage {
    _codeStorage = codeStorage;
    if (_codeStorage)
        [self loadCodeViewWithCodeStorage:_codeStorage];

}


- (void)toggleRuler:(id)sender {
    // do not show ruler.
}

#pragma mark QCCodeLayoutManager
- (QCCodeLayoutManager *) codeLayoutManager {
    return _codeLayoutManager;    
}


- (void) setWrapingColumnWidht:(CGFloat)wrapingColumnWidht {
    _wrapingColumnWidht = (int) roundf(wrapingColumnWidht);
    [_codeContainer setContainerSize:CGSizeMake(wrapingColumnWidht, MAXFLOAT)];
    [self setNeedsDisplay:YES];
}
#pragma mark - Draw

/*
-(void)drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color turnedOn:(BOOL)flag {
    [super drawInsertionPointInRect:rect color:color turnedOn:flag];
}
*/

-(void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    /*
    NSArray * bracketPairs = [_codeRepresentation bracketPairs];

    NSArray *colors = @[[NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor cyanColor], [NSColor yellowColor], [NSColor magentaColor], [NSColor orangeColor], [NSColor purpleColor], [NSColor brownColor], [NSColor clearColor]];
    
    
    
    NSUInteger index = 0;
    for(NSDictionary *container in bracketPairs) {
    
        NSColor *bracketPairColor = [colors objectAtIndex:index];
        if (index >8)
            index=0;
        index++;
        
        NSBezierPath* editedBezierPath = [NSBezierPath bezierPath];
        [editedBezierPath appendBezierPathWithRect:[container[QCCEditorRulerOpenBracketRectKey] rectValue]];
        [editedBezierPath appendBezierPathWithRect:[container[QCCEditorRulerClosedBracketRectKey] rectValue]];

        [bracketPairColor setStroke];
        [editedBezierPath stroke];
    }
     */
    
    /*
     NSBezierPath* editedBezierPath = [NSBezierPath bezierPath];
     [editedBezierPath appendBezierPathWithRect:rect];
     [[NSColor redColor] setStroke];
     [editedBezierPath stroke];
    */
    
    NSRect waterlineBacgroundRect = NSMakeRect(_wrapingColumnWidht, rect.origin.y, self.bounds.size.width - _wrapingColumnWidht, rect.size.height);
    [[_themaManager waterlineBackgroundColor] setFill];
    NSRectFill(waterlineBacgroundRect);


    // Border for bracket view
    NSBezierPath* borderBezierPath = [NSBezierPath bezierPath];
    NSRect bracketsViewBorderRect = NSMakeRect(_wrapingColumnWidht,
                                               rect.origin.y,
                                               QCCodeViewWrapColumnBorderSize,
                                               rect.size.height);

    
    [borderBezierPath appendBezierPathWithRect:bracketsViewBorderRect];
    [[_themaManager rulerBorderColor] setFill];
    [borderBezierPath fill];
    
}

#pragma mark - Events
-(void)mouseDown:(NSEvent *)theEvent {
    if (![_interectionController mouseDownInterception:theEvent]) {
        [super mouseDown:theEvent];
    }
    
     
}

#pragma mark - Copy \ Paste events
- (void) paste:(id)sender {
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = @[[NSMutableAttributedString class], [NSAttributedString class], [NSString class]];
    NSDictionary *options = @{};
    
    BOOL canRead = [pasteboard canReadObjectForClasses:classArray options:options];
    if (canRead) {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        for (id pasteObject in objectsToPaste) {

            if ([pasteObject isKindOfClass:[NSAttributedString class]]) {
                NSAttributedString *attributedString = (NSAttributedString *) pasteObject;
                [self pasteAsPlainText:attributedString.string];
            }else if ([pasteObject isKindOfClass:[NSString class]]) {
                [self pasteAsPlainText:pasteObject];
            }
        }
    }
}


- (IBAction) reformatSelectedCode:(id) sender {
    NSString *selectedString = [self.string substringWithRange:self.selectedRange];
    NSString *reformatedString = [QCCFormater formatCodeString:selectedString];
    if (reformatedString){
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard setString:reformatedString forType:NSStringPboardType];
        [self pasteAsPlainText:sender];
        [pasteboard clearContents];
    }
}

- (void) pasteAsPlainText:(id)sender {
    [super pasteAsPlainText:sender];
}
- (void) pasteAsRichText:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [super pasteAsRichText:sender];
}
- (void) pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type {
    NSLog(@"%s", __FUNCTION__);
    [super pasteboard:sender provideDataForType:type];
}

- (void) pasteboardChangedOwner:(NSPasteboard *)sender {
    NSLog(@"%s", __FUNCTION__);
    [super pasteboardChangedOwner:sender];
}

- (void) pasteFont:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [super pasteFont:sender];
}


#pragma mark - Fix-it
- (void) showPopoverForFixIts:(NSArray *) fixIts {
    if (_fixItPopover.isShown) {
        [_fixItPopover close];
        return;
    }
//    QCCFixItViewController *fixItController = [[QCCFixItViewController alloc] initWithFixIts:@[@"1", @"2", @"3", @"4"]];

    NSScrollView *tableScrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [tableScrollView setDrawsBackground:NO];
//    [tableScrollView setDocumentView:tableView];
    [tableScrollView setHasVerticalScroller:YES];
    
    NSView *contentView = [[NSView alloc] initWithFrame:NSZeroRect];
    [contentView addSubview:tableScrollView];
    
    NSViewController *contentViewController = [[NSViewController alloc] init];
    [contentViewController setView:contentView];
    
    _fixItPopover.contentViewController = contentViewController;
    _fixItPopover.contentSize = NSMakeSize(400, 200);
    // Fix-it feature is in future.
    //[_fixItPopover showRelativeToRect:CGRectMake(100, 0, 1, 1) ofView:self preferredEdge:CGRectMaxYEdge];
    
}
@end
