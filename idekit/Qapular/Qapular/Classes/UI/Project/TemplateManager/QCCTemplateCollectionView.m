//
//  QCCTemplateCollectionView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTemplateCollectionView.h"
#import "QCCTemplateFileViewItem.h"
#import "NSObject+Cast.h"

@interface QCCTemplateCollectionView() <QCCTemplateFileViewItemDelegate>

@end

@implementation QCCTemplateCollectionView

-(NSCollectionViewItem *)newItemForRepresentedObject:(id)object {

    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    [item dependClass:[QCCTemplateFileViewItem class] performBlock:^(QCCTemplateFileViewItem * object) {
        object.delegate = self;
    }];
    
    
    return item;
    
}

#pragma mark - QCCTemplateFileViewItemDelegate
-(void)selectTemplate:(id)templateObject {
    
    if ([_fileTemplateDelegate respondsToSelector:@selector(selectTemplate:)])
        [_fileTemplateDelegate selectTemplate:templateObject];
}

@end
