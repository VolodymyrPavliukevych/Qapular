//
//  QCCTemplateFileViewItem.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QCCTemplateFileViewItemDelegate <NSObject>

- (void) selectTemplate:(id) templateObject;

@end

@interface QCCTemplateFileViewItem : NSCollectionViewItem
@property (nonatomic, weak) IBOutlet id <QCCTemplateFileViewItemDelegate> delegate;
@end
