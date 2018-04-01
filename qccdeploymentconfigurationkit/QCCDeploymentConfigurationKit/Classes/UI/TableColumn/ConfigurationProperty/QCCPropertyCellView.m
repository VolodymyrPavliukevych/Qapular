//
//  QCCPropertyCellView.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCPropertyCellView.h"
#import "QCCDeploymentConfigurationDataSource.h"
#import "QCConfigurationProperty.h"


@implementation QCCPropertyCellView

@end

@implementation QCCPropertyNameCellView

-(void)setObjectValue:(id)objectValue {
    
    if ([objectValue isKindOfClass:[QCConfigurationProperty class]]) {
        QCConfigurationProperty *property = (QCConfigurationProperty *) objectValue;
        NSString *name = property.name;
        self.textField.stringValue = (name ? name : @"");
    }
}

@end

@interface QCCPropertyValueCellView() <NSTextFieldDelegate> {
    QCConfigurationProperty *_relatedProperty;
}

@end


@implementation QCCPropertyValueCellView

-(void)setTextField:(NSTextField *)textField {
    [super setTextField:textField];
    self.textField.delegate = self;
}

-(void)setObjectValue:(id)objectValue {
    
    if ([objectValue isKindOfClass:[QCConfigurationProperty class]]) {
        QCConfigurationProperty *property = (QCConfigurationProperty *) objectValue;
        [self setRelatedProperty:property];
    }
}

- (void) setRelatedProperty:(QCConfigurationProperty *) property {
    _relatedProperty = property;
    
    NSString *value = property.value;
    self.textField.stringValue = (value ? value : @"");
    
}

#pragma mark - NSTextFieldDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if (fieldEditor.string)
        [_relatedProperty updateValue:[NSString stringWithString:fieldEditor.string]];
    
    return YES;
}

- (BOOL)control:(NSControl *)control isValidObject:(NSString *) string {
    if (!string || string.length == 0)
        return NO;
    
    return YES;
}

@end

@implementation QCCPropertyActionCellView

-(void)setObjectValue:(id)objectValue {
    
    if ([objectValue isKindOfClass:[QCConfigurationProperty class]]) {
        QCConfigurationProperty *property = (QCConfigurationProperty *) objectValue;
        
        __block NSMutableArray *actions = [NSMutableArray new];
        
        [[property.actionKeys allObjects] enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *localization = ([property.localizationDataSource localizationStringForKey:obj] ? :obj);
            [actions addObject:localization];
        }];
        
        NSString *name = [actions componentsJoinedByString:@", "];
        self.textField.stringValue = (name ? name : @"");
    }
    
}

@end
