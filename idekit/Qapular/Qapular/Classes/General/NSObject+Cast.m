//
//  NSObject+Cast.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "NSObject+Cast.h"

@implementation NSObject (Cast)
- (void) dependClass:(Class ) class performBlock:(void (^)(id object)) block {
    if ([self isKindOfClass:class]) {
    
        if (block)
            block(self);
    }
}
@end
