//
//  QCCFabricViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFabricViewController.h"

@interface QCCFabricViewController () {

    
}
@property (nonatomic, strong) NSMutableArray *documentsArray;
@end

@implementation QCCFabricViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.documentsArray = [NSMutableArray new];
    
}


/* 
 Show NSWindow as a toolbar sheet
 
 http://stackoverflow.com/questions/12075129/show-nswindow-as-a-toolbar-sheet
 
 
 [NSApp beginSheet:sheetWindow
 modalForWindow:mainWindow
 modalDelegate:self
 didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
 contextInfo:NULL];
 
 
 [savePanel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
 if (result != NSFileHandlingPanelOKButton) return;
 // Do something
 }];
 
 */
@end
