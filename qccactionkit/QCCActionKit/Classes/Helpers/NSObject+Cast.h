//
//  NSObject+Cast.h
//  Qapular Code Composer
//
//  Created by Vladimir Pavlyukevich on 6/4/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Cast)
- (void) dependClass:(Class ) class performBlock:(void (^)(id object)) block;


@end
