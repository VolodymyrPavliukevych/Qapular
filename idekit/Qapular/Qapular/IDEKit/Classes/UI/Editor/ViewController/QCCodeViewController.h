//
//  QCCodeViewController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCWindowController.h"
#import "QCCBaseDocument.h"

@class QCCWindowController;

@interface QCCodeViewController : NSViewController
@property (nonatomic, weak) QCCWindowController *windowController;

- (void) replaceEditorDataSource:(id<QCCEditorDataSource>) editorDataSource;

@end
