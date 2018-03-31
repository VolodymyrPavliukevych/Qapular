//
//  QCCProjectTabView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectTabView.h"

@implementation QCCProjectTabView

-(void)addTabViewItem:(NSTabViewItem *)tabViewItem {
    [super addTabViewItem:tabViewItem];
    [_tabBarView addTabWithTitle:tabViewItem.label identifier:tabViewItem.identifier];
    [self.tabBarView selectTabWithIdentifier:tabViewItem.identifier];
}



#pragma mark - QCCTabBarViewDelegate
- (BOOL) shouldCloseTabWithIdentifier:(NSString *) identifier {
    
    NSUInteger index = [self indexOfTabViewItemWithIdentifier:identifier];
    if (index == NSNotFound)
        return NO;
    
    NSTabViewItem *item = [self tabViewItemAtIndex:index];
    [self removeTabViewItem:item];
    
    return YES;
}

-(void)selectTabWithIdentifier:(NSString *)identifier {
    [self selectTabViewItemWithIdentifier:identifier];
}

#pragma mark - NSTabViewDelegate
/*
 - (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
 - (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem;
 - (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
 - (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView;
 */

#pragma mark - NSToolbarDelegate
/*
 - (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
 - (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
 - (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
 - (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar;
 - (void)toolbarWillAddItem:(NSNotification *)notification;
 - (void)toolbarDidRemoveItem:(NSNotification *)notification;
 */

@end
