//
//  QCConfigurationPropertyNode.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationPropertyNode.h"
#import "QCCBaseConfigurationElement.h"
#import "QCConfigurationContainer.h"
#import "QCConfigurationProperty.h"

@implementation QCConfigurationPropertyNode

+ (instancetype)treeNodeWithRepresentedObject:(id)modelObject {
    QCConfigurationPropertyNode *node;
    
    if ([modelObject isKindOfClass:[QCConfigurationProperty class]]) {
        node = [super treeNodeWithRepresentedObject:modelObject];
    }
    
    if ([modelObject isKindOfClass:[NSDictionary class]]) {
        node = [super treeNodeWithRepresentedObject:modelObject];
    }
    
    return node;
}
@end
