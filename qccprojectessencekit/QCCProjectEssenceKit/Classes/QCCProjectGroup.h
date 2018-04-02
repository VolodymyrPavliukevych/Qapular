//
//  QCCProjectGroup.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCCProjectEssence.h"

@class QCCProjectGroup;

@protocol QCCProjectGroupRootDelegate <NSObject>
- (void) invalidateGroup:(QCCProjectGroup *)group child:(BOOL) child;
@end

@interface QCCProjectGroup : QCCProjectEssence

- (void) monitor:(BOOL) monitor;
- (void) notifyRootWithObject:(QCCProjectGroup *) group child:(BOOL) child;

@end

@interface QCCProjectGroup(Root)

// Path URL for folder where content folder placed. Example: /Users/Roaming/Desktop/
@property (nonatomic, readonly, strong)    NSURL    *projectFolderURL;
// Path URL for project document url. Example: /Users/Roaming/Desktop/scetch.qccproj
@property (nonatomic, readonly, strong)    NSURL    *projectDocumentURL;

@property (nonatomic, weak) id <QCCProjectGroupRootDelegate> delegate;

- (instancetype) initWithDictionary:(NSDictionary *) dict identifier:(NSString *) identifier projectURL:(NSURL *) projectURL;
- (NSArray *) allChildrenURLsInRoot;

// Path URL for folder with content. Example: /Users/Roaming/Desktop/scetch/
- (NSString *) projectRootFolderPath;

@end
