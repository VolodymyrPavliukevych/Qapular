//
//  QCCSandBoxManager.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/11/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCSandBoxManager.h"

@implementation QCCSandBoxManager

static NSString * QCCSandBoxBookmarksKey = @"QCCSandBoxBookmarks";

+ (BOOL) saveBookmarkForURL:(NSURL *) url relatedKey:(NSString *) key {
    NSError *error;
    
    NSData * bookmarkData = [url
                             bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                             includingResourceValuesForKeys:nil
                             relativeToURL:nil
                             error:&error];
    
    if (bookmarkData && key) {
        [self saveBookmarkData:bookmarkData forKey:key];
        NSLog(@"bookmark saved for project %@", key);
    }
    
    if (error) {
        NSLog(@"Can't do Security Scope Bookmark: %@", error);
        return NO;
    }
    
    return YES;
}

+ (BOOL) saveBookmarkForURL:(NSURL *) url relatedProjectURL:(NSURL *) projectDocumentURL {
    return [self saveBookmarkForURL:url relatedKey:projectDocumentURL.absoluteString];
}

+ (BOOL) restoreAccessForKey:(NSString *) key {
    
    NSURL *bookmark = [self restoreBookmarkURLForKey:key];
    if (bookmark)
        NSLog(@"restore : %@", bookmark);
    return [bookmark startAccessingSecurityScopedResource];
}

+ (BOOL) restoreAccessToProjectURL:(NSURL *) projectDocumentURL {
    
    NSURL *bookmark = [self restoreBookmarkURLForProjectURL:projectDocumentURL];
    if (bookmark)
        NSLog(@"restore : %@", bookmark);
    return [bookmark startAccessingSecurityScopedResource];
}

+ (void) closeAccessForKey:(NSString *) key {
    NSURL *bookmark = [self restoreBookmarkURLForKey:key];
    NSLog(@"close access to: %@ for key %@", bookmark, key);
    [bookmark stopAccessingSecurityScopedResource];
}

+ (void) closeAccessToProjectURL:(NSURL *) projectDocumentURL {
    
    NSURL *bookmark = [self restoreBookmarkURLForProjectURL:projectDocumentURL];
    NSLog(@"close access to: %@ for project %@", bookmark, projectDocumentURL);
    [bookmark stopAccessingSecurityScopedResource];
    
}

+ (NSURL *) restoreBookmarkURLForProjectURL:(NSURL *) projectDocumentURL {
    
    NSString *key = projectDocumentURL.absoluteString;
    if ([key hasSuffix:@"/"]) {
        key = [key substringWithRange:NSMakeRange(0, key.length - 1)];
    }
    return [self restoreBookmarkURLForKey:key];
}

+ (NSURL *) restoreBookmarkURLForKey:(NSString *) key {
    NSData *bookmarkData = [[self bookmarks] objectForKey:key];
    if (!bookmarkData)
        return nil;
    NSLog(@"Restore %lu bookmark byte", (unsigned long)bookmarkData.length);
    NSError *error = nil;
    BOOL bookmarkDataIsStale;
    NSURL *bookmarkFileURL = nil;
    
    bookmarkFileURL = [NSURL
                       URLByResolvingBookmarkData:bookmarkData
                       options:NSURLBookmarkResolutionWithSecurityScope
                       relativeToURL:nil
                       bookmarkDataIsStale:&bookmarkDataIsStale
                       error:&error];
    
    if (error)
        NSLog(@"Can't restore access: %@", error);

    
    return bookmarkFileURL;
}

+ (NSMutableDictionary *) bookmarks {
    
    NSMutableDictionary *bookmarks;
    
    id storage = [[NSUserDefaults standardUserDefaults] objectForKey:QCCSandBoxBookmarksKey];
    
    if (storage && [storage isKindOfClass:[NSDictionary class]]) {
        bookmarks = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) storage];
    }else {
        bookmarks = [NSMutableDictionary new];
    }
    
    return bookmarks;
}

+ (void) saveBookmarkData:(NSData *) bookmarkData forKey:(NSString *) key {
    
    NSMutableDictionary *bookmarks = [self bookmarks];
    
    if (bookmarkData && key) {
        bookmarks[key] = bookmarkData;
        
        [[NSUserDefaults standardUserDefaults] setObject:bookmarks forKey:QCCSandBoxBookmarksKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
