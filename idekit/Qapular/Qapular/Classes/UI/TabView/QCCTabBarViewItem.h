//
//  QCCTabViewItem.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QCCTabBarViewItemDelegate <NSObject>

- (void) closeTabWithIdentifier:(NSString *) identifier;
- (void) selectTabWithIdentifier:(NSString *) identifier;

@end

@interface QCCTabBarViewItem : NSCollectionViewItem

@property (nonatomic, weak) IBOutlet    NSTextField     * titleTextField;
@property (nonatomic, weak) IBOutlet    NSButton        * closeButton;
//@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, weak) id <QCCTabBarViewItemDelegate> delegate;

- (IBAction) performClose:(id)sender;
- (void) select:(BOOL) select;

@end
