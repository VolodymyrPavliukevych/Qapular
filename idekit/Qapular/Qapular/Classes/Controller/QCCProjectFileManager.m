//
//  QCCProjectFileManager.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectFileManager.h"
#import "QCCBaseProjectDocument+Dialog.h"

#import "QCCBaseDocument.h"
#import "NSObject+Cast.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

@interface QCCProjectFileManager() {
    QCCBaseProjectDocument *_document;
}

@end
@implementation QCCProjectFileManager

- (instancetype) initWithDocument:(QCCBaseProjectDocument *) document {
    if (!document)
        return nil;
    self = [super init];
    if (self) {
        _document = document;
    }
    
    return self;
}

#pragma mark - QCCProjectFileManagerDelegate
- (void) moveItemToTrash:(QCCProjectEssence *) essence completition:(void (^)(BOOL sucess)) block {
    
    NSURL *fileURL = [essence fileURLWithProjectPath:[_document projectFolderPath]];
    
    if (!fileURL || !essence) {
        block(NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[NSWorkspace sharedWorkspace] recycleURLs:@[fileURL] completionHandler:^(NSDictionary *newURLs, NSError *error) {
            block((!error));
        }];
    });
}

- (void) showItemInFinder:(QCCProjectEssence *) essence completition:(void (^)(BOOL sucess)) block {

    if ([essence isKindOfClass:[QCCProjectGroup class]]) {
        NSURL *groupURL = [essence fileURLWithProjectPath:[_document projectFolderPath]];
        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:groupURL.path];
    }else {
        NSURL *fileURL = [essence fileURLWithProjectPath:[_document projectFolderPath]];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
    }
    
}


- (BOOL) createOnFilesystem:(QCCProjectEssence *) essence {
    return [self createOnFilesystem:essence withData:nil];
}

- (BOOL) createOnFilesystem:(QCCProjectEssence *) essence withData:(NSData *) content {
    // make folders
    NSString *fullPath = [NSString new];
    
    if ([essence isKindOfClass:[QCCProjectGroup class]]) {
        
        for (NSString *path in [self pathComponentsForEssence:essence]) {
            // creating all folder to folder destination
            fullPath = [fullPath stringByAppendingPathComponent:path];
            if (![self createFolder:fullPath])
                return NO;
        }
        
    }else if ([essence isKindOfClass:[QCCProjectFile class]]) {
        
        NSString *fullPath = [NSString new];
        NSError *error;
        // Creating all folders to file destination
        for (NSString *path in [self pathComponentsForEssence:essence]) {
            fullPath = [fullPath stringByAppendingPathComponent:path];
            
            if (path == [[self pathComponentsForEssence:essence] lastObject]) {
                BOOL created = [content writeToFile:fullPath options:NSDataWritingAtomic error:&error];
                if (error)
                    NSLog(@"Error: %@", error);
                
                if (!created)
                    return created;
                
                
            }else {
                if (![self createFolder:fullPath])
                    return NO;
            }
        }
    }
    
    return YES;
    
}

- (BOOL) createFolder:(NSString *) fullPath {
    NSError *error;
    BOOL isFolder;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isFolder]) {
        BOOL created =[[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                                withIntermediateDirectories:NO
                                                                 attributes:nil
                                                                      error:&error];
        if (error)
            NSLog(@"Error: %@", error);
        
        if (!created)
            return created;
        
    }else  {
        // exist, is it folder ?
        if (!isFolder)
            return NO;
        else
            return YES;
        
    }
    
    return YES;
}


#pragma mark - Helper

- (NSArray *) pathComponentsForEssence:(QCCProjectEssence *) essence {
    NSMutableArray *pathArray = [NSMutableArray new];
    QCCProjectEssence *parent = essence.parent;
    if (parent) {
        [pathArray addObjectsFromArray:[self pathComponentsForEssence:parent]];
        [pathArray addObject:essence.path];
        return pathArray;
    }
    else
        return @[[_document.fileURL.path stringByDeletingPathExtension]];
}

- (BOOL) essenceExists:(QCCProjectEssence *) essence inProjectPath:(NSString *) projectPath {
    NSURL *pathURL = [essence fileURLWithProjectPath:projectPath];
    return [[NSFileManager defaultManager] fileExistsAtPath:pathURL.path isDirectory:nil];
}

@end
