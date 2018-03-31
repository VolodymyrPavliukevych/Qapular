//
//  QCCTemplateManager.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTemplateManager.h"
#import "QCCBaseProjectDocument+Dialog.h"
#import "QCCBaseProjectDocument.h"

#import "QCCProjectFileManager.h"
#import <AppKit/AppKit.h>

#import "QCCError.h"
#import "QCCNewFolderWindowController.h"
#import "QCCNewFileWindowController.h"
#import "QCCBaseDocument.h"
#import "QCCBaseDocument+UTType.h"


NSString  *const  QCCDocumentTemplateFileName          =   @"QCCDocumentTemplate.plist";

NSString  *const  QCCProjectSourceConfigurationKey     =   @"SourceConfigurationKey";
/*
NSString  *const  QCCProjectSourceFileKey              =   @"SourceFileKey";
NSString  *const  QCCProjectSourceVirtualFileKey       =   @"SourceVirtualFileKey";
NSString  *const  QCCProjectSourceRootFileKey          =   @"SourceRootFileKey";
NSString  *const  QCCProjectSourceParentKey            =   @"SourceParentKey";
NSString  *const  QCCProjectSourcePathKey              =   @"SourcePathKey";
NSString  *const  QCCProjectSourceISAKey               =   @"SourceISAKey";
NSString  *const  QCCProjectSourceFileTypeKey          =   @"SourceFileTypeKey";
NSString  *const  QCCProjectSourceContentKey           =   @"SourceContentKey";

NSString  *const  QCCProjectSourceGroupKey             =   @"SourceGroupKey";
*/
NSString  *const  QCCProjectSourceDescriptionKey     =   @"SourceDescriptionKey";
NSString  *const  QCCProjectSourceHeaderTypeKey      =   @"SourceHeaderTypeKey";
NSString  *const  QCCProjectSourceIconKey            =   @"SourceIconKey";
NSString  *const  QCCProjectSourceTitleKey           =   @"SourceTitleKey";


@interface QCCTemplateManager() {
    
    QCCBaseProjectDocument              *_document;
    
    QCCNewFolderWindowController        *_newFolderWindowController;
    QCCNewFileWindowController          *_newFileWindowController;
    
    NSArray                             *_documentTemplatesArray;
}

@end

@implementation QCCTemplateManager

- (instancetype) initWithDocument:(QCCBaseProjectDocument *) document {

    if (!document)
        return nil;
    
    self = [super init];
    
    if (self) {
        _document = document;
    }
    
    return self;
}

- (void) createInGroup:(QCCProjectGroup *) group newGrup:(void (^) (QCCProjectEssence *essence, NSError *error)) resultBlock {
    
    QCCProjectGroup *defaultGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey : @""}
                                                                     identifier:nil];
    
    _newFolderWindowController = [[QCCNewFolderWindowController alloc] initWithFolder:defaultGroup completion:^(QCCProjectEssence *subGroup) {
        
        // Cancel button
        if (!subGroup) {
            resultBlock(nil, nil);
            [[self baseWindow] endSheet:_newFolderWindowController.window];
            return;
        }
        
        // set parent folder
        subGroup.parent = group;
        
        // Is folder exist
        if ([[self defaultFileManager] essenceExists:subGroup inProjectPath:[_document projectFolderPath]]){
            resultBlock(nil, [QCCError errorForCode:QCCErrorCodeFolderExist]);
            return;
        }
        
        BOOL onFileSystem = [[self defaultFileManager] createOnFilesystem:subGroup];
        
        if (!onFileSystem)
            resultBlock(nil, [QCCError errorForCode:QCCErrorCodeCanNotCreateFolder]);
        
        
        if (resultBlock && onFileSystem)
            resultBlock(subGroup, nil);
        
        
        [[self baseWindow] endSheet:_newFolderWindowController.window];
        
        
    }];
    
    NSWindow *projectWindow = [self baseWindow];
    NSWindow *panelWindow = _newFolderWindowController.window;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [projectWindow beginSheet:panelWindow completionHandler:nil];
    });
    
}


