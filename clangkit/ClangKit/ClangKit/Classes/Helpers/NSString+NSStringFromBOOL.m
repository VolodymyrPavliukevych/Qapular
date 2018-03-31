//
//  NSString+NSStringFromBOOL.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "NSString+NSStringFromBOOL.h"

@implementation NSString (NSStringFromBOOL)
+ (NSString *) stringFromBOOL:(BOOL) value {
    return (value ? @"YES" : @"NO");
}

@end
