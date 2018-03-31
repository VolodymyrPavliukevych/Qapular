//
//  QCCProjectWindow.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectWindow.h"
#import "QCCProjectWindowController.h"

#import "QCCWindowTitleBar.h"
#import "QCCStatusBar.h"
#import "QCCSplitView.h"

@interface QCCProjectWindow() {

    QCCProjectWindowController      *_projectWindowController;
    
}

@property (nonatomic, weak) IBOutlet QCCWindowTitleBar      *titleBar;
@property (nonatomic, weak) IBOutlet QCCStatusBar           *statusBar;
@property (nonatomic, weak) IBOutlet QCCSplitView           *splitView;

@end

@implementation QCCProjectWindow

-(void)setWindowController:(NSWindowController *)windowController {
    [super setWindowController:windowController];
    
    if ([windowController isKindOfClass:[QCCProjectWindowController class]])
        _projectWindowController = (QCCProjectWindowController *) windowController;
}

-(void)setTitleBar:(QCCWindowTitleBar *)titleBar {
    _titleBar =  titleBar;
    _titleBar.delegate = self;
    [_titleBar setThemaManager:[_projectWindowController.projectDataSource themaManager]];
}
-(void)setStatusBar:(QCCStatusBar *)statusBar {
    _statusBar = statusBar;
    [_statusBar setThemaManager:[_projectWindowController.projectDataSource themaManager]];
}


-(void)setContentViewController:(NSViewController *)contentViewController {
    NSLog(@"%s %@", __FUNCTION__, contentViewController);
}


@end
