//
//  QCCNewConfigurationWindowController.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCNewConfigurationWindowController.h"

@interface QCCNewConfigurationWindowController () <NSTextFieldDelegate, NSComboBoxDelegate, NSComboBoxDataSource> {
    
    IBOutlet    NSTextField     *_nameTitleTextField;
    IBOutlet    NSTextField     *_configurationTitleTextField;
    IBOutlet    NSTextField     *_nameTextField;
    IBOutlet    NSTextField     *_keysTextField;
    IBOutlet    NSTextField     *_actionsTextField;
    
    IBOutlet    NSComboBox      *_configurationComboBox;
    IBOutlet    NSComboBox      *_actionsComboBox;
    IBOutlet    NSComboBox      *_keysComboBox;
    
    NSDictionary                *_configurationComboBoxItems;
    NSDictionary                *_actionComboBoxItems;
    NSDictionary                *_propertyKeyComboBoxItems;
    
}

@property (nonatomic, copy) void (^ resultBlock) (QCCNewConfigurationWindowController *NewConfigurationWindowController, NSString *name, NSString *configuration, NSString *actionKey, NSString *propertyKey);

@end

@implementation QCCNewConfigurationWindowController

- (instancetype) initWithType:(QCCNewConfigurationType) type completion:(NewConfigurationCompletionBlock) resultBlock {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    
    if (self) {
        _type = type;
        self.resultBlock = resultBlock;
        
    }
    return self;
}

#pragma mark - UI settings
-(void)awakeFromNib {
    [super awakeFromNib];
    switch (_type) {
        case QCCNewConfigurationTypeProperty:
            [self setupPropertyConfigurationUI];
            break;
            
        case QCCNewConfigurationTypeBoard:
            [self setupBoardConfigurationUI];
            break;
            
        case QCCNewConfigurationTypeDeployment:
            [self setupDeploymentConfigurationUI];
            break;
            
        default:
            break;
    }
}

- (void) setupPropertyConfigurationUI {
    _nameTitleTextField.stringValue = NSLocalizedString(@"Property or flag value:", @"New Configuration Label");
    _configurationTitleTextField.stringValue = NSLocalizedString(@"Related to files:", @"New Configuration Label");
}

- (void) setupBoardConfigurationUI {
    _configurationTitleTextField.stringValue = NSLocalizedString(@"Please, select board:", @"New Configuration Label");
    
    _nameTitleTextField.hidden = YES;
    _nameTextField.hidden = YES;

    _keysComboBox.hidden = YES;
    _actionsComboBox.hidden = YES;
    _keysTextField.hidden = YES;
    _actionsTextField.hidden = YES;

}

- (void) setupDeploymentConfigurationUI {
    _nameTitleTextField.stringValue = NSLocalizedString(@"Configuration name:", @"New Configuration Label");
    _configurationTitleTextField.hidden = YES;
    _configurationComboBox.hidden = YES;
    
    _keysComboBox.hidden = YES;
    _actionsComboBox.hidden = YES;
    _keysTextField.hidden = YES;
    _actionsTextField.hidden = YES;
    
}

#pragma mark - UI Actions
- (IBAction) cancelAction:(id)sender {
    if (self.resultBlock)
        self.resultBlock(self, nil, nil, nil, nil);
}


- (IBAction) doneAction:(id)sender {    
    if (self.resultBlock) {
        NSArray *configurationKeys = [_configurationComboBoxItems allKeysForObject:_configurationComboBox.selectedCell.stringValue];
        NSArray *actionKeys = [_actionComboBoxItems allKeysForObject:_actionsComboBox.selectedCell.stringValue];
        NSArray *propertyKeys = [_propertyKeyComboBoxItems allKeysForObject:_keysComboBox.selectedCell.stringValue];
        
        self.resultBlock(self, _nameTextField.stringValue,
                         [configurationKeys firstObject],
                         [actionKeys firstObject],
                         [propertyKeys firstObject]);
    }
}

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        [self doneAction:nil];
    }
}

#pragma mark - NSComboBoxDelegate

- (void) setConfigurationComboBoxItems:(NSDictionary *) items {
    if (items)
        _configurationComboBoxItems = [items copy];
    
    [_configurationComboBox reloadData];
}

- (void) setActionComboBoxItems:(NSDictionary *) items {
    if (items)
        _actionComboBoxItems = [items copy];
    
    [_actionsComboBox reloadData];
}

- (void) setPropertyKeyComboBoxItems:(NSDictionary *) items {
    if (items)
        _propertyKeyComboBoxItems = [items copy];
    
    [_keysComboBox reloadData];
}


#pragma mark - NSComboBoxDataSource
- (NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if (aComboBox == _keysComboBox)
        return [[self propertyKeysComboBoxKeys] count];
    
    if (aComboBox == _actionsComboBox)
        return [[self actionComboBoxKeys] count];
    
    return [[self comboBoxKeys] count];
}

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger) index {
    NSArray *items;
    NSDictionary *dictionary;
    
    if (aComboBox == _keysComboBox) {
        items = [self propertyKeysComboBoxKeys];
        dictionary = _propertyKeyComboBoxItems;
    }
        
    if (aComboBox == _actionsComboBox) {
        items = [self actionComboBoxKeys];
        dictionary = _actionComboBoxItems;
    }
    
    if (aComboBox == _configurationComboBox) {
        items = [self comboBoxKeys];
        dictionary = _configurationComboBoxItems;
    }
    
    NSString *key = ([items count] > index ? items[index] : nil);
    
    return dictionary[key];
}


- (NSArray *) comboBoxKeys {
    return [[_configurationComboBoxItems allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *) actionComboBoxKeys {
    return [[_actionComboBoxItems allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *) propertyKeysComboBoxKeys {
    return [[_propertyKeyComboBoxItems allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

@end
