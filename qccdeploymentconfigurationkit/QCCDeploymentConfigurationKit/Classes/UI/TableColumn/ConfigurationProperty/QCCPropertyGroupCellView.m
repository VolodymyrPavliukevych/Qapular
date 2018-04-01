//
//  QCCPropertyGroupCellView.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCPropertyGroupCellView.h"

@implementation QCCPropertyGroupCellView
-(void)setObjectValue:(id)objectValue {
    if ([objectValue isKindOfClass:[NSDictionary class]]) {
        NSString *name = objectValue[@"name"];
        self.textField.stringValue = (name ? name : @"");
    }
}
@end
