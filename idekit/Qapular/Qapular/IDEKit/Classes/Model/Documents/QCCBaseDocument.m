//
//  QCCBaseDocument.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseDocument.h"
#import "QCCWindowController.h"
#import "QCCodeViewController.h"
#import "QCCodeView.h"
#import "QCCPreferences.h"
#import "QCCDocumentController.h"



static NSString *const DocumentWindowStoryboardFileName = @"IDEKit";
static NSString *const DocumentWindowControllerIdentefier = @"QCCWindowController";

static NSString *const DocumentTemporaryExtention = @"c";

@interface QCCBaseDocument() {
    QCCPreferences          *_preferences;

}

@end

@implementation QCCBaseDocument

#pragma mark - Save untiteled file

-(instancetype)initAutoSaveFileWithType:(NSString *)typeName error:(NSError **)outError completion:(void (^)(NSError *errorOrNil))completion {
    
    self = [super initWithType:typeName error:outError];
    if (self) {
        
        [self saveToURL:[self temporaryFilePathForType:typeName]
                 ofType:typeName
       forSaveOperation:NSAutosaveElsewhereOperation
      completionHandler:^(NSError *errorOrNil) {
          completion(errorOrNil);
      }];
        
    }
    return self;
    
}

#pragma mark - Window managing

-(void)makeWindowControllers {
    if ([self.windowControllers count] == 0) {
        
        NSStoryboard *devKitStoryboard = [NSStoryboard storyboardWithName:DocumentWindowStoryboardFileName bundle:[NSBundle mainBundle]];
        QCCWindowController  *documentWindowController = [devKitStoryboard instantiateControllerWithIdentifier:DocumentWindowControllerIdentefier];
        [self addWindowController:documentWindowController];
    }
}


-(void)addWindowController:(NSWindowController *)windowController {
    [super addWindowController:windowController];
}


+ (BOOL)autosavesInPlace {
    return NO;
}


-(void) showWindows {
    [super showWindows];
}


- (NSURL *) temporaryFilePathForType:(NSString *)typeName {
    
    NSString *temporaryDirectory;
    
    switch ([[self preferences] selectedUnSavedDocumentFolderIndex]) {
        case QCCPreferencesUnSavedDocumentFolderTemporary:
            temporaryDirectory = NSTemporaryDirectory();
            break;
        case QCCPreferencesUnSavedDocumentFolderDesctop: {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask,YES);
            temporaryDirectory = [pathArray firstObject];
        }
            break;
        case QCCPreferencesUnSavedDocumentFolderDocuments: {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            temporaryDirectory = [pathArray firstObject];
        }
            break;
            
        default:
            temporaryDirectory = NSTemporaryDirectory();
            break;
    }
    
    NSString *extension = [[NSWorkspace sharedWorkspace] preferredFilenameExtensionForType:typeName];
    
    NSURL *fileURL;
    for (int i = 0; ; i++) {
        NSString *fileName;
        if (i == 0)
            fileName = [NSString stringWithFormat:@"untitled"];
        else
            fileName = [NSString stringWithFormat:@"untitled-%i", i];
        
        NSString *filePath = [temporaryDirectory stringByAppendingPathComponent:fileName];
        filePath = [filePath stringByAppendingPathExtension:extension];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
            break;
            
        }
    }
    
    return fileURL;
}


- (QCCPreferences *) preferences {
    if (_preferences)
        return _preferences;
    
    _sharedDocumentController = [QCCDocumentController sharedDocumentController];
    _preferences = _sharedDocumentController.applicationPreferences;
    
    return _preferences;
}



#pragma mark - QCCEditorDataSource
- (QCCodeStorage *) codeStorageForCodeView:(QCCodeView *) view; {
    return nil;
}
- (QCCThemaManager *) themaManagerForCodeView:(QCCodeView *) view; {
    return nil;
}
-(QCCPreferences *)preferencesForCodeView:(QCCodeView *)view; {
    return nil;
}
- (NSString *) titleForDocument; {
    return nil;
}
- (NSImage *)imageForDocument; {
    return nil;
}
-(QCCAnalyser *)analyserForCodeView:(QCCodeView *)view {
    return nil;
}


@end