- (void) createInGroup:(QCCProjectGroup *) group newFile:(void (^) (QCCProjectEssence *essence, NSError *error)) resultBlock {
    
    NSArray *array = [self documentTemplatesArray];
    
    _newFileWindowController = [[QCCNewFileWindowController alloc] initWithParentFolder:group templates:array completion:^(id object) {



        if (object) {
            
            QCCProjectFile *newFile = [[QCCProjectFile alloc] initWithDictionary:object identifier:nil];
            newFile.parent = group;
            
            __block NSDictionary *headerOptions;
            QCCProjectFile *header;
            
            if (object[QCCProjectSourceHeaderTypeKey]) {
                // create header

                [array enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    if ([obj[QCCProjectSourceFileTypeKey] isEqualToString:object[QCCProjectSourceHeaderTypeKey]]) {
                        headerOptions = obj;
                        *stop = YES;
                    }
                }];
                
                if (headerOptions) {
                    
                    header = [[QCCProjectFile alloc] initWithDictionary:headerOptions identifier:nil];
                    NSString *headerFileName = [newFile.path stringByDeletingPathExtension];
                    NSString *fileType = headerOptions[QCCProjectSourceFileTypeKey];
                    
                    NSString *extension = [QCCBaseDocument extensionForUTType:fileType];
                    headerFileName = [headerFileName stringByAppendingPathExtension:extension];
                    header.path = headerFileName;
                    header.parent = group;
                }
            }
            
            BOOL result = [[self defaultFileManager] createOnFilesystem:newFile withData:object[QCCProjectSourceContentKey]];
            
            if (result) {
                resultBlock(newFile, nil);
                
                BOOL headerCreated = [[self defaultFileManager] createOnFilesystem:header withData:headerOptions[QCCProjectSourceContentKey]];

                if (headerCreated)
                    resultBlock(header, nil);
            }
            else
                resultBlock(nil, [QCCError errorForCode:QCCErrorCodeCanNotCreateFile]);

            
        }
        
        
        [[self baseWindow] endSheet:_newFileWindowController.window];
    }];

    NSWindow *projectWindow = [self baseWindow];
    NSWindow *panelWindow = _newFileWindowController.window;
    dispatch_async(dispatch_get_main_queue(), ^{
        [projectWindow beginSheet:panelWindow completionHandler:nil];
    });
    
}

- (NSWindow *) baseWindow {
    
    for (NSWindowController *windowController in _document.windowControllers) {
        if (windowController.window.isKeyWindow)
            return windowController.window;
    }

    return [[_document.windowControllers firstObject] window];
}

#pragma mark - Project Docuemtn template
- (NSArray *) documentTemplatesArray {
    
    if (_documentTemplatesArray)
        return _documentTemplatesArray;
    
    
    NSString *documentTemplateFilePath = [self documentTemplateFilePathString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentTemplateFilePath])
        return NO;
    NSError *readingError;
    
    NSData *content = [NSData dataWithContentsOfFile:documentTemplateFilePath
                                             options:NSDataReadingUncached
                                               error:&readingError];
    
    if (!content || content.length == 0)
        return NO;
    
    NSPropertyListFormat format;
    NSArray * templatesArray = [NSPropertyListSerialization propertyListWithData:content
                                                                         options:NSPropertyListImmutable
                                                                          format:&format
                                                                           error:&readingError];

    if (!templatesArray || [templatesArray count] == 0)
        return nil;
    
    _documentTemplatesArray = [templatesArray firstObject][@"SectionItems"];

    return _documentTemplatesArray;
}

- (NSString *) documentTemplateFilePathString {
    NSURL *resourceURL = [[NSBundle mainBundle] resourceURL];
    NSString *urlString = [resourceURL.path stringByAppendingPathComponent:QCCProjectTemplatesFolder];
    urlString = [urlString stringByAppendingPathComponent:QCCDocumentTemplateFileName];
    return urlString;
}

#pragma mark - Project Template structure
- (QCCProjectEssence  *) instanceProjectStructure:(NSDictionary *) sourceConfiguration isTemplate:(BOOL) template {
    
    NSDictionary *groups = sourceConfiguration[QCCProjectSourceGroupKey];
    
    __block QCCProjectGroup *rootGroup;
    
    [groups enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {
        if (obj[QCCProjectSourceRootFileKey] && obj[QCCProjectSourceVirtualFileKey]) {
            rootGroup = [[QCCProjectGroup alloc] initWithDictionary:obj identifier:key projectURL:[_document fileURL]];
            rootGroup.path = _document.fileURL.lastPathComponent;
            *stop = YES;
        }
    }];
    
    [self attachGroupsToParent:rootGroup structure:sourceConfiguration isTemlate:template];
    [self attachFilesToParent:rootGroup structure:sourceConfiguration isTemlate:template];
    
    if (template)
        [[ self defaultFileManager] createFolder:_document.fileURL.path];
    
    [rootGroup monitor:YES];
    
    return rootGroup;
}

- (void) attachGroupsToParent:(QCCProjectGroup *) parent structure:(NSDictionary *) sourceConfiguration isTemlate:(BOOL) template {
    
    NSDictionary *groups = sourceConfiguration[QCCProjectSourceGroupKey];
    [groups enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {
        if ([obj[QCCProjectSourceParentKey] isEqualToString:parent.identifier]) {
            QCCProjectGroup *group = [[QCCProjectGroup alloc] initWithDictionary:obj identifier:key];
            group.parent  = parent;
            
            [self attachGroupsToParent:group structure:sourceConfiguration isTemlate:template];
            [self attachFilesToParent:group structure:sourceConfiguration isTemlate:template];
            
            if (template)
                [[ self defaultFileManager] createOnFilesystem:group];
        }
    }];
    
}

