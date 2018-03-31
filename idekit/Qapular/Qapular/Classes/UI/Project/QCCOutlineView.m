//
//  QCCOutlineView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCOutlineView.h"

@implementation QCCOutlineView
static dispatch_once_t onceToken;
static NSColor  *selectedRowBackgroundColor;

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self = [super awakeAfterUsingCoder:aDecoder];
    if (self) {
        [self setDoubleAction:@selector(doubleClick:)];
    }
    
    return self;
}

- (void) doubleClick:(id) sender {
    if ([_outlineViewDelegate respondsToSelector:@selector(outlineView:didDoubleClickOnColumn:row:)])
        [_outlineViewDelegate outlineView:self didDoubleClickOnColumn:self.clickedColumn row:self.clickedRow];
}

-(void)setThemaManagerDataSource:(id<QCCThemaManagerDataSource>)themaManagerDataSource {
    
    onceToken = 0;
    selectedRowBackgroundColor = nil;
    
    _themaManagerDataSource = themaManagerDataSource;
    [self reloadData];
}

- (NSColor *) selectedRowBackgroundColor {

    dispatch_once(&onceToken, ^{
        selectedRowBackgroundColor = [[_themaManagerDataSource themaManager] sourceTreeRowSelectedBackgroundColor];
    });
    
    return selectedRowBackgroundColor;
}

#pragma mark - QCCSourcetreeControllerInterfaceDelegate
-(void)invalidateItem:(id)item children:(BOOL)children {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadItem:item reloadChildren:children];
    });
    
}
-(void)invalidateGroup:(id)group {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger row = [self rowForItem:group];
        if (row == -1)
            [self reloadData];
        else
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    });
}

@end
