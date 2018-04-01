//
//  QCConfigurationLevelNode.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationLevelNode.h"
#import "QCCBaseConfigurationElement.h"
#import "QCConfigurationContainer.h"
#import "QCCBoardConfigurationContainer.h"


@implementation QCConfigurationLevelNode

+(instancetype)treeNodeWithRepresentedObject:(id)modelObject {
    QCConfigurationLevelNode *node;
    
    if ([modelObject isKindOfClass:[QCConfigurationContainer class]]) {
        node = [super treeNodeWithRepresentedObject:modelObject];
        QCConfigurationContainer *container = (QCConfigurationContainer *) modelObject;
        
        for (QCCBaseConfigurationElement *element in [container children]) {
            QCConfigurationLevelNode *child = [QCConfigurationLevelNode treeNodeWithRepresentedObject:element];
            if (child)
                [[node mutableChildNodes] addObject:child];
        }
    }
    
    return node;
}

- (void) updateBoardNode {
    for (NSTreeNode *node in self.mutableChildNodes) {
        if ([node isKindOfClass:[QCConfigurationLevelNode class]]) {
            QCConfigurationLevelNode *configurationLevelNode = (QCConfigurationLevelNode *) node;
            id object = configurationLevelNode.representedObject;
            if ([object isKindOfClass:[QCCBoardConfigurationContainer class]]) {
                [self.mutableChildNodes removeObject:configurationLevelNode];
                break;
            }
        }
    }
    
    if ([self.representedObject isKindOfClass:[QCConfigurationContainer class]]) {
        QCConfigurationContainer *configurationContainer = (QCConfigurationContainer *) self.representedObject;
        for (QCCBaseConfigurationElement *element in configurationContainer.children) {
            if ([element isKindOfClass:[QCCBoardConfigurationContainer class]]) {
                QCConfigurationLevelNode *child = [QCConfigurationLevelNode treeNodeWithRepresentedObject:element];
                if (child)
                    [[self mutableChildNodes] addObject:child];
            }
        }
    }
}

@end
