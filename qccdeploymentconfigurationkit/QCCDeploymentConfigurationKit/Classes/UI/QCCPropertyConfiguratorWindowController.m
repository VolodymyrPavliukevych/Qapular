
//
//  QCCPropertyConfiguratorWindowController.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCPropertyConfiguratorWindowController.h"

static NSString * ActionObjectValueKey        =   @"value";
static NSString * ActionObjectIdentefierKey   =   @"identefier";

@interface QCCPropertyConfiguratorWindowController() {
    
    __weak IBOutlet    NSTextField     *_valueTitleTextField;
    __weak IBOutlet    NSTextField     *_valueTextField;
    
    __weak IBOutlet    NSTextField     *_keyTitleTextField;
    __weak IBOutlet    NSComboBox      *_keyComboBox;
    
    __weak IBOutlet    NSTextField     *_UTTypeTitleTextField;
    __weak IBOutlet    NSComboBox      *_UTTypeComboBox;
    
    __weak IBOutlet    NSButton        *_isComplicatedValueButton;

}

@property (nonatomic, copy) PropertyConfiguratorCompletionBlock resultBlock;
@property (nonatomic, strong) IBOutlet NSArrayController *actionListArrayController;

@end

@implementation QCCPropertyConfiguratorWindowController

- (nonnull instancetype) initWithDataSource:(nonnull id <QCCPropertyConfiguratorDataSource>) dataSource completion:(nonnull PropertyConfiguratorCompletionBlock) resultBlock {

    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    
    if (self) {
        self.resultBlock = resultBlock;
        self.dataSource = dataSource;
    }
    
    return self;

}
-(void)setActionListArrayController:(NSArrayController *)actionListArrayController {
    _actionListArrayController = actionListArrayController;
    
    for (NSString *key in [self actionList]) {
        [_actionListArrayController addObject:@{ActionObjectValueKey : [self actionList][key],
                                                ActionObjectIdentefierKey : key}];
    }
}

#pragma mark - Button Action
#pragma mark - UI Actions
- (IBAction) cancelAction:(id)sender {
    if (self.resultBlock)
        self.resultBlock(self, nil, nil, nil, nil, NO, 0);
}


- (IBAction) doneAction:(id)sender {
    
    if (_UTTypeComboBox.indexOfSelectedItem == -1 || _keyComboBox.indexOfSelectedItem == -1)
        return;
    
    if (_valueTextField.stringValue.length == 0 || [_valueTextField.stringValue isEqualToString:@""])
        return;
    NSArray *actionIdentefiers = [NSArray arrayWithArray:[self.actionListArrayController.selectedObjects valueForKeyPath:ActionObjectIdentefierKey]];

    if (self.resultBlock)
        
        
        self.resultBlock(self,
                         _valueTextField.stringValue,
                         [self keyValueForComboBox:_keyComboBox],
                         [NSSet setWithArray:actionIdentefiers],
                         [self keyValueForComboBox:_UTTypeComboBox],
                         (_isComplicatedValueButton.state == 1),
                         PropertyTypeBack);
}


-(void)controlTextDidEndEditing:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[NSTextField class]]) {
        NSTextField *textField = (NSTextField *) notification.object;
        if ([textField.stringValue isEqualToString:@""] || textField.stringValue.length == 0)
            return;
    }
    
    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        [self doneAction:nil];
    }
}

#pragma mark - NSComboBoxDataSource
- (NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    
    if (aComboBox == _keyComboBox) {
        return [[[self keyList] allKeys] count];
    }
    
    if (aComboBox == _UTTypeComboBox) {
        return [[[self UTTypeList] allKeys] count];
    }
    
    return 0;
}

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger) index {
    
    NSDictionary *dictionary = [self dictionaryForComboBox:aComboBox];
    
    NSString *value = [dictionary objectForKey:[self dictionary:dictionary keyAtIndex:index]];
    return value;
}

- (NSDictionary <NSString *, NSString *> *) dictionaryForComboBox:(NSComboBox *)aComboBox {
    NSDictionary *dictionary;
    
    if (aComboBox == _keyComboBox) {
        dictionary = [self keyList];
    }
    
    if (aComboBox == _UTTypeComboBox) {
        dictionary = [self UTTypeList];
    }
    
    return dictionary;
}

- (NSString *) dictionary:(NSDictionary *) dictionary keyAtIndex:(NSUInteger) index {
    if ([[dictionary allKeys] count] <= index)
        return nil;
    
    NSString *key = [[[dictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:index];
    return key;
}

- (NSString *) keyValueForComboBox:(NSComboBox *)aComboBox {
    NSDictionary *dictionary = [self dictionaryForComboBox:aComboBox];

    return [self dictionary:dictionary keyAtIndex:aComboBox.indexOfSelectedItem];
}


- (NSDictionary <NSString *, NSString *> *) keyList {
    return [self.dataSource keyList];
}

- (NSDictionary <NSString *, NSString *> *) actionList {
    return [self.dataSource actionList];
}

- (nonnull NSDictionary <NSString *, NSString *>*) UTTypeList {
    return [self.dataSource UTTypeList];
}


@end
