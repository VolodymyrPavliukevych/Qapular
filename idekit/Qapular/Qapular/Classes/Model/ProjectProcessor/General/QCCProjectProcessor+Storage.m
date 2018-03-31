//
//  QCCProjectProcessor+Storage.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectProcessor+Storage.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

static NSString *const QCCProjectProcessorFolderName = @"builds";

@implementation QCCProjectProcessor (Storage)

+ (NSString *) storageFolder {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* applicationSupportFolders = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    
    if ([applicationSupportFolders count] == 0)
        return nil;
    
    NSString *customBundleIdentifier  = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *mainBundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *bundleIdentifier = (mainBundleIdentifier ? mainBundleIdentifier : customBundleIdentifier);
    
    NSError *error;
    NSURL *applicationSupportFolder = [applicationSupportFolders firstObject];
    NSString *rootFolderPath = [[applicationSupportFolder path] stringByAppendingPathComponent:bundleIdentifier];
    
    if (![fileManager fileExistsAtPath:rootFolderPath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    NSString *packageFolderPath = [rootFolderPath stringByAppendingPathComponent:QCCProjectProcessorFolderName];
    if (![fileManager fileExistsAtPath:packageFolderPath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:packageFolderPath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    return packageFolderPath;
}

+ (QCCProjectGroup *) sourceForPathString:(NSString *) path {
    return [QCCProjectProcessor sourceForPathString:[path stringByDeletingLastPathComponent] groupName:[path lastPathComponent]];
}

+ (QCCProjectGroup *) sourceForPathString:(NSString *) path groupName:(NSString *) groupName {
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    if (!url)
        return nil;
    QCCProjectGroup *arduinoCoreSourceGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey: groupName,
                                                                                            QCCProjectSourceRootFileKey : @(YES)}
                                                                               identifier:nil
                                                                               projectURL:url];
    NSError *error;
    NSString *folder = [arduinoCoreSourceGroup.projectFolderURL.path stringByAppendingPathComponent:arduinoCoreSourceGroup.path];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    
    for (NSString *file in files) {
        
        //if ([[file pathExtension] isEqualToString:@"cpp"] || [[file pathExtension] isEqualToString:@"c"] || [[file pathExtension] isEqualToString:@"S"]) {
            QCCProjectFile *projectFile = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : file} identifier:nil];
            projectFile.parent = arduinoCoreSourceGroup;
        //}
    }
    return arduinoCoreSourceGroup;
}

@end
