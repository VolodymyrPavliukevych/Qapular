//
//  QCCBaseSchema.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCBaseSchema : NSObject {
    NSDictionary        *_rawContentDictionary;
}

@property (nonatomic, readonly) NSString            *identifier;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary;

- (id) valueForSchemaKey:(NSString *) schemaKey;


@end
