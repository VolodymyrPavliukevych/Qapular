//
//  QCCDocumentController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCDocumentController.h"
#import "QCCThemaContainer.h"
#import "QCCThemaManager.h"
#import "QCCPreferences.h"
#import "QCCPreferencesViewController.h"
#import "QCCWindow.h"
#import "QCCBaseProjectDocument.h"
#import "QCCSandBoxManager.h"
#import "NSObject+Cast.h"
#import "QCCBaseDocument+UTType.h"
#import "QCCDocumentController+Menu.h"
#import "QCCDocumentController+NSOpenSavePanelDelegate.h"
#import "QCCWelcomeWindowController.h"
#import "QCCPreferencesWindowController.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>

#import "QCCWindowController.h"
#import "QCCProjectWindowController.h"


@interface QCCDocumentController() <NSWindowDelegate, QCCWelcomeDelegate>{
    
    QCCThemaManager     *_applicationThemaManager;
    QCCPreferences      *_applicationPreferences;
    QCCTargetManager    *_targetManager;

    QCCPreferencesWindowController  *_preferencesWindowController;
    QCCWelcomeWindowController      *_welcomeWindowController;

}

@end

@implementation QCCDocumentController
#pragma mark - UI section
#pragma mark WelcomeDelegate

#warning (NeedsBetterSolution) Should set withContentsOfURL as template URL

-(void)welcomeWindowController:(QCCWelcomeWindowController *)controller createDocumentWithURL:(NSURL *)url fileType:(NSString *)fileType {
    
    [controller.window close];
    
    NSError *error;
    
    NSDocument *document = [self makeDocumentForURL:url withContentsOfURL:[NSURL new] ofType:fileType error:&error];
    
    if (error || !document)
        NSLog(@"Error: %@", error);
    
    [self addDocument:document];
    [document makeWindowControllers];
    [document showWindows];
}

#pragma mark Welcome Section
- (void) showWelcomeWindow {
    if (!_welcomeWindowController)
        _welcomeWindowController = [QCCWelcomeWindowController initFromDefaultWindowNib];
    
    _welcomeWindowController.delegate = self;
    NSWindow *window = _welcomeWindowController.window;
    
    window.delegate = self;
    [window makeKeyAndOrderFront:self];
    
}

#pragma mark Preferences Actions
-(IBAction) showPreferences:(id) sender {

    _preferencesWindowController = [QCCPreferencesWindowController initFromDefaultWindowNib];
    _preferencesWindowController.documentController = self;
    _preferencesWindowController.window.delegate = self;
    [_preferencesWindowController.window makeKeyAndOrderFront:self];
    
}


#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[NSWindow class]]) {
        if ([notification.object windowController] == _preferencesWindowController) {
            _preferencesWindowController = nil;
        }
    }
}

#pragma mark - Application delegate
-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self showWelcomeWindow];
    }
    
    return NO;
}

-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    [self showWelcomeWindow];
    return NO;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}


#pragma mark - Document work-flow
- (void) addDocument:(NSDocument *)document {
    [super addDocument:document];
}


-(id) currentDocument {
    return [[[self currentWindow] windowController] document];
}

- (NSWindow *) currentWindow {    
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        id windowController = window.windowController;
        
        if (window.isKeyWindow && window.windowController.document && ([windowController isKindOfClass:[QCCWindowController class]] || [windowController isKindOfClass:[QCCProjectWindowController class]]))
            return window;
    }
    return nil;
}


- (id) openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError *__autoreleasing *)outError {
    id document = [super openUntitledDocumentAndDisplay:displayDocument error:outError];
    return document;
}

- (IBAction)openDocument:(nullable id)sender {
    
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setMessage:NSLocalizedString(@"Please, select the folder containing qccproj file.", @"OpenPanel")];
    [openPanel setDelegate:self];
    [openPanel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSError *error;
            for (NSURL *fileURL in [openPanel URLs]) {
                
                NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileURL
                                                               includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&error];
                
                for (NSURL *url in items) {
                    if ([url.lastPathComponent.pathExtension isEqualToString:[QCCBaseDocument extensionForUTType:kUTTypeQCCProject]]) {
                        [QCCSandBoxManager saveBookmarkForURL:fileURL relatedProjectURL:url];
                        [self openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
                            
                        }];
                        break;
                    }
                }
            }
        }        
    }];

}

