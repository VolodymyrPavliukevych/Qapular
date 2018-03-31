//
//  QCCPreferencesViewController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCPreferences;
@class QCCDocumentController;


@interface QCCPreferencesViewController : NSViewController
@property (nonatomic, strong) QCCPreferences *preferences;
@property (nonatomic, strong) QCCDocumentController *documentController;

- (NSSize) contentSize;

@end
