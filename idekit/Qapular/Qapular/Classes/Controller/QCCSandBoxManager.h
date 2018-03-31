//
//  QCCSandBoxManager.h
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/11/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCSandBoxManager : NSObject

+ (BOOL) saveBookmarkForURL:(NSURL *) url relatedKey:(NSString *) key;
+ (BOOL) saveBookmarkForURL:(NSURL *) url relatedProjectURL:(NSURL *) projectDocumentURL;

+ (BOOL) restoreAccessToProjectURL:(NSURL *) projectDocumentURL;
+ (void) closeAccessToProjectURL:(NSURL *) projectDocumentURL;

+ (void) closeAccessForKey:(NSString *) key;
+ (BOOL) restoreAccessForKey:(NSString *) key;

@end
