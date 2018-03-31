//
//  QCCThemaManager.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "QCCThemaManager.h"
#import "NSColor+QCColor.h"

#import "QCCPreferences.h"

@interface QCCThemaManager() {

    QCCPreferences  *_applicationPreferences;
}

@end



@implementation QCCThemaManager

#pragma mark - IDEKit

#pragma mark Ruler Fonts
NSString *const	IDEKitRulerFontName = @"XcodeDigits";//TitilliumWeb-Light";

#pragma mark Ruler Colors

static const CGFloat IDEKitDarkThemaRulerBackgroundColorShift = 0.16470588;
static const CGFloat IDEKitDarkThemaRulerBorderColorhift = 0.3215686f;
static const CGFloat IDEKitDarkThemaRulerCaretBackgroundColorShift = 0.3215686f;
static const CGFloat IDEKitDarkThemaRulerCaretBorderColorShift = 0.3529411f;
static const CGFloat IDEKitDarkThemaRulerNumberColorShift = 0.7764705f;

static const CGFloat IDEKitLightThemaRulerBackgroundColorShift = -0.1019607f;
static const CGFloat IDEKitLightThemaRulerBorderColorhift = -0.3058823f;
static const CGFloat IDEKitLightThemaRulerCaretBackgroundColorShift = -0.0392156f;
static const CGFloat IDEKitLightThemaRulerCaretBorderColorShift = -0.3058823f;
static const CGFloat IDEKitLightThemaRulerNumberColorShift = -0.8784313f;

static const CGFloat IDEKitWaterLineBackgroundColorShift = -0.01176471;

static const CGFloat IDEKitLightThemaSourceTreeRowSelectedBackgroundColorShift = -0.3f;


#pragma mark - Thema Keys

NSString *const	ConsoleDebuggerPromptTextColorKey  = @"DVTConsoleDebuggerPromptTextColor";
NSString *const	DebuggerInstructionPointerColorKey = @"DVTDebuggerInstructionPointerColor";
NSString *const	SourceTextBackgroundKey            = @"DVTSourceTextBackground";
NSString *const	SourceTextInsertionPointColorKey   = @"DVTSourceTextInsertionPointColor";
NSString *const	SourceTextSelectionColorKey        = @"DVTSourceTextSelectionColor";
NSString *const	SourceTextSyntaxFontsKey           = @"DVTSourceTextSyntaxFonts";
NSString *const	SourceTextSyntaxColorsKey          = @"DVTSourceTextSyntaxColors";

NSString *const QCCThemaManagerReplacedNotification = @"QCCThemaManagerReplacedNotification";

static NSString *const ProjectLightNormalBackgroundColorString = @"0xe8eaed";
static NSString *const ProjectLightHighlightedBackgroundColorString = @"0xf2f3f6";
static NSString *const ProjectLightBorderColorString = @"0xc4c7ce";

static NSString *const ProjectDarkNormalBackgroundColorString = @"0x36393b";
static NSString *const ProjectDarkHighlightedBackgroundColorString = @"0x4d5154";
static NSString *const ProjectDarkBorderColorString = @"0x262626";






static QCCThemaManager *sharedSingleton = nil;

+(instancetype) shared {
    
    if(!sharedSingleton){
        sharedSingleton = [[QCCThemaManager alloc] init];
    }
    
    return sharedSingleton;
    
}

- (instancetype) initWithApplicationPreferences:(QCCPreferences *) preferences {
    
    if (sharedSingleton) return sharedSingleton;
    
    self = [super init];
    
    if(self) {
        _applicationPreferences = preferences;
        
        NSString *themeFilePath = [[self class] fontAndColorThemesPath:[_applicationPreferences selectedTheme]];
        _container = [[QCCThemaContainer alloc] initWithContentsOfFile:themeFilePath];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatedPreferences:)
                                                     name:QCCPreferencesUpdatedNotification
                                                   object:nil];
    }
    
    sharedSingleton = self;
    return self;
}

- (void) updatedPreferences:(NSNotification *) notification {
    
    if ([notification.userInfo objectForKey:QCCPreferencesUpdatedValueKey] == QCCPreferencesFontAndColorThemeKey)
        [self replaceTheme];    
}

