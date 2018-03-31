//
//  QCCDocumentController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCThemaManager;
@class QCCPreferences;

@class QCCTargetManager;
@class QCCSerialConsoleWindowController;

typedef NSUInteger QCCProcessDocumentOptions;

@interface QCCDocumentController : NSDocumentController <NSApplicationDelegate> {
    QCCSerialConsoleWindowController  *_serialConsoleWindowController;
}

@property (nonatomic, readonly) QCCThemaManager     *applicationThemaManager;
@property (nonatomic, readonly) QCCPreferences      *applicationPreferences;
@property (nonatomic, readonly) QCCTargetManager    *applicationTargetManager;

- (NSArray *) supportedTypesWithProject:(BOOL) project;

-(id) currentDocument;
- (void) showWelcomeWindow;
- (void) updateDocumentEnvironments;

@end
