//
//  QCCManipulationTabView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCManipulationTabView.h"

@implementation QCCManipulationTabView

- (void) showArea:(QCCManipulationArea) area {
    switch (area) {
        case QCCManipulationEditArea:
            break;
            
        case QCCManipulationReportArea:
            break;
            
        case QCCManipulationConfigurationArea:
            break;
    }

    if ([self identifierForArea:area])
        [self selectTabViewItemWithIdentifier:[self identifierForArea:area]];
}

- (QCCManipulationArea) selectedArea {
    if ([self.selectedTabViewItem.identifier isKindOfClass:[NSString class]])
        return [self areaForIdentifier:self.selectedTabViewItem.identifier];
    else
        return NSNotFound;
}


- (QCCManipulationArea) areaForIdentifier:(NSString *) identifier {
    NSArray *identifiers = [self areaIdentifiers];

    __block NSUInteger index = NSNotFound;
    [identifiers enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:identifier]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (NSString *) identifierForArea:(QCCManipulationArea) area {
    NSArray *identifiers = [self areaIdentifiers];
    if ([identifiers count] > area)
        return identifiers[area];
    else
        return nil;
}

- (NSArray *) areaIdentifiers {
    static dispatch_once_t onceToken;
    static NSArray *identifiers;
    dispatch_once(&onceToken, ^{
        identifiers = @[@"QCCManipulationEditArea", @"QCCManipulationReportArea", @"QCCManipulationConfigurationArea"];
    });
    return identifiers;
}

@end
