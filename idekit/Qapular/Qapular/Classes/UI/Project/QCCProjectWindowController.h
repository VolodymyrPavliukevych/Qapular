//
//  QCCProjectWindowController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCProjectDocument.h"
#import "QCCSourceTreeController.h"
#import "QCCTabBarView.h"
#import "QCCOutlineView.h"
#import "QCCProjectTabView.h"
#import "QCCBorderedView.h"
#import "QCCNavigationAreaViewController.h"
#import "QCCThemaManager.h"
#import "QCCManipulationTabView.h"
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@interface QCCProjectWindowController : NSWindowController <NSSplitViewDelegate, QCCThemaManagerDataSource, QCCDeploymentConfigurationProvider>

@property (nonatomic, weak, readonly) id<QCCProjectDataSource> projectDataSource;

@property (nonatomic, weak)     IBOutlet    QCCOutlineView                  *sourceTreeOutlineView;
@property (nonatomic, weak)     IBOutlet    QCCSourceTreeController         *sourceTreeController;
@property (nonatomic, weak)     IBOutlet    QCCProjectTabView               *projectTabView;

@property (nonatomic, weak)     IBOutlet    QCCBorderedView                 *navigationAreaToolBarView;
@property (nonatomic, weak)     IBOutlet    QCCNavigationAreaViewController *navigationAreaViewController;
@property (nonatomic, weak)     IBOutlet    QCCBorderedView                 *navigationAreaView;

@property (nonatomic, weak)     IBOutlet    QCCManipulationTabView          *manipulationTabView;
@property (nonatomic, strong)   IBOutlet    NSTextView                      *debugTextView;



+ (instancetype)initFromDefaultWindowNib;

- (IBAction) runButtonAction:(NSButton *)sender;
- (IBAction) stopButtonAction:(NSButton *)sender;
- (IBAction) uploadButtonAction:(NSButton *) sender;

@end