- (void) replaceTheme {
    if (_applicationPreferences) {
     
        NSString *themeFilePath = [[self class] fontAndColorThemesPath:[_applicationPreferences selectedTheme]];
        _container = [[QCCThemaContainer alloc] initWithContentsOfFile:themeFilePath];

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QCCThemaManagerReplacedNotification object:nil];
}


- (NSString *) themaValueForKey:(NSString *const) key {
   return _container[key];
}

- (NSColor *) colorForKey:(NSString *const) colorKey {

    NSString *colorString = [self themaValueForKey:colorKey];
    
    if (!colorString)
        return [NSColor orangeColor];
    
    NSColor *color = [NSColor colorWithFloatString:colorString];
    if (!color)
        return [NSColor orangeColor];
    return color;
}

- (NSColor *) colorForKeyPath:(NSArray *) colorKeyPath {

    NSString *colorString = [_container valueForKeyPath:[colorKeyPath componentsJoinedByString:@"."]];
    
    if (!colorString)
        return [NSColor orangeColor];
    
    NSColor *color = [NSColor colorWithFloatString:colorString];
    if (!color)
        return [NSColor orangeColor];

    return color;
}


#pragma mark - Fonts
- (NSFont *) fontForKeyPath:(NSArray *) fontKeyPath {
    
    NSString *fontString = [_container valueForKeyPath:[fontKeyPath componentsJoinedByString:@"."]];
    
    if (!fontString)
        return nil;
    NSArray *fontComponents = [fontString componentsSeparatedByString:@" - "];
    
    if ([fontComponents count] != 2)
        return nil;
    NSScanner *scaner = [[NSScanner alloc] initWithString:fontComponents[1]];
    
    float fontSize;
    if (![scaner scanFloat:&fontSize])
        return nil;
    
    return  [NSFont fontWithName:fontComponents[0] size:fontSize];
    
}

- (CGFloat) fontSizeForKeyPath:(NSArray *) fontKeyPath {
    
    NSString *fontString = [_container valueForKeyPath:[fontKeyPath componentsJoinedByString:@"."]];
    
    if (!fontString)
        return -1;
    
    NSArray *fontComponents = [fontString componentsSeparatedByString:@" - "];
    
    if ([fontComponents count] != 2)
        return -1;
    
    NSScanner *scaner = [[NSScanner alloc] initWithString:fontComponents[1]];
    
    float fontSize;
    if (![scaner scanFloat:&fontSize])
        return -1;
    
    return fontSize;
    
}



+ (NSString *) fontAndColorThemesPath:(NSString *) fileName {
    return [[NSBundle mainBundle] pathForResource:fileName ofType:FontAndColorThemesExtension inDirectory:FontAndColorThemesBundle];

}

#pragma mark - Ruler options
- (NSFont *) rulerFontWithSize:(CGFloat) size {

    NSFont *font = [NSFont fontWithName:IDEKitRulerFontName size:size];
    if (!font)
        return [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
    
    return font;
}

- (NSColor *) rulerBackgroundColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerBackgroundColorShift : IDEKitLightThemaRulerBackgroundColorShift) alphaShift:0.0];
}

- (NSColor *) rulerBorderColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerBorderColorhift  : IDEKitLightThemaRulerBorderColorhift) alphaShift:0.0];

}

- (NSColor *) rulerCaretBackgroundColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerCaretBackgroundColorShift  : IDEKitLightThemaRulerCaretBackgroundColorShift) alphaShift:0.0];

}

- (NSColor *) rulerCaretBorderColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerCaretBorderColorShift  : IDEKitLightThemaRulerCaretBorderColorShift) alphaShift:0.0];

}

- (NSColor *) rulerLineNumberColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerNumberColorShift : IDEKitLightThemaRulerNumberColorShift) alphaShift:0.0];

}

#pragma mark - CodeView
- (NSColor *) waterlineBackgroundColor {

    NSColor *backgroundColor  = [self colorForKey:SourceTextBackgroundKey];
    
    NSColor *waterlineBackgroundColor = [backgroundColor colorWithSharedShift:IDEKitWaterLineBackgroundColorShift alphaShift:0];
    
    return waterlineBackgroundColor;
}

#pragma mark - Background & border for project window

