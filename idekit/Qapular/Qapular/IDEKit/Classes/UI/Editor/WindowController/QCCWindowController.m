//
//  QCCWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCWindowController.h"
#import "QCCodeViewController.h"
#import "QCCBaseDocument.h"



@interface QCCWindowController () {
    QCCodeViewController    *_codeViewController;
    QCCBaseDocument         *_baseDocument;
}

@end

@implementation QCCWindowController

-(void)awakeFromNib {
    [super awakeFromNib];
    [self codeViewController];
}

- (QCCodeViewController *) codeViewController {
    if (_codeViewController)
        return _codeViewController;
    
    if ([self.contentViewController isKindOfClass:[QCCodeViewController class]]) {
        _codeViewController = (QCCodeViewController *) self.contentViewController;
        _codeViewController.windowController = self;

    }
    return _codeViewController;
}

-(void)setDocument:(QCCBaseDocument *) document {
    [super setDocument:document];
    if (!document)
        return;
    [_codeViewController replaceEditorDataSource:document];
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
}



-(NSViewController *)contentViewController {
    return [super contentViewController];
}

-(void)setContentViewController:(NSViewController *)contentViewController {
    [super setContentViewController:contentViewController];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    NSLog(@"Call: %s", __FUNCTION__);
    return YES;
}


@end
