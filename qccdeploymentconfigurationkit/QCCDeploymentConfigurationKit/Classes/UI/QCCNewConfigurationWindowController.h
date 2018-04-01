//
//  QCCNewConfigurationWindowController.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    QCCNewConfigurationTypeProperty,
    QCCNewConfigurationTypeBoard,
    QCCNewConfigurationTypeDeployment,
} QCCNewConfigurationType;

@class QCCNewConfigurationWindowController;

typedef void (^NewConfigurationCompletionBlock)(QCCNewConfigurationWindowController *NewConfigurationWindowController,
                                                NSString *name,
                                                NSString *configuration,
                                                NSString *actionKey,
                                                NSString *propertyKey);

@interface QCCNewConfigurationWindowController : NSWindowController

@property (nonatomic, readonly) QCCNewConfigurationType type;

- (instancetype) initWithType:(QCCNewConfigurationType) type completion:(NewConfigurationCompletionBlock) resultBlock;

- (void) setConfigurationComboBoxItems:(NSDictionary *) items;
- (void) setActionComboBoxItems:(NSDictionary *) items;
- (void) setPropertyKeyComboBoxItems:(NSDictionary *) items;

@end
