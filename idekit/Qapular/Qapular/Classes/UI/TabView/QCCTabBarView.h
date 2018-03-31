//
//  QCCTabsView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCThemaManager.h"
#import "QCCTabBarViewItem.h"

extern NSString *const QCCTabBarViewContainerTitleKey;
extern NSString *const QCCTabBarViewContainerIdentifierKey;

@protocol QCCTabBarViewDelegate <NSObject>
- (BOOL) shouldCloseTabWithIdentifier:(NSString *) identifier;
- (void) selectTabWithIdentifier:(NSString *) identifier;

@end

@interface QCCTabBarView : NSCollectionView <QCCTabBarViewItemDelegate>

@property (nonatomic, weak) IBOutlet id <QCCTabBarViewDelegate> tabsViewDelegate;
@property (nonatomic, weak) IBOutlet id <QCCThemaManagerDataSource> themaManagerDataSource;

- (void) selectTabWithIdentifier:(NSString *)identifier;
- (void) addTabWithTitle:(NSString *) title identifier:(NSString *) identifier;

#pragma mark - Appearance
- (NSColor *) borderColor;
- (NSColor *) backgroundColor:(BOOL) highlighted;
- (NSColor *) labelColor;
@end
