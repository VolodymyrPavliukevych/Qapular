//
//  NSObject+Cast.m
//  Qapular Code Composer
//
//  Created by Vladimir Pavlyukevich on 6/4/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
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
