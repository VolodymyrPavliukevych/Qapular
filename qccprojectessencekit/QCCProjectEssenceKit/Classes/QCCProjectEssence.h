//
//  QCCProjectEssence.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString  *const  QCCProjectSourceFileKey;
extern NSString  *const  QCCProjectSourceVirtualFileKey;
extern NSString  *const  QCCProjectSourceRealFileNameKey;
extern NSString  *const  QCCProjectSourceRootFileKey;
extern NSString  *const  QCCProjectSourceParentKey;
extern NSString  *const  QCCProjectSourcePathKey;
extern NSString  *const  QCCProjectSourceISAKey;
extern NSString  *const  QCCProjectSourceFileTypeKey;
extern NSString  *const  QCCProjectSourceContentKey;

extern NSString  *const  QCCProjectSourceGroupKey;



@interface QCCProjectEssence : NSObject

@property (nonatomic, strong)   NSString                *identifier;
@property (nonatomic, strong)   NSString                *path;
@property (nonatomic)           BOOL                    isVirtual;
@property (nonatomic, strong)   NSString                *realFileName;
@property (nonatomic)           BOOL                    root;
@property (nonatomic, strong)   NSMutableArray          *children;
@property (nonatomic, strong)   QCCProjectEssence       *parent;
@property (nonatomic, getter=isValid)   BOOL            valid;



- (instancetype) initWithDictionary:(NSDictionary *) dict identifier:(NSString *) identifier ;
- (NSArray *) pathComponents;
- (NSString *) pathInProjectFolder;

- (NSURL *) fileURLWithProjectPath:(NSString *) filePrefix;
+ (BOOL) isFolderOnFileSystem;

- (NSArray *) allChildren;
- (NSArray *) allChildrenURLsWithProjectPath:(NSString *) filePrefix;
- (QCCProjectEssence *) childeEssenceForPath:(NSString *) childePath;
- (NSArray *) parents;

- (NSDictionary *) serialize;
- (NSString *) serializeGroupKey;
- (NSString *) fileUTTString;

@end

