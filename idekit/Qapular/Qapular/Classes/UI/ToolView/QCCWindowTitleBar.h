//
//  QCCWindowTitleBar.h
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCBaseToolView.h"
#import "QCCFamilyDocument.h"

@protocol QCCWindowTitleBarDelegate <NSObject>
@required
- (void) titleBarHandleActionWithButton:(NSWindowButton ) button;

@end

@interface QCCWindowTitleBar : QCCBaseToolView

@property (nonatomic, weak) id<QCCWindowTitleBarDelegate> delegate;

- (void) setTitle:(NSString *) title;

@end
