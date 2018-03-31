//
//  QCCPreferences.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCPreferences.h"
#import "QCCSandBoxManager.h"

@interface QCCPreferences() {
    
    NSUserDefaults *_preferences;
    NSDictionary *_defaultPreferences;
}

@end

@implementation QCCPreferences

NSString *const	QCCPreferencesFontAndColorThemeKey      = @"QCCPreferencesTheme";
NSString *const	QCCPreferencesWrapColumnKey             = @"QCCPreferencesWrapColumn";
NSString *const	QCCPreferencesShowLineNumberKey         = @"QCCPreferencesShowLineNumber";
NSString *const	QCCPreferencesUnSavedDocumentFolderIndexKey = @"QCCPreferencesUnSavedDocumentFolderIndexKey";

static NSString *const PreferencesPlistFile         = @"Preference";
static NSString *const PreferencesPlistExtension    = @"plist";

NSString *const FontAndColorThemesBundle            = @"FontAndColorThemes.bundle";
NSString *const FontAndColorThemesExtension         = @"dvtcolortheme";

NSString *const QCCPreferencesUpdatedNotification   = @"QCCPreferencesUpdatedNotification";
NSString *const QCCPreferencesUpdatedValueKey       = @"QCCPreferencesUpdatedValueKey";

NSString *const QCCPreferencesLibraryKey            = @"QCCPreferencesLibrary";


#pragma mark - Preferences keys
- (instancetype) init {

    self = [super init];
    if (self) {
    
        [self loadDefaultPreferences];
        [self restoreLibraryAccess];
    }
    
    return self;
}

- (void) restoreLibraryAccess {
    for (NSString *libraryURLPath in [self libraryList]) {
       [QCCSandBoxManager restoreAccessForKey:libraryURLPath];
    }
}

- (BOOL) loadDefaultPreferences {
    _preferences = [NSUserDefaults standardUserDefaults];
    _defaultPreferences = [[NSDictionary alloc] initWithContentsOfFile:[[self class] preferencesPath]];
    
    return YES;
}

+ (NSString *) preferencesPath {

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:PreferencesPlistFile ofType:PreferencesPlistExtension];;
    return bundlePath;
}

#pragma mark - Preferences Appearance
- (NSString *) selectedTheme {
    
    NSString *selectedTheme = [_preferences objectForKey:QCCPreferencesFontAndColorThemeKey];
    if (!selectedTheme) {
        selectedTheme = _defaultPreferences[QCCPreferencesFontAndColorThemeKey];
        [_preferences setObject:selectedTheme forKey:QCCPreferencesFontAndColorThemeKey];
        [_preferences synchronize];
    }
    
    return selectedTheme;
}

- (void) selectTheme:(NSString *) value {
    [_preferences setObject:value forKey:QCCPreferencesFontAndColorThemeKey];
    [self saveForKey:QCCPreferencesFontAndColorThemeKey];
}

#pragma mark Wrap Column
- (QCCPreferencesWrapColumn) wrapColumn {
    QCCPreferencesWrapColumn wrapColumnValue;
    
    NSData *value = [_preferences objectForKey:QCCPreferencesWrapColumnKey];
    if (!value)
        wrapColumnValue.type = QCCWrapColumnNon;
    
    [value getBytes:&wrapColumnValue length:sizeof(QCCPreferencesWrapColumn)];
    
    return wrapColumnValue;
}


- (void) setWrapColumn:(QCCPreferencesWrapColumn) value {
    NSData *storedValue = [NSData dataWithBytes:&value length:sizeof(QCCPreferencesWrapColumn)];
    [_preferences setObject:storedValue
                     forKey:QCCPreferencesWrapColumnKey];
    
    [self saveForKey:QCCPreferencesWrapColumnKey];
}

#pragma mark Line numbering
- (BOOL) shouldShowLineNumbering {

    NSNumber *value =  [_preferences objectForKey:QCCPreferencesShowLineNumberKey];
    if (!value)
        return YES;
    
    return [value boolValue];
}

- (void) setShouldShowLineNumbering:(BOOL) value {

    NSNumber *storedValue = [NSNumber numberWithBool:value];
    [_preferences setObject:storedValue forKey:QCCPreferencesShowLineNumberKey];
    [self saveForKey:QCCPreferencesShowLineNumberKey];
    
}


- (NSArray *) themeList {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *rootBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:FontAndColorThemesBundle];
    NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:rootBundle error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH %@", FontAndColorThemesExtension];
    NSArray *themeList = [contentsOfDirectory filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *result = [NSMutableArray new];
    
    for (NSString *name in themeList) {
        {}
        [result addObject:[name stringByDeletingPathExtension]];
    }
    
    return result;
    
}

#pragma mark - Library
- (void) addLibraryURL:(NSURL *) url {
    if (!url && !url.path)
        return;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_preferences objectForKey:QCCPreferencesLibraryKey]];
    if ([array containsObject:url.path])
        return;
    
    [array addObject:url.path];
    [_preferences setObject:array forKey:QCCPreferencesLibraryKey];
    [QCCSandBoxManager saveBookmarkForURL:url relatedKey:url.path];
}

- (void) removeLibraryURL:(NSString *) urlPath {
    if (!urlPath)
        return;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_preferences objectForKey:QCCPreferencesLibraryKey]];
    [array removeObject:urlPath];
    [QCCSandBoxManager closeAccessForKey:urlPath];
    [_preferences setObject:array forKey:QCCPreferencesLibraryKey];
}

- (NSArray< NSString *> *) libraryList {
    return [_preferences objectForKey:QCCPreferencesLibraryKey];
}

- (NSArray< NSURL *> *) libraryURLList {
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSString *urlPath in [self libraryList]) {
        NSURL *url = [[NSURL alloc] initWithString:urlPath];
        if (url)
            [array addObject:url];
    }
    
    return array;
}

#pragma makr - Update Notification
- (void) saveForKey:(NSString *) key {
    [_preferences synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:QCCPreferencesUpdatedNotification
                                                        object:nil
                                                      userInfo:@{QCCPreferencesUpdatedValueKey : key}];
}


- (QCCPreferencesUnSavedDocumentFolder) selectedUnSavedDocumentFolderIndex {
    NSUInteger value = [[_preferences objectForKey:QCCPreferencesUnSavedDocumentFolderIndexKey] integerValue];
    
    return value;
}


- (void) setUnSavedDocumentFolderIndex:(QCCPreferencesUnSavedDocumentFolder) folderIndex {
    [_preferences setObject:@(folderIndex) forKey:QCCPreferencesUnSavedDocumentFolderIndexKey];
    [self saveForKey:QCCPreferencesUnSavedDocumentFolderIndexKey];
}



@end
