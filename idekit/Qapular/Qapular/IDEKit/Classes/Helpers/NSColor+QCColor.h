//
//  NSColor+QCColor.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (QCColor)


+ (NSColor *) colorWithFloatString:(NSString *)string;
+ (NSColor *) colorWithHexString:(NSString *)string;

- (NSColor *) colorWithWithRedShift:(CGFloat)red greenShift:(CGFloat)green blueShift:(CGFloat)blue alphaShift:(CGFloat)alpha;
- (NSColor *) colorWithSharedShift:(CGFloat) shift alphaShift:(CGFloat)alpha;
@end
