//
//  NSObject+Cast.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
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
