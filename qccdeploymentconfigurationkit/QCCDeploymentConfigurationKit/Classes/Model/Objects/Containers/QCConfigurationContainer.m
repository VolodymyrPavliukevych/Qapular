//
//  QCConfigurationContainer.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationContainer.h"
#import "QCCDeploymentConfiguration+Constructor.h"

@implementation QCConfigurationContainer

- (instancetype)initWithDictionary:(NSDictionary *) dict {
    
    self = [super initWithDictionary:dict];
    
    if (self) {
        _childrenArray = [QCCMutableCollection new];
        _childrenArray.delegate = self;
        
        for (NSDictionary *element in dict[QCCBaseConfigurationElementChildrenKey]) {
            QCCBaseConfigurationElement * configurationElement = [QCCDeploymentConfiguration elementFromDictionary:element];
            if (configurationElement)
                [self addChild:configurationElement];
        }
    }
    
    return self;
}


-(QCCMutableCollection *) children {
    return _childrenArray;
}



+ (BOOL) canAddElement:(QCCBaseConfigurationElement *) element {
    return [self canAddElementClass:[element class]];
}

+ (BOOL) canAddElementClass:(Class) class {
    return NO;
}

- (BOOL) addChild:(QCCBaseConfigurationElement *) element {
    return NO;
}

- (BOOL) removeChild:(QCCBaseConfigurationElement *) element {
    for (QCCBaseConfigurationElement *child in _childrenArray) {
        if (child == element){
            [_childrenArray removeObject:child];
            return YES;
        }
    }
    
    return NO;
}

-(NSDictionary *)serialize {
    
    NSMutableDictionary *dict = [[super serialize] mutableCopy];
    dict[QCCBaseConfigurationElementTypeKey] = QCConfigurationContainerKey;
    
    NSMutableArray *childrenSerialization = [NSMutableArray new];
    
    for (QCCBaseConfigurationElement *element in self.children) {
        NSDictionary *serialize = [element serialize];
         [childrenSerialization addObject:serialize];
    }
    
    dict[QCCBaseConfigurationElementChildrenKey] = childrenSerialization;
    return dict;
}
#pragma mark - QCCMutableCollectionDelegate
-(void)addedObject {
    if ([_delegate respondsToSelector:@selector(addedObject)]) {
        [_delegate addedObject];
    }
}

-(void)removedObject {
    if ([_delegate respondsToSelector:@selector(removedObject)]) {
        [_delegate removedObject];
    }
}


@end
