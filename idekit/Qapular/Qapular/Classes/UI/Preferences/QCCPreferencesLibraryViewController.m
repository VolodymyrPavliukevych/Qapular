//
//  QCCPreferencesLibraryViewController.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPreferencesLibraryViewController.h"

@interface QCCPreferencesLibraryViewController () <NSTableViewDataSource> {
}

@property (nullable, nonatomic, weak) IBOutlet NSTableView  *tableView;

@end

@implementation QCCPreferencesLibraryViewController


-(void)viewWillAppear {
    [self reloadContent];
}

- (void) reloadContent {
    [_tableView reloadData];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[[self dataSource] libraryURLs] count];
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *array = [[self dataSource] libraryURLs];
    
    if ([array count] > row)
        return array[row];
    return nil;
}

-(IBAction) addAction:(id)sender {
    [[self delegate] addLibraryFolder];
}

-(IBAction) removeAction:(id)sender {
    NSArray *items = [[self dataSource] libraryURLs];
    if ([items count] <= _tableView.selectedRow)
        // wrong index
        return;
    
    [[self delegate] removeLibraryFolder:items[_tableView.selectedRow]];
}


@end
