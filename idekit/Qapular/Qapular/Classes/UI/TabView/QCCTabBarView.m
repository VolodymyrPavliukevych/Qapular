//
//  QCCTabsView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTabBarView.h"
#import "QCCTabBarViewItem.h"

@interface QCCTabBarView() {
    NSMutableArray  *_tabBatItems;
    
}
@property (nonatomic, strong) NSArrayController    *arrayController;
@end



NSString *const QCCTabBarViewContainerTitleKey = @"QCCTabBarViewContainerTitle";
NSString *const QCCTabBarViewContainerIdentifierKey = @"QCCTabBarViewContainerIdentifier";

const static CGSize QCCTabViewMinSize   =   {100, 25};


@implementation QCCTabBarView

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {

    self = [super awakeAfterUsingCoder:aDecoder];
    if (self) {
        self.maxItemSize = NSZeroSize;
        self.minItemSize = QCCTabViewMinSize;
        _arrayController = [[NSArrayController alloc] init];
        _tabBatItems = [NSMutableArray new];
        [self bind:NSContentBinding toObject:_arrayController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];

    }
    
    return self;
    
}

-(NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    
    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    if ([item isKindOfClass:[QCCTabBarViewItem class]]) {
        QCCTabBarViewItem *tabViewItem = (QCCTabBarViewItem *) item;
        tabViewItem.delegate = self;
        [_tabBatItems addObject:tabViewItem];
    }
    
    return item;
}




- (void) addTabWithTitle:(NSString *) title identifier:(NSString *) identifier {

    [_arrayController addObject:@{QCCTabBarViewContainerTitleKey: title,
                        QCCTabBarViewContainerIdentifierKey: identifier}];
}


#pragma mark - QCCTabBarViewItemDelegate
-(void)closeTabWithIdentifier:(NSString *)identifier {

    if (_tabsViewDelegate && [_tabsViewDelegate respondsToSelector:@selector(shouldCloseTabWithIdentifier:)]) {
        if ([_tabsViewDelegate shouldCloseTabWithIdentifier:identifier]) {
            // Deselect tab and change color
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
            [_tabBatItems removeObjectsInArray:[_tabBatItems filteredArrayUsingPredicate:predicate]];
            
            // Send action to tabViewController
            predicate = [NSPredicate predicateWithFormat:@"%K == %@", QCCTabBarViewContainerIdentifierKey, identifier];
            NSArray *willRemoveObjects = [[_arrayController arrangedObjects] filteredArrayUsingPredicate:predicate];
            [_arrayController removeObjects:willRemoveObjects];
            // And select first item.
            if ([_tabBatItems count] != 0)
                [self selectTabWithIdentifier:[[_tabBatItems firstObject] identifier]];
        }
    }
}

-(void)selectTabWithIdentifier:(NSString *)identifier {
    
    [_tabBatItems enumerateObjectsUsingBlock:^(QCCTabBarViewItem *tabBarViewItem, NSUInteger idx, BOOL *stop) {
        [tabBarViewItem select:([tabBarViewItem.identifier isEqualToString:identifier] ? YES : NO)];
    }];
    
    if ([_tabsViewDelegate respondsToSelector:@selector(selectTabWithIdentifier:)])
        [_tabsViewDelegate selectTabWithIdentifier:identifier];
}

#pragma mark - Appearance
- (NSColor *) borderColor {
    QCCThemaManager *themaManager;
    if ([_themaManagerDataSource respondsToSelector:@selector(themaManager)])
        themaManager = [_themaManagerDataSource themaManager];
    else
        return [NSColor redColor];
    
    return [themaManager projectWindowBorderColor];
}

- (NSColor *) backgroundColor:(BOOL) highlighted {
    QCCThemaManager *themaManager;
    if ([_themaManagerDataSource respondsToSelector:@selector(themaManager)])
        themaManager = [_themaManagerDataSource themaManager];
    else
        return [NSColor redColor];
    
    if (highlighted)
        return [themaManager projectWindowBackgroundHighlightedColor];
    else
        return [themaManager projectWindowBackgroundNormalColor];
}

- (NSColor *) labelColor {
    return [[_themaManagerDataSource themaManager] labelColor];
}


@end
