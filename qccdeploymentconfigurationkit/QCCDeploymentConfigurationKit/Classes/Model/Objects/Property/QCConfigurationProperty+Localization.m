//
//  QCConfigurationProperty+Localization.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationProperty+Localization.h"

@implementation QCConfigurationProperty (Localization)

- (NSString *) name {
    
    if (self.key_localization)
        return self.key_localization;
    
    if (self.localizationDataSource) {
        NSString *localizationString = [self.localizationDataSource localizationStringForKey:self.key];
        if (localizationString && ![localizationString isEqualToString:@""])
            return localizationString;
    }
    
    return self.key;
}



@end
