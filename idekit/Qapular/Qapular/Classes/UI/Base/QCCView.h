//
//  QCCView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCView : NSView

@property (nonatomic, strong) NSColor   *backgroundColor;
@property (nonatomic, strong) NSColor   *borderColor;

- (void) drawBackground;
- (void) drawBorder;

@end