-(void) reopenDocumentForURL:(NSURL *)urlOrNil
          withContentsOfURL:(NSURL *)contentsURL
                    display:(BOOL)displayDocument
          completionHandler:(void (^)(NSDocument *, BOOL, NSError *))completionHandler {
    
    [QCCSandBoxManager restoreAccessToProjectURL:urlOrNil];
    NSLog(@"Reopen documentForURL: %@ and contentsOfURL:%@", urlOrNil, contentsURL);
    [super reopenDocumentForURL:urlOrNil withContentsOfURL:contentsURL display:displayDocument completionHandler:completionHandler];
}


- (id) makeUntitledDocumentOfType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSError *error;
    id document = [super makeUntitledDocumentOfType:typeName error:&error];
    
    if (!document || error) {
        NSLog(@"Error : %@", [error localizedDescription]);
    }

    return document;
}

-(NSDocument *)makeDocumentWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    return [super makeDocumentWithContentsOfURL:url ofType:typeName error:outError];
}

-(void)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument * _Nullable, BOOL, NSError * _Nullable))completionHandler {
    
    if ([url.lastPathComponent.pathExtension isEqualToString:[QCCBaseDocument extensionForUTType:kUTTypeQCCProject]]) {
        [QCCSandBoxManager restoreAccessToProjectURL:url];
    }
    
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if (window == _welcomeWindowController.window) {
            [window close];
        }
    }

    [super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:completionHandler];
}

- (Class) documentClassForType:(NSString *)typeName {
    
    Class class = [super documentClassForType:typeName];
    return class;
}

-(NSString *) typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    return [super typeForContentsOfURL:url error:outError];
}

- (NSString *) defaultType {
    /*
    NSString *UTI = @"public.c-plus-plus-header";
    CFDictionaryRef utiDecl = UTTypeCopyDeclaration((__bridge CFStringRef) UTI);
    */
    return kUTTypeQCCProject;
    return (NSString *) kUTTypeCSource;

}

- (void) displayDocument:(NSDocument *)doc {
    NSLog(@"Call: %s", __FUNCTION__);
}

#pragma mark - Environment
- (void) updateDocumentEnvironments {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSDocument *document in self.documents) {
            if ([document isKindOfClass:[QCCFamilyDocument class]]) {
                QCCFamilyDocument *cFamilyDocument = (QCCFamilyDocument *) document;
                [cFamilyDocument loadAnalyzer];
            }
        }
    });
}


#pragma mark - Thema manager & container;
- (QCCThemaManager *) applicationThemaManager {

    if (_applicationThemaManager)
        return _applicationThemaManager;
    

    _applicationThemaManager = [[QCCThemaManager alloc] initWithApplicationPreferences:self.applicationPreferences];
    // Load thema & container or set default value.
    return _applicationThemaManager;
    
}

- (QCCPreferences *) applicationPreferences {

    if (_applicationPreferences)
        return _applicationPreferences;
    
    _applicationPreferences = [QCCPreferences new];
        
    return _applicationPreferences;
}

-(QCCTargetManager *) applicationTargetManager {
    if (_targetManager)
        return _targetManager;
    
    _targetManager = [QCCTargetManager defaultManager];
    return _targetManager;
    
}


#pragma mark - Supported files

- (NSArray *) supportedTypesWithProject:(BOOL) project {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *types = [infoDict valueForKeyPath:@"CFBundleDocumentTypes.LSItemContentTypes"];
    NSMutableArray  *result = [types valueForKeyPath:@"@unionOfArrays.self"];
    
    if (!project)
        [result removeObject:@"com.qapular.project"];
    
    return result;
    
}


@end
