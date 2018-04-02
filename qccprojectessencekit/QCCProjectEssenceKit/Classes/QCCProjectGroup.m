//
//  QCCProjectGroup.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "QCCProjectGroup.h"
#import "QCCProjectGroupMonitor.h"
#import "NSObject+Cast.h"
#import "QCCProjectFile.h"
#import <objc/runtime.h>


@interface QCCProjectGroup() {
    QCCProjectGroupMonitor *    _monitor;
}

@end

@implementation QCCProjectGroup


- (NSString *) serializeGroupKey {
    return QCCProjectSourceGroupKey;
}

+ (BOOL) isFolderOnFileSystem {
    return YES;
}

-(void)dealloc {
    [_monitor stopMonitoring];
}

-(void)setParent:(QCCProjectEssence *)parent {
    if (!parent)
        [self monitor:NO];
    
    [super setParent:parent];
    
    QCCProjectGroup *group = [[self parents] lastObject];
    if (group.root && [group respondsToSelector:@selector(projectFolderURL)]) {
        NSLog(@"need stop & start monitor");
    }
}

- (NSURL *) fullPath {
    if (self.root) {
        return [self projectFolderURL];
    }

    QCCProjectGroup *rootGroup = [[self parents] firstObject];
    
    if (rootGroup.root && [rootGroup respondsToSelector:@selector(projectFolderURL)]) {
        NSURL *URLPath = [[rootGroup projectFolderURL] URLByAppendingPathComponent:[self pathInProjectFolder]];
        return URLPath;
    }else
        return nil;
}

- (void) monitor:(BOOL) monitor {
    if (!monitor) {
        [_monitor stopMonitoring];
        _monitor = nil;
    }
    
    if (_monitor)
        return;
    
    NSURL *groupPathURL = [self fullPath];
    
    __weak QCCProjectGroup *weakSelf = self;
    
    _monitor = [QCCProjectGroupMonitor folderMonitorForURL:groupPathURL block:^{
        [weakSelf monitorEvent];
    }];
    
    [_monitor startMonitoring];
    
    for (QCCProjectEssence *essence in self.children) {
        [essence dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup * subGroup) {
            [subGroup monitor:YES];
        }];
    }
    
}

- (void) monitorEvent {
    [self invalidateGroup];
}

- (void) notifyRootWithObject:(QCCProjectGroup *) group child:(BOOL) child{
    if (self.root) {
        if([self.delegate respondsToSelector:@selector(invalidateGroup:child:)])
            [self.delegate invalidateGroup:group child:child];
    }else {
        
        [[self parent] dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup *parent) {
            [parent notifyRootWithObject:group child:child];
        }];
    }
}



- (void) invalidateGroup {
    
    BOOL updated = self.valid;
    
    NSURL *fullPath = [self fullPath];
    BOOL isDirectory;
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:fullPath.path isDirectory:&isDirectory];
    
    self.valid = (exist && isDirectory ? YES : NO);
    
    BOOL childrenUpdate = [self invalidateChildren];
    
    if (updated != self.valid || childrenUpdate)
        [self notifyRootWithObject:self child:childrenUpdate];
    
}


- (BOOL) invalidateChildren {

    __block BOOL update = NO;
    
    NSURL *groupPath = [self fullPath];
    
    [[self children] enumerateObjectsUsingBlock:^(QCCProjectEssence *child, NSUInteger idx, BOOL *stop) {
    if (child.isVirtual)
        return;

        [child dependClass:[QCCProjectFile class] performBlock:^(QCCProjectFile *file) {
            BOOL fileUpdated = file.valid;
            NSString *filePath = [groupPath.path stringByAppendingPathComponent:file.path];
            file.valid = [[NSFileManager defaultManager] fileExistsAtPath:filePath];

            if (!update)
                update = (fileUpdated != file.valid);
        }];
        
        [child dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup *subGroup) {
            [subGroup invalidateGroup];
        }];
    }];
    
    return update;
}


@end

@implementation QCCProjectGroup(Root)

//@dynamic delegate;

NSString const *QCCProjectEssenceRootFolderKey = @"QCCProjectEssenceRootFolderKey";
NSString const *QCCProjectEssenceRootDocumentKey = @"QCCProjectEssenceRootDocumentKey";
NSString const *QCCProjectEssenceRootDelegateKey = @"QCCProjectEssenceRootDelegateKey";

- (instancetype) initWithDictionary:(NSDictionary *) dict identifier:(NSString *) identifier projectURL:(NSURL *) projectURL {
    self = [super initWithDictionary:dict identifier:identifier];
    if (self) {
        self.root = YES;
        
        NSString *projectFileURL = [projectURL.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *documentFolder;
        
        if (dict[QCCProjectSourceVirtualFileKey] && [dict[QCCProjectSourceVirtualFileKey] boolValue] == YES)
            documentFolder = [[NSURL alloc] initWithString:[projectFileURL stringByDeletingPathExtension]];
        else
            documentFolder = [[NSURL alloc] initWithString:projectFileURL];
        
        objc_setAssociatedObject(self, &QCCProjectEssenceRootFolderKey, documentFolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        objc_setAssociatedObject(self, &QCCProjectEssenceRootDocumentKey, projectURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return self;
    
}

- (NSArray *) allChildrenURLsInRoot {
    
    if (!self.root)
        return nil;

    return [self allChildrenURLsWithProjectPath:[self projectRootFolderPath]];
    
}

- (NSString *) projectRootFolderPath {
    NSString *fullPath;
    
    if (self.isVirtual) {
        
        if (self.realFileName)
            fullPath = [self.projectFolderURL.path stringByAppendingPathComponent:self.realFileName];
        else
            fullPath = self.projectFolderURL.path;
    }else {
        fullPath = [self.projectFolderURL.path stringByAppendingPathComponent:self.path];
    }
    
    return fullPath;
    
}

-(NSURL *)projectDocumentURL {
    NSURL *result = objc_getAssociatedObject(self, &QCCProjectEssenceRootDocumentKey);
    return result;
}

-(NSURL *)projectFolderURL {
    NSURL *result = objc_getAssociatedObject(self, &QCCProjectEssenceRootFolderKey);
    return result;
}


-(void)setDelegate:(id<QCCProjectGroupRootDelegate>)delegate {
    objc_setAssociatedObject(self, &QCCProjectEssenceRootDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);

}

-(id<QCCProjectGroupRootDelegate>)delegate {
    id <QCCProjectGroupRootDelegate> object =  objc_getAssociatedObject(self, &QCCProjectEssenceRootDelegateKey);
    return object;
}


@end