- (NSColor *) projectWindowBorderColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor colorWithHexString:ProjectLightBorderColorString];
    else
        return [NSColor colorWithHexString:ProjectDarkBorderColorString];
}

- (NSColor *) projectWindowBackgroundNormalColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor colorWithHexString:ProjectLightNormalBackgroundColorString];
    else
        return [NSColor colorWithHexString:ProjectDarkNormalBackgroundColorString];
    
}


- (NSColor *) projectWindowBackgroundHighlightedColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor colorWithHexString:ProjectLightHighlightedBackgroundColorString];
    else
        return [NSColor colorWithHexString:ProjectDarkHighlightedBackgroundColorString];
}

#pragma mark - Icons
- (NSColor *) iconTintColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor colorWithHexString:@"999999"];
    return [NSColor colorWithHexString:@"aaaaaa"];
    
}

- (NSColor *) iconSelectedTintColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor colorWithHexString:@"60a9d7"];
    return [NSColor colorWithHexString:@"919fa6"];
}

#pragma mark - Menu Labels
- (NSColor *) labelColor {
    if ([self spectrum] == QCCThemaSpectrumLight)
        return [NSColor darkGrayColor];
    return [NSColor grayColor];
}

#pragma mark - Navigation Aria
#pragma mark SourceTree menu
- (NSColor *) sourceTreeRowSelectedBackgroundColor {
    return [[self anchorColor] colorWithSharedShift:([self spectrum] == QCCThemaSpectrumDark ? IDEKitDarkThemaRulerCaretBackgroundColorShift  : IDEKitLightThemaSourceTreeRowSelectedBackgroundColorShift) alphaShift:0.0];
}

#pragma mark - Spectrum
- (QCCThemaSpectrum) spectrum {
    NSColor *backgroundColor = [self colorForKey:SourceTextBackgroundKey];

    NSColor *convertedColor=[backgroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
    
    float colorValue = (redFloatValue + greenFloatValue + blueFloatValue) / 3;
    
    if (colorValue > 0.455)
        return QCCThemaSpectrumLight;
    else
        return QCCThemaSpectrumDark;

}

- (NSString *) appearanceName {

    switch ([self spectrum]) {
        case QCCThemaSpectrumDark:
            return NSAppearanceNameVibrantDark;
            
        case QCCThemaSpectrumLight:
            return NSAppearanceNameVibrantLight;
            
        default:
            return NSAppearanceNameVibrantLight;
    }
}

#pragma mark - Helper
- (NSColor *) anchorColor {
    return [self colorForKey:SourceTextBackgroundKey];
}

#pragma mark - Report thema
- (NSColor *) reportAreaBackgroundColor {
    return [self colorForKey:SourceTextBackgroundKey];
}

- (NSDictionary *) outputReportThema {
    
    static dispatch_once_t onceToken;
    static NSDictionary *outputReportThema;
    dispatch_once(&onceToken, ^{
        NSFont *syntaxFontAttribute = [self fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
        NSColor *syntaxColorAttribute = [self colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.plain"]];
        
        outputReportThema = @{NSFontAttributeName:syntaxFontAttribute,
                              NSForegroundColorAttributeName:syntaxColorAttribute};
    });
    
    
    return outputReportThema;
}


- (NSDictionary *) errorReportThema {
    static dispatch_once_t onceToken;
    static NSDictionary *errorReportThema;
    dispatch_once(&onceToken, ^{
        NSFont *syntaxFontAttribute = [self fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
        NSColor *syntaxColorAttribute = [NSColor redColor];
        
        errorReportThema = @{NSFontAttributeName:syntaxFontAttribute,
                             NSForegroundColorAttributeName:syntaxColorAttribute};
    });
    
    
    return errorReportThema;
    
}


- (NSDictionary *) warningReportThema {
    static dispatch_once_t onceToken;
    static NSDictionary *warningReportThema;
    dispatch_once(&onceToken, ^{
        NSFont *syntaxFontAttribute = [self fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
        NSColor *syntaxColorAttribute = [NSColor brownColor];
        
        warningReportThema = @{NSFontAttributeName:syntaxFontAttribute,
                               NSForegroundColorAttributeName:syntaxColorAttribute};
    });
    
    
    return warningReportThema;
    
}




@end
