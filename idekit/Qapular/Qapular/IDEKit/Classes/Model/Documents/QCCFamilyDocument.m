//
//  QCCFamilyDocument.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFamilyDocument.h"
#import "QCCodeStorage.h"
#import "QCCThemaManager.h"
#import "QCCDocumentController.h"

#import "QCCWindowTitleBar.h"
#import "QCCStatusBar.h"

#import "QCCRootView.h"
#import "QCCWindowController.h"
#import "QCCodeViewController.h"

#import "QCCBracketMachine.h"
#import "QCCFamilyAnalyser.h"
#import "QCCProjectDocument.h"
#import "QCCProjectProcessor.h"
#import "NSDocumentController+QCCProjectEnvironmentSource.h"
#import "QCCBaseDocument+UTType.h"

@class QCCodeView;
@class QCCPreferences;

@interface QCCFamilyDocument() {
    QCCodeStorage           *_codeStorage;
    QCCThemaManager         *_themaManager;
    QCCFamilyAnalyser       *_analyser;
}

@end

@implementation QCCFamilyDocument

@synthesize projectEnvironmentSource = _projectEnvironmentSource;

static const NSStringEncoding DefaultStringEncoding = NSUTF8StringEncoding;

#pragma mark - Initialization
- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self =  [super initWithContentsOfURL:url ofType:typeName error:outError];
    if (self) {
    }
    return self;
}

- (instancetype)initForURL:(NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self = [super initForURL:urlOrNil withContentsOfURL:contentsURL ofType:typeName error:outError];
    if (self) {
    }
    return self;
}

- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self = [super initAutoSaveFileWithType:typeName error:outError completion:^(NSError *errorOrNil) {
        if (!errorOrNil) {
            
            [self loadCodeStorageWithString:@" "];
            
        }else {
            NSLog(@"Error: %@", errorOrNil);
        }
        
    }];
    
    if (self) {
    }
    
    return self;
}


- (QCCThemaManager *) themaManager {
    
    if (_themaManager)
        return _themaManager;
    
    _sharedDocumentController = [QCCDocumentController sharedDocumentController];
    _themaManager = _sharedDocumentController.applicationThemaManager;
    
    return _themaManager;
}

- (BOOL) loadCodeStorageWithString:(NSString *) string {
    @synchronized(self) {
        if (!_codeStorage)
            _codeStorage = [[QCCodeStorage alloc] initWithString:string
                                             bracketMachineClass:[QCCBracketMachine class]
                                                 andThemaManager:[self themaManager]];
        
        if (!_codeStorage)
            return NO;
        return YES;
    }
}

- (BOOL) loadAnalyzer {
    if (_analyser)
        _analyser = nil;
    
    NSString *filePath = (self.fileURL ? self.fileURL.path : self.autosavedContentsFileURL.path);
    
    if (filePath)
        _analyser = [[QCCFamilyAnalyser alloc] initForDocument:self
                                                     themaManager:[self themaManager]
                                                        projectEnvironmentSource:self.projectEnvironmentSource];
    
    else
        return NO;
    
    _codeStorage.delegate = _analyser;
    
    return YES;
}


- (id<QCCProjectEnvironmentSource>) projectEnvironmentSource {
    if (!_projectEnvironmentSource)
        return _sharedDocumentController;
    else
        return _projectEnvironmentSource;
}


- (void) setProjectEnvironmentSource:(id<QCCProjectEnvironmentSource>)projectEnvironmentSource {
    if (projectEnvironmentSource != _projectEnvironmentSource) {
        _projectEnvironmentSource = projectEnvironmentSource;
        [self loadAnalyzer];
    }
}

#pragma mark - Read
- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [super readFromURL:url ofType:typeName error:outError];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    /*
     There is you can check file attributes, after you should set readonly for file.
     It needs for system headers and includes.
     Also we can check encoding
     NSLog(@"fileAttributes: %@", fileWrapper.fileAttributes);
     */
    return [super readFromFileWrapper:fileWrapper ofType:typeName error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *) typeName error:(NSError **)outError {
    
    [self.undoManager disableUndoRegistration];
    NSString *documentContent;
    if (data && data.length > 0)
        documentContent = [NSString stringWithUTF8String:[data bytes]];
    
    if (!documentContent)
        documentContent = [NSString new];
    
    [self loadCodeStorageWithString:documentContent];

    if (!_codeStorage)
        return NO;
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    
    [self.undoManager enableUndoRegistration];
    return YES;
}


#pragma mark - Write
- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation {
    return [super writableTypesForSaveOperation:saveOperation];
}

- (BOOL)writeSafelyToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {
    return [super writeSafelyToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)outError {
    return [super writeToURL:url ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:outError];
}


- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [super writeToURL:url ofType:typeName error:outError];
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    NSData *codeContentData = [_codeStorage.string dataUsingEncoding:DefaultStringEncoding];
    
    if (!codeContentData)
        codeContentData = [NSData new];
        
    return codeContentData;
}

#pragma mark - QCCEditorDataSource
- (QCCodeStorage *) codeStorageForCodeView:(QCCodeView *) view {
    return _codeStorage;
}

- (QCCThemaManager *) themaManagerForCodeView:(QCCodeView *) view {
    return [self themaManager];
}

- (QCCPreferences *)preferencesForCodeView:(QCCodeView *)view; {
    return [self preferences];
}

- (NSString *) titleForDocument {
    
    if (!self.fileURL)
        return NSLocalizedString(@"untitled", @"title for not saved document.");
    
    NSArray *pathComponents = self.fileURL.pathComponents;
    NSString *file = self.fileURL.lastPathComponent;
    
    if ([pathComponents count] >= 2)
        return [NSString stringWithFormat:@"%@ - %@", file, pathComponents[[pathComponents count]-2]];
    else
        return [NSString stringWithFormat:@"%@", file];
    return nil;
    
}

- (QCCAnalyser *) analyserForCodeView:(QCCodeView *) view {
    return _analyser;
}


- (NSImage *)imageForDocument {
    NSLog(@"fileType: %@", self.fileType);

    return nil;
}

- (QCCodeStorage *) codeStorage {
    return _codeStorage;
}

/* for future
- (void)lockDocument:(id)sender
- (void)duplicateDocument:(id)sender
- revertToContentsOfURL:ofType:error:
- (void)browseDocumentVersions:(id)sender
*/

@end
