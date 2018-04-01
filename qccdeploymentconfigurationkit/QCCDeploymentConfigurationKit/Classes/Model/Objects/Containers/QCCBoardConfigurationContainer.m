//
//  QCCBoardConfigurationContainer.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCBoardConfigurationContainer.h"
#import "QCConfigurationProperty.h"

@implementation QCCBoardConfigurationContainer

- (instancetype)initWithDictionary:(NSDictionary *) dict {
    self = [super initWithDictionary:dict];
    if (self) {
        _identifier = dict[QCCBoardConfigurationIdentifierKey];
    }
    return self;
}


+ (BOOL) canAddElementClass:(Class)class {
    /*
    if (class == [QCConfigurationProperty class])
        return YES;
     */
    
    return NO;
}

- (BOOL) addChild:(QCCBaseConfigurationElement *) element {
    if (!element)
        return NO;
    
    if ([[self class] canAddElement:element]) {
        [_childrenArray addObject:element];
        return YES;
    }
    
    return NO;
}

-(NSDictionary *)serialize {
    
    NSMutableDictionary *dict = [[super serialize] mutableCopy];
    dict[QCCBaseConfigurationElementTypeKey] = QCCBoardConfigurationContainerKey;
    
    if (self.identifier)
        dict[QCCBoardConfigurationIdentifierKey] = self.identifier;
    
    return dict;
}

@end
