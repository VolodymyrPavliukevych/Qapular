//
//  QCCThemaManager.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCCThemaContainer.h"
#import "QCCPreferences.h"


typedef enum : NSUInteger {
    QCCThemaSpectrumUnknown,
    QCCThemaSpectrumDark,
    QCCThemaSpectrumLight
} QCCThemaSpectrum;

@class QCCThemaManager;

@protocol QCCThemaManagerDataSource <NSObject>

- (nullable QCCThemaManager *) themaManager;

@end

@interface QCCThemaManager : NSObject

@property (nullable, nonatomic, strong) QCCThemaContainer *container;

#pragma mark - Thema Keys

extern NSString *_Nonnull const	ConsoleDebuggerPromptTextColorKey;
extern NSString *_Nonnull const	DebuggerInstructionPointerColorKey;
extern NSString *_Nonnull const	SourceTextBackgroundKey;
extern NSString *_Nonnull const	SourceTextInsertionPointColorKey;
extern NSString *_Nonnull const	SourceTextSelectionColorKey;
extern NSString *_Nonnull const	SourceTextSyntaxFontsKey;
extern NSString *_Nonnull const	SourceTextSyntaxColorsKey;



#pragma mark - Notifications
extern NSString *_Nonnull const	QCCThemaManagerReplacedNotification;

- (nonnull instancetype) initWithApplicationPreferences:(nonnull QCCPreferences *) preferences;
- (void) replaceTheme;

- (nullable NSColor *) colorForKey:(nonnull NSString *const) colorKey;
- (nullable NSColor *) colorForKeyPath:(nonnull NSArray *) colorKeyPath;
- (nullable NSFont *) fontForKeyPath:(nonnull NSArray *) fontKeyPath;
- (CGFloat) fontSizeForKeyPath:(nonnull NSArray *) fontKeyPath;

- (QCCThemaSpectrum) spectrum;
- (nonnull NSString *) appearanceName;

#pragma mark - Ruler options
- (nullable NSFont *) rulerFontWithSize:(CGFloat) size;

- (nullable NSColor *) rulerBackgroundColor;
- (nullable NSColor *) rulerBorderColor;
- (nullable NSColor *) rulerCaretBackgroundColor;
- (nullable NSColor *) rulerCaretBorderColor;
- (nullable NSColor *) rulerLineNumberColor;

// Color for background after wrap column line
- (nullable NSColor *) waterlineBackgroundColor;

#pragma mark - Background & border for project window

- (nullable NSColor *) projectWindowBorderColor;
- (nullable NSColor *) projectWindowBackgroundNormalColor;
- (nullable NSColor *) projectWindowBackgroundHighlightedColor;

#pragma mark - Icons

- (nullable NSColor *) iconTintColor;
- (nullable NSColor *) iconSelectedTintColor;

#pragma mark - Menu Labels
- (nullable NSColor *) labelColor;

#pragma mark - Navigation Aria
#pragma mark SourceTree menu

- (nullable NSColor *) sourceTreeRowSelectedBackgroundColor;

#pragma mark - Report thema
- (nullable NSColor *) reportAreaBackgroundColor;
- (nullable NSDictionary <NSString *, id > *) outputReportThema;
- (nullable NSDictionary <NSString *, id > *) errorReportThema;
- (nullable NSDictionary <NSString *, id > *) warningReportThema;

@end

