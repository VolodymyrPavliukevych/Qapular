//
//  QCCImportPanel.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>


@protocol QCCImportPanelDataSource <NSObject>

@end

@interface QCCImportPanel : NSObject

- (instancetype) initWithRootURL:(NSURL *) rootURL excludeURLs:(NSArray *) excludeURLs allowedFileTypes:(NSArray *) allowedFileTypes  window:(NSWindow *) window;
- (void) importItems:(void(^)(NSArray *items, NSError *error)) completionBlock;

@end
