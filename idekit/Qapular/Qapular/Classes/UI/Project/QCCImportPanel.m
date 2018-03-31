//
//  QCCImportPanel.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCImportPanel.h"

@interface QCCImportPanel() <NSOpenSavePanelDelegate> {
    
    NSOpenPanel     *_openPanel;
    NSURL           *_rootURL;
    NSWindow        *_window;
    NSArray         *_excludeURLs;
}



@end

@implementation QCCImportPanel

- (instancetype) initWithRootURL:(NSURL *) rootURL excludeURLs:(NSArray *) excludeURLs allowedFileTypes:(NSArray *) allowedFileTypes  window:(NSWindow *) window {
    
    self = [super init];
    if (self) {
        _rootURL = rootURL;
        _window = window;
        _excludeURLs = excludeURLs;
        
        if (!rootURL || !window)
            return nil;
        
        _openPanel = [NSOpenPanel openPanel];
        
        NSString *folderString = [_rootURL.path lastPathComponent];
        NSString *title = NSLocalizedString(@"Import files to folder `%@`", @"Import panel");
        _openPanel.title = [NSString stringWithFormat:title, folderString];
        
        _openPanel.directoryURL = rootURL;
        _openPanel.allowedFileTypes = allowedFileTypes;
        _openPanel.allowsMultipleSelection = YES;
        _openPanel.canChooseDirectories = YES;
        _openPanel.delegate = self;
        _openPanel.canCreateDirectories = NO;
    }
    
    return self;
}


- (void) importItems:(void(^)(NSArray *items, NSError *error)) completionBlock {

    [_openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
            completionBlock(_openPanel.URLs, nil);
    }];
}


#pragma mark - NSOpenSavePanelDelegate
- (BOOL)panel:(NSOpenPanel *) panel shouldEnableURL:(NSURL *) url {
    if ([_excludeURLs containsObject:url])
        return NO;
    
    return  [self folder:_rootURL containsURL:url];
}

- (BOOL) folder:(NSURL *) folder containsURL:(NSURL *) target {
    
    NSString *rootFolderPathString = [[folder path] lowercaseString];
    NSString *urlTargetPathString = [[target path] lowercaseString];
    
    NSRange range =  [urlTargetPathString rangeOfString:rootFolderPathString];
    if (range.location == NSNotFound)
        return NO;
    
    if(range.location != 0 || range.length != rootFolderPathString.length)
        
        return NO;
    
    return YES;
    
}

@end
