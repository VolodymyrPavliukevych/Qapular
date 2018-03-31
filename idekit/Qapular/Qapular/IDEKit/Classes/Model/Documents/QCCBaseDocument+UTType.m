//
//  QCCBaseDocument+UTType.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2015 Qapular. All rights reserved.
//

#import "QCCBaseDocument+UTType.h"

@implementation QCCBaseDocument (UTType)
#pragma mark - UnSavaed file
- (CFStringRef) unSavedDefaultUTType {
    return kUTTypePlainText;
}

+ (NSString *) extensionForUTType:(NSString *) type {
    
    if ([type isEqualToString:@"public.c-plus-plus-source"])
        return @"cpp";

    // Fix for non installed app.
    if ([type isEqualToString:@"com.qapular.project"])
        return @"qccproj";
    
    CFDictionaryRef utiDecl = UTTypeCopyDeclaration((__bridge CFStringRef)(type));
    NSDictionary *dictionary = (__bridge NSDictionary*) utiDecl;
    NSDictionary * tagSpecification = dictionary[@"UTTypeTagSpecification"];
    
    id container = tagSpecification[@"public.filename-extension"];
    
    if ([container isKindOfClass:[NSArray class]])
        return [container firstObject];
    
    return container;
}


- (NSString *) UTIString {
    NSString *type;
    NSError *error;
    if ([self.fileURL getResourceValue:&type forKey:NSURLTypeIdentifierKey error:&error]) {
        if (error)
            NSLog(@"Error %@", error);
    }
    return type;
}

@end
