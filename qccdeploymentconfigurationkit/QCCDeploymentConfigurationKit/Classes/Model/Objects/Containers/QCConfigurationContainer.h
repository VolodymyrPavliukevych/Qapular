//
//  QCConfigurationContainer.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCBaseConfigurationElement.h"
#import "QCCMutableCollection.h"

@interface QCConfigurationContainer : QCCBaseConfigurationElement <QCCMutableCollectionDelegate> {
    QCCMutableCollection *_childrenArray;
}

@property (nonatomic, strong) NSArray *children;

+ (BOOL) canAddElement:(QCCBaseConfigurationElement *) element;
+ (BOOL) canAddElementClass:(Class) class;
- (BOOL) addChild:(QCCBaseConfigurationElement *) element;
- (BOOL) removeChild:(QCCBaseConfigurationElement *) element;

@property (nonatomic, weak) id <QCCMutableCollectionDelegate> delegate;

@end
