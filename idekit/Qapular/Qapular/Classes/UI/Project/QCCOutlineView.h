//
//  QCCOutlineView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCThemaManager.h"
#import "QCCSourcetreeControllerInterfaceDelegate.h"


@class QCCOutlineView;

@protocol QCCOutlineViewDelegate <NSObject>
- (void) outlineView:(QCCOutlineView *) outlineView didDoubleClickOnColumn:(NSUInteger) columnt row:(NSUInteger) row;
@end

@interface QCCOutlineView : NSOutlineView <NSMenuDelegate, QCCSourcetreeControllerInterfaceDelegate>
@property (nonatomic, weak) IBOutlet id <QCCOutlineViewDelegate> outlineViewDelegate;
@property (nonatomic, weak) id <QCCThemaManagerDataSource> themaManagerDataSource;

- (NSColor *) selectedRowBackgroundColor;

@end
