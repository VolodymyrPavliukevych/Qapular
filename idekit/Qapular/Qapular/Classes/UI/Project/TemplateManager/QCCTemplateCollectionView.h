//
//  QCCTemplateCollectionView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCTemplateFileViewItem.h"

@interface QCCTemplateCollectionView : NSCollectionView

@property (nonatomic, weak) IBOutlet id <QCCTemplateFileViewItemDelegate> fileTemplateDelegate;

@end
