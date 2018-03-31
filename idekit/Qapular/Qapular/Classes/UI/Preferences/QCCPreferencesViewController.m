//
//  QCCPreferencesViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCPreferencesViewController.h"
#import "QCCPreferences.h"


@interface QCCPreferencesViewController () {
    IBOutlet    NSButton    *_showLineNumberCheckBox;
    
    IBOutlet    NSButton    *_wrapColumnCheckBox;
    IBOutlet    NSButton    *_wrapColumnAtFrameCheckBox;
    IBOutlet    NSTextField *_wrapColumnTextField;
    IBOutlet    NSStepper   *_wrapColumnStepper;
    IBOutlet    NSComboBox  *_themeNameComboBox;
    IBOutlet    NSComboBox  *_unSavedComboBox;
    NSArray                 *_unSavedDocumentFoldersArray;
    QCCPreferencesWrapColumn _wrapColumn;
}

@end

@implementation QCCPreferencesViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self loadPreferences];
}

- (void) loadPreferences {
    
    _showLineNumberCheckBox.state = [_preferences shouldShowLineNumbering];
    NSArray *themeList = [_preferences themeList];
    [_themeNameComboBox addItemsWithObjectValues:themeList];
    [_themeNameComboBox selectItemWithObjectValue:[_preferences selectedTheme]];
    
    _unSavedDocumentFoldersArray = @[@"in Temporary folder", @"in Documents folder", @"on Desctop"];
    [_unSavedComboBox addItemsWithObjectValues:_unSavedDocumentFoldersArray];
    if ([_unSavedComboBox numberOfItems] > [_preferences selectedUnSavedDocumentFolderIndex])
        [_unSavedComboBox selectItemAtIndex:[_preferences selectedUnSavedDocumentFolderIndex]];
    
    _wrapColumn = [_preferences wrapColumn];
    
    _wrapColumnStepper.intValue = _wrapColumn.columns;
    
    switch (_wrapColumn.type) {
        case QCCWrapColumnNon:
            _wrapColumnStepper.enabled = NO;
            _wrapColumnTextField.enabled = NO;
            _wrapColumnAtFrameCheckBox.enabled = NO;
            _wrapColumnAtFrameCheckBox.state = NO;
            _wrapColumnCheckBox.state = NO;
            break;
            
            
        case QCCWrapColumnAtFrameSize:
            _wrapColumnStepper.enabled = NO;
            _wrapColumnTextField.enabled = NO;
            _wrapColumnAtFrameCheckBox.enabled = YES;
            _wrapColumnAtFrameCheckBox.state = YES;
            _wrapColumnCheckBox.state = YES;
            break;
            
        case QCCWrapColumnValue:
            _wrapColumnStepper.enabled = YES;
            _wrapColumnTextField.enabled = YES;
            _wrapColumnAtFrameCheckBox.enabled = YES;
            _wrapColumnAtFrameCheckBox.state = NO;
            _wrapColumnCheckBox.state = YES;
            _wrapColumnTextField.stringValue = [NSString stringWithFormat:@"%i", _wrapColumn.columns];
            
            break;
        default:
            break;
    }
    
}


#pragma mark - UI elements



#pragma mark - Actions
- (IBAction) showLineNumberCheckBox:(NSButton *)sender {
    BOOL value = sender.state;
    [_preferences setShouldShowLineNumbering:value];
}

- (IBAction) shouldWrapColumn:(NSButton *)sender {
    
    if (sender.state == 1){
        _wrapColumnTextField.enabled = YES;
        _wrapColumnStepper.enabled = YES;
        _wrapColumnAtFrameCheckBox.enabled = YES;
        _wrapColumn.type = QCCWrapColumnValue;

    }else {
        _wrapColumnTextField.enabled = NO;
        _wrapColumnStepper.enabled = NO;
        _wrapColumnAtFrameCheckBox.enabled = NO;
        _wrapColumnAtFrameCheckBox.state = NO;
        _wrapColumn.type = QCCWrapColumnNon;
    }

        [_preferences setWrapColumn:_wrapColumn];
}


- (IBAction) wrapColumnValueChanged:(NSStepper *)sender {
    int value = [sender intValue];
    _wrapColumn.columns = value;
    _wrapColumnTextField.stringValue = [NSString stringWithFormat:@"%i", _wrapColumn.columns];
    [_preferences setWrapColumn:_wrapColumn];
}

- (IBAction) themeNameSelected:(NSComboBox *) sender {
    [_preferences selectTheme:sender.objectValueOfSelectedItem];
}

- (IBAction) userWindowFrameForWrapingCode:(NSButton *)sender {
    
    if (sender.state == 1){
        _wrapColumnTextField.enabled = NO;
        _wrapColumnStepper.enabled = NO;
        _wrapColumn.type = QCCWrapColumnAtFrameSize;
    }else {
        _wrapColumnTextField.enabled = YES;
        _wrapColumnStepper.enabled = YES;
        _wrapColumn.type = QCCWrapColumnValue;
    }
    [_preferences setWrapColumn:_wrapColumn];

}
- (IBAction) unSavedDocumentFolder:(NSComboBox *) sender {
    [_preferences setUnSavedDocumentFolderIndex:sender.indexOfSelectedItem];

}


-(NSSize)contentSize {

    return NSMakeSize(480, 200);
}

@end
