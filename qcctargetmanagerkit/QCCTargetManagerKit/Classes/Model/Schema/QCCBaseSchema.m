//
//  QCCBaseSchema.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCBaseSchema.h"

@interface QCCBaseSchema() {
    NSDictionary    *_sourceDictionary;
}
@end

@implementation QCCBaseSchema

static NSString *const QCCSchemaIdentifierKey = @"QCCSchemaIdentifier";


-  (instancetype)initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (!dictionary)
        return nil;
    
    if (self) {
        _rawContentDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
        
        _identifier = _rawContentDictionary[QCCSchemaIdentifierKey];
    }
    
    return self;
}

- (id) valueForSchemaKey:(NSString *) schemaKey {
    if (!schemaKey)
        return nil;
    return _rawContentDictionary[schemaKey];
}



@end
