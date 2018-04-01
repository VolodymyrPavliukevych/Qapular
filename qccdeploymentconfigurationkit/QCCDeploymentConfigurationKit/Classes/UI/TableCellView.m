//
//  TableCellView.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "TableCellView.h"

@implementation TableCellView
-(void)setObjectValue:(id)objectValue {

    if (objectValue) {
        self.textField.stringValue = [objectValue valueForKey:@"value"];
    }
    
    
}
@end
