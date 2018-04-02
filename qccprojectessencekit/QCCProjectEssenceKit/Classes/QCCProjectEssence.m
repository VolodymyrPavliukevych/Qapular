//
//  QCCProjectEssence.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "QCCProjectEssence.h"

@implementation QCCProjectEssence


NSString  *const  QCCProjectSourceConfigurationKey     =   @"SourceConfigurationKey";
NSString  *const  QCCProjectSourceFileKey              =   @"SourceFileKey";
NSString  *const  QCCProjectSourceVirtualFileKey       =   @"SourceVirtualFileKey";
NSString  *const  QCCProjectSourceRealFileNameKey      =   @"QCCProjectSourceRealFileNameKey";
NSString  *const  QCCProjectSourceRootFileKey          =   @"SourceRootFileKey";
NSString  *const  QCCProjectSourceParentKey            =   @"SourceParentKey";
NSString  *const  QCCProjectSourcePathKey              =   @"SourcePathKey";
NSString  *const  QCCProjectSourceISAKey               =   @"SourceISAKey";
NSString  *const  QCCProjectSourceFileTypeKey          =   @"SourceFileTypeKey";
NSString  *const  QCCProjectSourceContentKey           =   @"SourceContentKey";

NSString  *const  QCCProjectSourceGroupKey             =   @"SourceGroupKey";




- (instancetype) initWithDictionary:(NSDictionary *) dict identifier:(NSString *) identifier{
    self = [super init];
    
    if (self) {
        _children = [NSMutableArray new];
        NSNumber *isVirtual = dict[QCCProjectSourceVirtualFileKey];
        if (isVirtual) {
            _isVirtual = [isVirtual boolValue];
            _realFileName = dict[QCCProjectSourceRealFileNameKey];
        }
        
        NSNumber *root = dict[QCCProjectSourceRootFileKey] ;
        if (root)
            _root = [root boolValue];
        
        
        if (identifier)
            _identifier = identifier;
        else
            _identifier = [[NSUUID UUID] UUIDString];
        
        _path = dict[QCCProjectSourcePathKey];
        _valid = YES;
    }
    
    return self;
}

- (NSString *) description {
    
    NSString *description = [super description];
    
    return [NSString stringWithFormat:@"%@\n identifier:%@ path:%@ children:%@",
            description,
            _identifier,
            _path,
            _children];

}

- (NSString *) fileUTTString {
    
    NSString *extension = [self.path pathExtension];
    CFStringRef fileUTT = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)(extension), NULL);
    return (__bridge NSString *)(fileUTT);
    
}


- (NSArray *) pathComponents {
    NSMutableArray *pathArray = [NSMutableArray new];
    QCCProjectEssence *parent = self.parent;
    
    if (parent) {
        [pathArray addObjectsFromArray:[parent pathComponents]];
        [pathArray addObject:self.path];
        return pathArray;
    }
    else
        return nil;
}


- (NSURL *) fileURLWithProjectPath:(NSString *) filePrefix {
    NSString * pathInProject = [self pathInProjectFolder];
    NSString * fullFilePath = [filePrefix stringByAppendingPathComponent:pathInProject];
    NSURL *url =  [[NSURL alloc] initFileURLWithPath:fullFilePath
                                         isDirectory:[[self class] isFolderOnFileSystem]];
    return url;
}

+ (BOOL) isFolderOnFileSystem {
    return NO;
}

- (NSString *) pathInProjectFolder {
    return [[self pathComponents] componentsJoinedByString:@"/"];
}

- (NSDictionary *) serialize {

    NSMutableDictionary * selfDictionary = [NSMutableDictionary new];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSMutableDictionary *sourcesDictionary = [NSMutableDictionary new];
    sourcesDictionary[QCCProjectSourceFileKey]  = [NSMutableDictionary new];
    sourcesDictionary[QCCProjectSourceGroupKey]  = [NSMutableDictionary new];
    
    if (self.root)
        selfDictionary[QCCProjectSourceRootFileKey] = @(self.root);
    
    if (self.isVirtual)
        selfDictionary[QCCProjectSourceVirtualFileKey] = @(self.isVirtual);

    if (self.path)
        selfDictionary[QCCProjectSourcePathKey] = self.path;
    
    if (self.parent.identifier)
    selfDictionary[QCCProjectSourceParentKey] = self.parent.identifier;
    
    dictionary[self.identifier] = selfDictionary;

    sourcesDictionary[[self serializeGroupKey]] = dictionary;
    
    for(QCCProjectEssence *childe in self.children) {
        NSDictionary *serialize = [childe serialize];
        
        [sourcesDictionary[QCCProjectSourceFileKey] addEntriesFromDictionary:serialize[QCCProjectSourceFileKey]];
        [sourcesDictionary[QCCProjectSourceGroupKey] addEntriesFromDictionary:serialize[QCCProjectSourceGroupKey]];
        
    }
    
    return sourcesDictionary;
}

- (NSString *) serializeGroupKey {
    return QCCProjectSourceFileKey;
}

- (NSArray *) allChildren {

    NSMutableArray *children = [NSMutableArray new];
    
    for (QCCProjectEssence * childe in self.children) {
        [children addObjectsFromArray:[childe allChildren]];
        [children addObject:childe];
    }
    
    return children;
}

- (NSArray *) allChildrenURLsWithProjectPath:(NSString *) filePrefix {

    NSMutableArray *URLs = [NSMutableArray new];

    [self.allChildren enumerateObjectsUsingBlock:^(QCCProjectEssence * childe, NSUInteger idx, BOOL *stop) {
        [URLs addObject:[childe fileURLWithProjectPath:filePrefix]];
    }];
    
    return URLs;
    
}

- (QCCProjectEssence *) childeEssenceForPath:(NSString *) childePath {
   return [[[self children] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"path LIKE %@", childePath]] firstObject];
}

-(void)setParent:(QCCProjectEssence *)parent {
    _parent = parent;
    if (![parent.children containsObject:self])
        [parent.children addObject:self];
}

- (NSArray *) parents {
    NSMutableArray *pathArray = [NSMutableArray new];
    QCCProjectEssence *parent = self.parent;
    
    if (parent)
        [pathArray addObjectsFromArray:[parent parents]];
    
    [pathArray addObject:self];
    
    return pathArray;
}


@end

