//
//  AppDelegate.m
//  ExampleConfiguration
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "AppDelegate.h"
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@interface AppDelegate () <QCCDeploymentConfigurationProvider,  QCCDeploymentConfigurationDataSource, QCCDeploymentConfigurationLocalization>{

    QCCDeploymentConfiguration *_deploymentConfiguration;

}

@end

@implementation AppDelegate

-(QCCDeploymentConfiguration *)deploymentConfiguration {
    if (_deploymentConfiguration)
        return _deploymentConfiguration;
    
    _deploymentConfiguration = [[QCCDeploymentConfiguration alloc] initWithDictionary:nil];
    _deploymentConfiguration.dataSource = self;
    _deploymentConfiguration.localizationDataSource = self;
    return _deploymentConfiguration;
}

-(NSString *)localizationStringForKey:(NSString *)key {
    if ([key isEqualToString:@"OPTIMIZATION_LEVEL_ARG_NAME"])
        return @"Optimization level";
    
    if([key isEqualToString:@"%COMPILE%"]) {
        return @"Compile";
    }
    if([key isEqualToString:@"%CLEAN%"]) {
        return @"Clean";
    }
    if([key isEqualToString:@"%ANALYZE%"]) {
        return @"Analyze";
    }
    if([key isEqualToString:@"%LINK%"]) {
        return @"Link";
    }
    
    if ([key isEqualToString:@"STRING_PROPERTY"])
        return @"Simple string property";
    
    
    return [[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] lowercaseString];
}
-(NSDictionary *)targetItems {

    return @{@"F7476B3C-6223-4C4F-B1C9-9A3AED5C904F" : @"Arduino UNO",
             @"B9BED655-DBFE-41A9-A3DB-2F808F6033E5" : @"Intel Edison"};
}

-(NSDictionary *) actionKeyList {
    return @{@"%COMPILE%" : @"Compile",
             @"%CLEAN%" : @"Clean",
             @"%ANALYZE%" : @"Analyze",
             @"%LINK%" : @"Link"};
}

- (IBAction) serialise :(id)sender {

    NSLog(@"%@", [_deploymentConfiguration serialize]);
    NSLog(@"\n\n deployemntConfigurationContainers: %@", [_deploymentConfiguration.projectConfigurationContainer deployemntConfigurationContainers]);
    NSLog(@"\n\n deployemntConfigurationIdentifiers: %@", [_deploymentConfiguration.projectConfigurationContainer deployemntConfigurationIdentifiers]);
    
    QCCDeploymentConfigurationContainer *container = [[[_deploymentConfiguration.projectConfigurationContainer deployemntConfigurationContainers] allValues] firstObject];
    
    QCCBoardConfigurationContainer *board = [container boardConfigurationContainer];
    
    NSLog(@"\n\n boardConfigurationContainer: %@", board);
    
}


@end
