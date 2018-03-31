//
//  QCCPreferences.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCPreferences : NSObject

typedef enum : NSUInteger {
    QCCWrapColumnNon,
    QCCWrapColumnAtFrameSize,
    QCCWrapColumnValue
} QCCWrapColumn;

typedef struct {
    QCCWrapColumn type;
    int     columns;
}QCCPreferencesWrapColumn;

typedef enum : NSUInteger {
    QCCPreferencesUnSavedDocumentFolderTemporary    =   0,
    QCCPreferencesUnSavedDocumentFolderDocuments    =   1,
    QCCPreferencesUnSavedDocumentFolderDesctop      =   2,
} QCCPreferencesUnSavedDocumentFolder;


extern NSString *const  QCCPreferencesFontAndColorThemeKey;
extern NSString *const	QCCPreferencesThemeKey;
extern NSString *const	QCCPreferencesWrapColumnKey;
extern NSString *const	QCCPreferencesShowLineNumberKey;
extern NSString *const	QCCPreferencesUnSavedDocumentFolderIndexKey;


extern NSString *const  FontAndColorThemesBundle;
extern NSString *const	FontAndColorThemesExtension;

extern NSString *const	QCCPreferencesUpdatedNotification;
extern NSString *const	QCCPreferencesUpdatedValueKey;


#pragma mark - Appearance

- (NSString *) selectedTheme;
- (void) selectTheme:(NSString *) value;

- (QCCPreferencesWrapColumn) wrapColumn;
- (void) setWrapColumn:(QCCPreferencesWrapColumn) value;
- (BOOL) shouldShowLineNumbering;
- (void) setShouldShowLineNumbering:(BOOL) value;
- (NSArray *) themeList;

- (QCCPreferencesUnSavedDocumentFolder) selectedUnSavedDocumentFolderIndex;
- (void) setUnSavedDocumentFolderIndex:(QCCPreferencesUnSavedDocumentFolder) folderIndex;

- (void) addLibraryURL:(NSURL *) url;
- (void) removeLibraryURL:(NSString *) urlPath;
- (NSArray< NSString *> *) libraryList;
- (NSArray< NSURL *> *) libraryURLList;

@end
