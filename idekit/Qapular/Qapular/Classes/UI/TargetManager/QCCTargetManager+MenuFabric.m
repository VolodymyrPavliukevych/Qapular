//
//  QCCTargetManager+MenuFabric.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTargetManager+MenuFabric.h"
#import "QCCTargetManagerMenuItem.h"


@implementation QCCTargetManager (MenuFabric)

- (NSArray *) attachedPortMenuArray {
    NSMutableArray *items = [NSMutableArray new];
    NSDictionary *attachedTargets = [self attachedTargets];
    
    for (NSString *port in [attachedTargets[QCCTargetManagerKnownTargetsKey] allKeys]) {
        QCCTarget *target = attachedTargets[QCCTargetManagerKnownTargetsKey][port];
        QCCTargetManagerMenuItem *item = [self menuWithTitle:target.name port:port];
        if (item)
            [items addObject:item];
    }

    for (NSString *port in [attachedTargets[QCCTargetManagerUnknownTargetsKey] allKeys]) {
        NSDictionary *target = attachedTargets[QCCTargetManagerUnknownTargetsKey][port];
        
        NSString *manufacturer = target[@"QCCPortManufacturer"];
        NSString *serial = target[@"QCCPortSerial"];
        
        NSString * title = [NSString stringWithFormat:@"%@ [Manufacturer: %@ Serial:%@]", port, manufacturer, serial];
        
        QCCTargetManagerMenuItem *item = [self menuWithTitle:title port:port];
        if (item)
            [items addObject:item];
    }
    
    
    return items;
    
}

- (QCCTargetManagerMenuItem *) menuWithTitle:(NSString *) title port:(NSString *) port {

    QCCTargetManagerMenuItem *item = [[QCCTargetManagerMenuItem alloc] initWithTitle:title
                                                                                port:port];
    return item;
}

@end
