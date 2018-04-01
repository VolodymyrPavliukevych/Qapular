//
//  QCCProjectConfigurationContainer.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCProjectConfigurationContainer.h"
#import "QCConfigurationProperty.h"
#import "QCCDeploymentConfigurationContainer.h"



@implementation QCCProjectConfigurationContainer

- (instancetype)initWithDictionary:(NSDictionary *) dict {
    self = [super initWithDictionary:dict];
    if (self) {
        
    }
    return self;
}

+ (BOOL) canAddElementClass:(Class) class {
    if (class == [QCCDeploymentConfigurationContainer class])
        return YES;
    
    if (class == [QCConfigurationProperty class])
        return YES;
    
    return NO;
    
}

- (BOOL) addChild:(QCCBaseConfigurationElement *) element {
    if (!element)
        return NO;
    
    if ([element isKindOfClass:[QCConfigurationContainer class]]) {
        QCConfigurationContainer * container = (QCConfigurationContainer *) element;
        container.delegate = self;
    }
    
    if ([[self class] canAddElement:element]) {
        [_childrenArray addObject:element];
        return YES;
    }
        
    return NO;
}

-(NSDictionary *)serialize {
    
    NSMutableDictionary *dict = [[super serialize] mutableCopy];
    dict[QCCBaseConfigurationElementTypeKey] = QCCProjectConfigurationContainerKey;
    
    return dict;
}

- (NSDictionary <NSString* , QCCDeploymentConfigurationContainer * >*) deployemntConfigurationContainers {
    NSMutableDictionary *containers = [NSMutableDictionary new];
    
    for (QCCBaseConfigurationElement *element in self.children) {
        if ([element isKindOfClass:[QCCDeploymentConfigurationContainer class]]){
            QCCDeploymentConfigurationContainer *deploymentConfigurationContainer = (QCCDeploymentConfigurationContainer *) element;
            containers[deploymentConfigurationContainer.identifier] = deploymentConfigurationContainer;
        }
    }
    
    return containers;
}

- (NSArray<NSString *> *) boardIdentifiers {
    NSMutableArray *array = [NSMutableArray new];
    
    for (QCCDeploymentConfigurationContainer *deploymentConfigurationContainer in [[self deployemntConfigurationContainers] allValues]) {
        if (deploymentConfigurationContainer.boardIdentifier)
            [array addObject:deploymentConfigurationContainer.boardIdentifier];
    }
    
    return array;
}

- (NSArray *) deployemntConfigurationIdentifiers {
    return [[self deployemntConfigurationContainers] allKeys];
}

@end
