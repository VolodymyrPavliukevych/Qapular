//
//  NSObject+Cast.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Cast)
- (void) dependClass:(Class ) class performBlock:(void (^)(id object)) block;


@end
