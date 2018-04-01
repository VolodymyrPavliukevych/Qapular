//
//  QCCDeploymentConfiguration+PropertyBlender.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration+PropertyBlender.h"
#import "QCCProjectConfigurationContainer.h"

static NSString *PunctuationPattern = @"!#$%&'*+,./:;<=>?@^_`{|}~";
static NSString *CharacterPattern = @"a-zA-Z0-9";

@implementation NSString (Trim)

- (NSString *) trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end

@implementation QCCDeploymentConfiguration (PropertyBlender)

- (nonnull NSArray <NSString *> *) blandPropertyWithRaw:(nonnull NSArray<NSDictionary <NSString *, id > *> *) array {
    NSMutableArray *properties = [NSMutableArray new];
    for (NSDictionary *raw in array) {
        QCConfigurationProperty *property =  [[QCConfigurationProperty alloc] initWithDictionary:raw];
        [properties addObject:property];
    }
    return [self blandProperty:properties];
}


- (nonnull NSArray <NSString *> *) blandProperty:(nonnull NSArray<QCConfigurationProperty *> *) array {
    __block NSMutableArray *items = [NSMutableArray new];
    
    for (QCConfigurationProperty *backProperty in array) {
        if (backProperty.type != PropertyTypeBack)
            continue;
        
        for (QCConfigurationProperty *frontProperty in array) {
            if (frontProperty.type == PropertyTypeFront) {
                if ([backProperty.key isEqualToString:frontProperty.key]) {
                    
                    NSString *value = [backProperty.value trim];
                    
                    if (!backProperty.isComplicatedValue) {
                        NSMutableArray *foundedProperty = [NSMutableArray new];
                        NSError *error;
                        NSString *pattern = [NSString stringWithFormat:@"([-%@%@]+[ ]+)|([-%@%@]+)|\\\"([%@%@ ]+)\\\"|([-%@%@]+\\\"[%@%@ ]+)\\\"",
                                             CharacterPattern,
                                             PunctuationPattern,
                                             CharacterPattern,
                                             PunctuationPattern,
                                             CharacterPattern,
                                             PunctuationPattern,
                                             CharacterPattern,
                                             PunctuationPattern,
                                             CharacterPattern,
                                             PunctuationPattern];
                        
                        NSRegularExpression *regex = [NSRegularExpression
                                                      regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                      error:&error];
                        
                        [regex enumerateMatchesInString:value options:0 range:NSMakeRange(0, [value length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                            [foundedProperty addObject: [value substringWithRange:match.range]];
                        }];
                        /*NSLog(@"founded property by pattern: %@", foundedProperty);*/
                        
                        
                        if ([foundedProperty count] != 0) {
                            NSString *property = [frontProperty.value stringByAppendingString:[foundedProperty firstObject]];
                            [items addObject: [property trim]];
                            /*NSLog(@"added first with key: \"%@\"", [property trim]);*/
                            
                            for (NSUInteger index = 1; index < [foundedProperty count]; index++) {
                                NSString *property = [foundedProperty[index] trim];
                                [items addObject: property];
                                /*NSLog(@"added left: \"%@\"", property);*/
                            }
                        }
                        
                        
                    } else {
                        NSString *property = [frontProperty.value stringByAppendingString:value];
                        [items addObject: property];
                    }
                    continue;
                }
            }
        }
    }
    return items;
}

@end


