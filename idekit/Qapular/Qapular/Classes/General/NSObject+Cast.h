//
//  NSObject+Cast.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Cast)
- (void) dependClass:(Class ) class performBlock:(void (^)(id object)) block;


@end
