//
//  QCCWindow.m
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCWindow.h"

@interface QCCWindow ()

@end
@implementation QCCWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void) awakeFromNib {
    
    self.movableByWindowBackground = YES;
    self.backgroundColor = [NSColor clearColor];
    self.hasShadow = YES;
    self.opaque = NO;

    [self setStyleMask:NSBorderlessWindowMask | NSResizableWindowMask];
}

-(void)setContentViewController:(NSViewController *)contentViewController {
    [super setContentViewController:contentViewController];
}



- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    return YES;
}


#pragma mark - QCCWindowTitleBarDelegate
-(void)titleBarHandleActionWithButton:(NSWindowButton)button {
    switch (button) {
        case NSWindowCloseButton:
            [self close];
            break;
            
        case NSWindowMiniaturizeButton:
            [self miniaturize:nil];
            break;
            
        case NSWindowFullScreenButton:
            [self zoom:nil];
            break;
            
        default:
            break;
    }
}

@end
