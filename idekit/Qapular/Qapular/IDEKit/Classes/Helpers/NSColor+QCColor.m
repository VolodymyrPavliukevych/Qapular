//
//  NSColor+QCColor.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "NSColor+QCColor.h"

@implementation NSColor (QCColor)

+ (NSColor *)colorWithHexString:(NSString *)string {
    
    if (!string)
        return nil;
    
    unsigned int value = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    [scanner scanString:@"#" intoString:NULL];
    
    if (![scanner scanHexInt:&value])
        return nil;
    
    return [NSColor colorWithRed:(CGFloat)((value & 0xFF0000) >> 16) / 255.0
                           green:(CGFloat)((value & 0xFF00) >> 8) / 255.0
                            blue:(CGFloat)(value & 0xFF) / 255.0
                           alpha:1.0];
}


+ (NSColor *)colorWithFloatString:(NSString *)string {
    
    if (!string)
        return nil;
    
    NSArray *colorComponents = [string componentsSeparatedByString:@" "];
    
    if ([colorComponents count] == 3 || [colorComponents count] == 4) {
        
        
        float red, green, blue, alpha;
        
        if (![[NSScanner scannerWithString:colorComponents[0]] scanFloat:&red])
            return nil;
        
        if (![[NSScanner scannerWithString:colorComponents[1]] scanFloat:&green])
            return nil;
        
        if (![[NSScanner scannerWithString:colorComponents[2]] scanFloat:&blue])
            return nil;
        
        if ([colorComponents count] == 4){
            if (![[NSScanner scannerWithString:colorComponents[3]] scanFloat:&alpha])
                return nil;
            
        }else {
            alpha = 1.0;
        }
        
        return [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    
    return nil;
}
#pragma mark - Color Model
- (CGColorSpaceModel) colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL) canProvideRGBComponents {
    switch ([self colorSpaceModel]) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}


- (NSColor *)colorWithWithRedShift:(CGFloat)red greenShift:(CGFloat)green blueShift:(CGFloat)blue alphaShift:(CGFloat)alpha {

    CGFloat redComponent = 0.0f;
    CGFloat greenComponent = 0.0f;
    CGFloat blueComponent = 0.0f;
    CGFloat alphaComponent = 0.0f;
    
    if (self.colorSpaceModel == kCGColorSpaceModelRGB)
        [self getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent];
    else {
        NSLog(@"Can't get right color space.");
        return self;
    }
    
    NSColor *resultColor = [NSColor colorWithRed:(redComponent + red)
                                           green:(greenComponent + green)
                                            blue:(blueComponent+ blue)
                                           alpha:(alphaComponent + alpha)];
    
    return resultColor;
    
    
}

- (NSColor *) colorWithSharedShift:(CGFloat) shift alphaShift:(CGFloat)alpha {
    return [self colorWithWithRedShift:shift
                            greenShift:shift
                             blueShift:shift
                            alphaShift:alpha];
}

@end
