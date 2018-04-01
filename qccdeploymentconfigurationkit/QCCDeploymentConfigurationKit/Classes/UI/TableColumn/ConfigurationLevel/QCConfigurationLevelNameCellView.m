//
//  QCConfigurationLevelNameCellView.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationLevelNameCellView.h"
#import "QCCBaseConfigurationElement.h"

@implementation QCConfigurationLevelNameCellView
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    
    }
    return self;
}

-(void)setObjectValue:(id)objectValue {

    if ([objectValue isKindOfClass:[QCCBaseConfigurationElement class]]) {
        QCCBaseConfigurationElement *element = (QCCBaseConfigurationElement *) objectValue;
        self.textField.stringValue = (element.name ? element.name : @"");
    }
}

@end
