//
//  QCCTabViewItem.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTabBarViewItem.h"
#import "QCCTabBarView.h"
#import "QCCView.h"
#import "QCCBorderedView.h"
#import "NSColor+QCColor.h"

@interface QCCTabBarViewItem () {
    
    BOOL    _selected;
}

@end

@implementation QCCTabBarViewItem


- (void) select:(BOOL) select {
    _selected = select;

    [self applyThema];
}

- (QCCTabBarView *) tabBarView {
    QCCTabBarView *tabBarView;
    if ([self.collectionView isKindOfClass:[QCCTabBarView class]])
        tabBarView = (QCCTabBarView *) self.collectionView;
    return tabBarView;
}

- (QCCBorderedView *) backgroundView {
    if ([self.view isKindOfClass:[QCCBorderedView class]])
        return (QCCBorderedView *) self.view;
    else
        return nil;
}
- (IBAction) performClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(closeTabWithIdentifier:)])
        [_delegate closeTabWithIdentifier:self.identifier];
}


-(void)awakeFromNib {
    [super awakeFromNib];
    if ([self.representedObject isKindOfClass:[NSDictionary class]]) {
        self.titleTextField.stringValue = self.representedObject[QCCTabBarViewContainerTitleKey];
        self.identifier = self.representedObject[QCCTabBarViewContainerIdentifierKey];
    }
    [self subscribeForNotifications];
    [self applyThema];

}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if ([_delegate respondsToSelector:@selector(selectTabWithIdentifier:)])
        [_delegate selectTabWithIdentifier:self.identifier];
}

- (void) applyThema {
    QCCBorderedView *backgroundView = [self backgroundView];
    backgroundView.backgroundColor = [[self tabBarView] backgroundColor:_selected];
    backgroundView.borderColor = [[self tabBarView] borderColor];
    backgroundView.borderType = QCCBorderedTypeRight | QCCBorderedTypeButtom ;
    _titleTextField.textColor = [[self tabBarView] labelColor];
}

#pragma mark - Notifications
- (void) subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themaManagerReplaced)
                                                 name:QCCThemaManagerReplacedNotification
                                               object:nil];
}

- (void) unsubscribe {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) themaManagerReplaced {
    [self applyThema];
}

-(void)dealloc {
    [self unsubscribe];
}

@end
