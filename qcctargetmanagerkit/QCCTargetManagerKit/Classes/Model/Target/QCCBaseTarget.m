//
//  QCCBaseTarget.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCBaseTarget.h"
#import "QCCSchema.h"


NSString *const QCCTargetIdentifierKey = @"QCCTargetIdentifier";
NSString *const QCCTargetNameKey = @"QCCTargetName";
NSString *const QCCTargetInformationKey = @"QCCTargetInformation";

NSString *const QCCTargetVenderNameKey = @"QCCTargetVenderName";
NSString *const QCCTargetGenerationKey = @"QCCTargetGeneration";

NSString *const QCCTargetVidNumberKey = @"QCCTargetVidNumber";
NSString *const QCCTargetPidNumberKey = @"QCCTargetPidNumber";

NSString *const QCCTargetManufactureKey = @"QCCTargetManufacture";
NSString *const QCCTargetVersionKey = @"QCCTargetVersion";
NSString *const QCCTargetSchemaKey = @"QCCTargetSchema";

@implementation QCCBaseTarget

-(instancetype)initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (!dictionary)
        return nil;
    
    if (self) {
        _rawContentDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
        
        _identifier = _rawContentDictionary[QCCTargetIdentifierKey];
        _name = _rawContentDictionary[QCCTargetNameKey];
        _information = _rawContentDictionary[QCCTargetInformationKey];
        _venderName = _rawContentDictionary[QCCTargetVenderNameKey];
        _generations = _rawContentDictionary[QCCTargetGenerationKey];
        _manufacture = _rawContentDictionary[QCCTargetManufactureKey];
        _versionString = _rawContentDictionary[QCCTargetVersionKey];
        _schema = [[QCCSchema alloc] initWithDictionary:_rawContentDictionary[QCCTargetSchemaKey]];
    
    }
        
    return self;
}


- (id) valueForKey:(NSString *) key generation:(NSString *) generationKey {
    
    if (!key || !generationKey)
        return nil;
    
    NSDictionary *generation =  _generations[generationKey];
    
    if (!generation)
        return nil;
    
    return generation[key];
}


@end
