//
//  QCCPreferencesWindowController.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPreferencesWindowController.h"
#import "QCCPreferencesTabView.h"
#import "QCCPreferencesViewController.h"
#import "QCCDocumentController.h"
#import "QCCPreferences.h"
#import "QCCPreferencesLibraryViewController.h"

@interface QCCPreferencesWindowController () <NSToolbarDelegate, NSTabViewDelegate, QCCPreferencesTabViewDataSource, QCCPreferencesTabViewDataSource, QCCPreferencesLibraryDataSource, QCCPreferencesLibraryDelegate> {
    QCCPreferencesLibraryViewController *_preferencesLibraryViewController;
}
@property (nullable, nonatomic, strong) QCCPreferencesTabView  *preferencesTabView;
@end

@implementation QCCPreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
}


#pragma mark - QCCPreferencesTabViewDataSource
- (void) setTabView:(nonnull QCCPreferencesTabView *) tabView {
    _preferencesTabView = tabView;
}

- (NSUInteger) numberOfTabViewItemsForTabView:(nonnull NSTabView *) tabView {
    return QCCPreferencesTabViewItemCount;
}

- (nullable NSTabViewItem *) tabView:(nonnull NSTabView *) tabView tabViewItemForIndex:(NSUInteger) index {
    return [NSTabViewItem tabViewItemWithViewController:[self preferencesViewControllerForTabViewItem:index]];
}

- (NSViewController *) preferencesViewControllerForTabViewItem:(QCCPreferencesTabViewItem) item {

    if (item == QCCPreferencesTabViewItemGeneral) {
        QCCPreferencesViewController *preferencesViewController = [[QCCPreferencesViewController alloc] initWithNibName:NSStringFromClass([QCCPreferencesViewController class])
                                                                                                                 bundle:[NSBundle mainBundle]];
        preferencesViewController.identifier = @"General";
        
        preferencesViewController.preferences = self.documentController.applicationPreferences;
        preferencesViewController.documentController = self.documentController;
        return preferencesViewController;
    }else if  (item == QCCPreferencesTabViewItemLibrary) {
        if (_preferencesLibraryViewController)
            return _preferencesLibraryViewController;
        
        _preferencesLibraryViewController = [[QCCPreferencesLibraryViewController alloc] initWithNibName:NSStringFromClass([QCCPreferencesLibraryViewController class])
                                                                                                                                      bundle:[NSBundle mainBundle]];
        
        _preferencesLibraryViewController.delegate = self;
        _preferencesLibraryViewController.dataSource = self;
        _preferencesLibraryViewController.identifier = @"Library";
        return _preferencesLibraryViewController;
    }
    
    return nil;
}

- (IBAction) selectToolBarItem:(NSToolbarItem *) item {
    if (item.tag == [_preferencesTabView indexOfTabViewItem:_preferencesTabView.selectedTabViewItem])
        return;
    
    /*
     if (item.tag == QCCPreferencesTabViewItemGeneral) {
        frame = NSMakeRect(frame.origin.x, frame.origin.y, size.width, size.height);
    }else if  (item.tag == QCCPreferencesTabViewItemLibrary) {
        frame = NSMakeRect(frame.origin.x, frame.origin.y, size.width, size.height);
    }
    [self.window setFrame:frame display:YES animate:YES];
    */
    
    [_preferencesTabView selectTabViewItemAtIndex:item.tag];    
    self.window.title = _preferencesTabView.selectedTabViewItem.viewController.identifier;
}

#pragma mark - QCCPreferencesTabViewDataSource


#pragma mark - Ceate Panel

- (void) showOpenPanelWithSucsessBlock:(void (^)(NSURL *fileURL)) block {
    
    NSOpenPanel *openLibraryPanel = [NSOpenPanel openPanel];
    openLibraryPanel.canChooseFiles = NO;
    openLibraryPanel.canChooseDirectories = YES;
    openLibraryPanel.canCreateDirectories = YES;
    openLibraryPanel.allowsMultipleSelection = NO;
    openLibraryPanel.message = NSLocalizedString(@"Please, select your library folder.", nil);
    
    openLibraryPanel.directoryURL = [self defaultURL];
    openLibraryPanel.allowedFileTypes = @[];
    openLibraryPanel.allowsOtherFileTypes = NO;
    
    [openLibraryPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            block(openLibraryPanel.URL);
        }
    }];
    
}

#pragma mark - Helper
- (NSURL *) defaultURL {
    
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask,YES);
    id path = [pathArray firstObject];
    if (![path isKindOfClass:[NSString class]])
        return nil;
    NSString *pathString = [NSString stringWithString:path];
    return [NSURL URLWithString:pathString];
    
}


#pragma mark - QCCPreferencesLibraryDataSource
-(NSArray<NSURL *> *)libraryURLs {
    return [_documentController.applicationPreferences libraryURLList];
}

#pragma mark - QCCPreferencesLibraryDelegate
-(void)addLibraryFolder {
    [self showOpenPanelWithSucsessBlock:^(NSURL *fileURL) {
        [_documentController.applicationPreferences addLibraryURL:fileURL];
        [_preferencesLibraryViewController reloadContent];
    }];
}

-(void)removeLibraryFolder:(NSURL *) folderURL {
    [_documentController.applicationPreferences removeLibraryURL:folderURL.absoluteString];
    [_preferencesLibraryViewController reloadContent];
}


@end
