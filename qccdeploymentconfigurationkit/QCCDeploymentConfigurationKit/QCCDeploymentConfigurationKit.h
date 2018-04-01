//
//  QCCDeploymentConfigurationKit.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for QCCDeploymentConfigurationKit.
FOUNDATION_EXPORT double QCCDeploymentConfigurationKitVersionNumber;

//! Project version string for QCCDeploymentConfigurationKit.
FOUNDATION_EXPORT const unsigned char QCCDeploymentConfigurationKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <QCCDeploymentConfigurationKit/PublicHeader.h>


// DeploymentConfiguration
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfiguration.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationDataSource.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfiguration+PropertyBlender.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfiguration+Constructor.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfiguration+UTCoreTypes.h>

//Objects
#import <QCCDeploymentConfigurationKit/QCCBaseConfigurationElement.h>

//Property
#import <QCCDeploymentConfigurationKit/QCConfigurationProperty.h>

//Containers
#import <QCCDeploymentConfigurationKit/QCConfigurationContainer.h>
#import <QCCDeploymentConfigurationKit/QCCBoardConfigurationContainer.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationContainer.h>
#import <QCCDeploymentConfigurationKit/QCCProjectConfigurationContainer.h>

// UI
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationProvider.h>
#import <QCCDeploymentConfigurationKit/QCCNewConfigurationWindowController.h>
#import <QCCDeploymentConfigurationKit/QCConfigurationLevelNode.h>
#import <QCCDeploymentConfigurationKit/QCConfigurationPropertyNode.h>
#import <QCCDeploymentConfigurationKit/QCConfigurationTabViewItem.h>
#import <QCCDeploymentConfigurationKit/QCConfigurationViewController.h>
#import <QCCDeploymentConfigurationKit/QCConfigurationLevelNameCellView.h>
#import <QCCDeploymentConfigurationKit/QCCPropertyGroupCellView.h>
#import <QCCDeploymentConfigurationKit/QCCPropertyCellView.h>
#import <QCCDeploymentConfigurationKit/QCCPropertyValueColumn.h>

#import <QCCDeploymentConfigurationKit/QCCPropertyConfiguratorWindowController.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfiguration+QCCPropertyConfiguratorDataSource.h>
