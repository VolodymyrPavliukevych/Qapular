//
//  QCCBaseTarget.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCSchema;


@interface QCCBaseTarget : NSObject {
    NSDictionary        *_rawContentDictionary;
}


@property (nonatomic, readonly) NSString    *name;
@property (nonatomic, readonly) NSString    *identifier;
@property (nonatomic, readonly) NSString    *information;
@property (nonatomic, readonly) NSString    *venderName;

@property (nonatomic, readonly) NSDictionary *generations;

@property (nonatomic, readonly) NSString    *manufacture;
@property (nonatomic, readonly) NSString    *versionString;

@property (nonatomic, readonly) QCCSchema   *schema;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary;

@end
