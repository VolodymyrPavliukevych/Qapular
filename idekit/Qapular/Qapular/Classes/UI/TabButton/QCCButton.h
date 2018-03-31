//
//  QCCButton.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef enum : NSUInteger {
    QCCButtonStateOff,
    QCCButtonStateOn,
} QCCButtonState;

@interface QCCButton : NSButton

@property (nonatomic, strong) NSColor   *tintColor;
@property (nonatomic, strong) NSColor   *selectedTintColor;
@property (nonatomic, strong) NSColor   *backgroundColor;
@end
