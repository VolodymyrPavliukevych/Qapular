//
//  QCCBorderedView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBorderedView.h"

@implementation QCCBorderedView

- (void) drawBorder {
    if (_borderType == QCCBorderedTypeNone || !self.borderColor)
        return;
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColorWithColor(context, self.borderColor.CGColor);
    
    
    // Top
    if (_borderType & QCCBorderedTypeTop) {
        CGContextFillRect(context, CGRectMake(0.0f, self.frame.size.height - 1, self.frame.size.width, 1.0));
    }
    
    // Left
    if (_borderType & QCCBorderedTypeLeft) {
        CGContextFillRect(context, CGRectMake(0.0f, 0.0, 1.0, self.frame.size.height));
    }
    // Right
    if (_borderType & QCCBorderedTypeRight) {
        CGContextFillRect(context, CGRectMake(self.frame.size.width - 1, 0.0, 1.0, self.frame.size.height));
    }
    // Buttom
    if (_borderType & QCCBorderedTypeButtom) {
        CGContextFillRect(context, CGRectMake(0.0f, 0, self.frame.size.width, 1.0));
    }
}


@end
