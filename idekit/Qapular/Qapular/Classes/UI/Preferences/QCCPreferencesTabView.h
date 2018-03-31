//
//  QCCPreferencesTabView.h
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    QCCPreferencesTabViewItemGeneral,
    QCCPreferencesTabViewItemLibrary,
    QCCPreferencesTabViewItemCount,
} QCCPreferencesTabViewItem;

@class QCCPreferencesTabView;

@protocol QCCPreferencesTabViewDataSource <NSObject>
@required

- (NSUInteger) numberOfTabViewItemsForTabView:(nonnull NSTabView *) tabView;
- (nullable NSTabViewItem *) tabView:(nonnull NSTabView *) tabView tabViewItemForIndex:(NSUInteger) index;
- (void) setTabView:(nonnull QCCPreferencesTabView *) tabView;

@end

@interface QCCPreferencesTabView : NSTabView
@property (nullable, nonatomic, weak) IBOutlet  id <QCCPreferencesTabViewDataSource> dataSource;

@end
