//
//  QCCDocumentController+NSOpenSavePanelDelegate.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/11/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCDocumentController+NSOpenSavePanelDelegate.h"

@implementation QCCDocumentController (NSOpenSavePanelDelegate)

#pragma mark - NSOpenSavePanelDelegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    /*
    NSError *error;
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                   includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&error];
    
    for (NSURL *url in items) {
        NSLog(@"%@", url);
    }
    */
    return YES;
}

@end
