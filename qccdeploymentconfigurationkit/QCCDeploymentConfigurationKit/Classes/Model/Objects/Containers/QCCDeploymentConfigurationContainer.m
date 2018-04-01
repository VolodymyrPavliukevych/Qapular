//
//  QCCDeploymentConfigurationContainer.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfigurationContainer.h"
#import "QCCBoardConfigurationContainer.h"
#import "QCConfigurationProperty.h"


@implementation QCCDeploymentConfigurationContainer

- (instancetype)initWithDictionary:(NSDictionary *) dict {
    self = [super initWithDictionary:dict];
    if (self) {
        _identifier = (dict[QCCDeploymentConfigurationContainerIdentifierKey] ?: [[NSUUID UUID] UUIDString]);
    }
    return self;
}

+ (BOOL) canAddElementClass:(Class)class {
    
    if (class == [QCCBoardConfigurationContainer class])
        return YES;
    
    if (class == [QCConfigurationProperty class])
        return YES;
    
    return NO;
}

- (BOOL) addChild:(QCCBaseConfigurationElement *) element {
    if (!element)
        return NO;
    
    if (![[self class] canAddElement:element])
        return NO;
    
    if ([element isKindOfClass:[QCConfigurationProperty class]]) {
        [_childrenArray addObject:element];
        return YES;
    } else if ([element isKindOfClass:[QCCBoardConfigurationContainer class]])
        return [self replaceBoardConfiguration:(QCCBoardConfigurationContainer *) element];
    
    return NO;
}


- (BOOL) replaceBoardConfiguration:(QCCBoardConfigurationContainer *) boardConfiguration {
    
    if(!boardConfiguration)
        return NO;
    
    for (QCCBaseConfigurationElement *element in self.children) {
        if ([element isKindOfClass:[QCCBoardConfigurationContainer class]]) {
            [_childrenArray removeObject:element];
            break;
        }
    }
    
    [_childrenArray addObject:boardConfiguration];
    
    return YES;
}

- (NSString *) boardIdentifier {

    for (QCCBaseConfigurationElement *element in self.children) {
        if ([element isKindOfClass:[QCCBoardConfigurationContainer class]]) {
            QCCBoardConfigurationContainer *boardConfigurationContainer = (QCCBoardConfigurationContainer *) element;
            return boardConfigurationContainer.identifier;
        }
    }
    return nil;
}


-(NSDictionary *)serialize {
    
    NSMutableDictionary *dict = [[super serialize] mutableCopy];
    dict[QCCBaseConfigurationElementTypeKey] = QCCDeploymentConfigurationContainerKey;

    if (self.identifier)
        dict[QCCDeploymentConfigurationContainerIdentifierKey] = self.identifier;
    
    return dict;
}

- (QCCBoardConfigurationContainer *) boardConfigurationContainer {

    for (QCCBaseConfigurationElement *element in self.children) {
        if ([element isKindOfClass:[QCCBoardConfigurationContainer class]])
            return (QCCBoardConfigurationContainer * ) element;
    }

    return nil;
}

@end