- (void) attachFilesToParent:(QCCProjectGroup *) parent structure:(NSDictionary *) sourceConfiguration isTemlate:(BOOL) template {
    
    NSDictionary *files = sourceConfiguration[QCCProjectSourceFileKey];
    [files enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {
        if ([obj[QCCProjectSourceParentKey] isEqualToString:parent.identifier]) {
            QCCProjectFile *file = [[QCCProjectFile alloc] initWithDictionary:obj identifier:key];
            file.parent = parent;
            
            if (template)
                [[ self defaultFileManager] createOnFilesystem:file withData:obj[QCCProjectSourceContentKey]];
        }
    }];
    
}

- (QCCProjectFileManager *) defaultFileManager {
    if ([_document respondsToSelector:@selector(projectFileManager)])
        return [_document projectFileManager];
    
    
    static QCCProjectFileManager *defaultFileManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultFileManager = [[QCCProjectFileManager alloc] initWithDocument:_document];
    });
    
    return defaultFileManager;
}

#pragma mark - Importing to Folder
- (NSArray *) essenceWithURLs:(NSArray *) URLs importedInGroup:(QCCProjectGroup *) rootGroup {
    NSLog(@"essenceWithURLs: %@", URLs);
    
    NSMutableArray *resultEssenceArray = [NSMutableArray new];
    NSURL *rootURL = [rootGroup fileURLWithProjectPath:[_document projectFolderPath]];
    
    
    [URLs enumerateObjectsUsingBlock:^(NSURL *essenceURL, NSUInteger idx, BOOL *stop) {
        NSUInteger rootURLComponentsCount = [[rootURL pathComponents] count];
        NSRange pathComponentsRange = NSMakeRange(rootURLComponentsCount, [[essenceURL pathComponents] count] - rootURLComponentsCount);
        NSArray *pathComponentsArray = [[essenceURL pathComponents] subarrayWithRange:pathComponentsRange];
        
        __block QCCProjectEssence *folder = rootGroup;
        __block QCCProjectEssence *subFolder = rootGroup;
        
        [pathComponentsArray enumerateObjectsUsingBlock:^(NSString *subFolderPath, NSUInteger idx, BOOL *stop) {
            subFolder = [folder childeEssenceForPath:subFolderPath];
            if (!subFolder) {
                __block QCCProjectEssence *newEssence = folder;
                NSArray *essencesForCreating = [pathComponentsArray subarrayWithRange:NSMakeRange(idx, [pathComponentsArray count] - idx)];
                
                [essencesForCreating enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                    BOOL isLastOne = ([essencesForCreating count] - 1 == idx);
                    newEssence = [self makeEssenceWithPath:path andParentGroup:newEssence recursive:isLastOne];
                    if (newEssence)
                        [resultEssenceArray addObject:newEssence];
                    
                }];
                *stop = YES;
            }
            else
                folder = subFolder;
        }];
    }];
    
    return resultEssenceArray;
}



- (QCCProjectEssence *) makeEssenceWithPath:(NSString *) path andParentGroup:(QCCProjectEssence *) group recursive:(BOOL) recursive {
    NSURL *groupURL = [group fileURLWithProjectPath:[_document projectFolderPath]];
    
    NSURL *essenceURL = [groupURL URLByAppendingPathComponent:path];
    
    BOOL isFolder;
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:essenceURL.path isDirectory:&isFolder];

    if (exist) {
        if (!isFolder) {
            // If it is exist, it is file, you have to check, is it exist in group
            
            if ([group childeEssenceForPath:path])
                return nil;
            
            QCCProjectFile *file = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : path} identifier:nil];
            file.parent = group;
            
            /* NSLog(@"make file WithPath:%@", file.path); */

            return file;
        }
        
        QCCProjectGroup *newGroup;
        // If it is exist, it is folder, you have to check, is it exist in group
        QCCProjectEssence *essence = [group childeEssenceForPath:path];
        BOOL groupExisted;
        if (essence) {
            if ([essence isKindOfClass:[QCCProjectFile class]]) {
                NSLog(@"Error, it is file class in model with path:%@", [essence fileURLWithProjectPath:[_document projectFolderPath]]);
            }
            
            if ([essence isKindOfClass:[QCCProjectGroup class]]) {
                newGroup = (QCCProjectGroup *) essence;
                groupExisted = YES;
            }
        }
        
        if (!newGroup) {
            newGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey : path} identifier:nil];
            newGroup.parent = group;
        }
        
        
        if (recursive && newGroup) {
            NSError *error;

            NSArray *children = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:essenceURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                               error:&error];
            
            
            
            [children enumerateObjectsUsingBlock:^(NSURL *essenceURL, NSUInteger idx, BOOL *stop) {
                
                QCCProjectEssence *essence = [self makeEssenceWithPath:[essenceURL lastPathComponent]
                                                        andParentGroup:newGroup
                                                             recursive:YES];
                essence.parent = newGroup;

                /* NSLog(@"added children:%@ to group:%@", essence.path, newGroup.path); */
            }];
            
        }
        
        // If it is existed, only add recursive items, don't return it.
        if (groupExisted)
            return nil;
        /*NSLog(@"make group WithPath:%@", newGroup.path);*/
        return newGroup;
    }
    
    
    return nil;
}



@end
