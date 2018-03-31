//
//  QCCNewFileWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCNewFileWindowController.h"
#import "QCCTemplateFileViewItem.h"
#import "QCCTemplateCollectionView.h"
#import "NSObject+Cast.h"

#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import "QCCTemplateManager.h"
#import "QCCBaseDocument.h"
#import "QCCBaseDocument+UTType.h"

@interface QCCNewFileWindowController () <NSTextFieldDelegate, QCCTemplateFileViewItemDelegate>{
    
    
    __weak IBOutlet NSTextField         *_resultEssenceNameTextField;
    __weak IBOutlet NSTextField         *_newEssenceTitleTextField;
    
    __weak IBOutlet NSButton            *_positiveButton;
    __weak IBOutlet NSButton            *_negativeButton;
    
    
    
    __weak IBOutlet NSButton            *_headerFileButton;
    __weak IBOutlet NSTextField         *_filePathTextField;
    
    __weak IBOutlet QCCTemplateCollectionView   *_filesCollectionView;
    
    
    NSArrayController                   *_templates;
    NSDictionary                        *_selectedTemplate;
    QCCProjectGroup                     *_parentEssence;
}

@property (nonatomic, copy) void (^ resultBlock) (id object);

@end

@implementation QCCNewFileWindowController

- (instancetype) initWithParentFolder:(QCCProjectGroup *)group templates:(NSArray *) templates completion:(void (^) (id object)) resultBlock {

    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        self.resultBlock = resultBlock;
        _templates = [[NSArrayController alloc] initWithContent:templates];
        
        if ([templates count] == 0 && resultBlock) {
            resultBlock(nil);
        }
        
        
        _parentEssence = group;
    }
    
    return self;
}

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    if (_filesCollectionView && _templates)
        [_filesCollectionView bind:NSContentBinding
                          toObject:_templates
                       withKeyPath:NSStringFromSelector(@selector(arrangedObjects))
                           options:nil];
    
    
    _filesCollectionView.selectable = YES;
    _filesCollectionView.fileTemplateDelegate = self;

    _selectedTemplate = [[_templates arrangedObjects] firstObject];
    
    NSString *path = ([_parentEssence pathInProjectFolder] ? [_parentEssence pathInProjectFolder] : @"");
    
    _filePathTextField.stringValue = path;
    
}


-(void)showWindow:(id)sender {
    [super showWindow:sender];
    
    _newEssenceTitleTextField.stringValue = @"";
    
}

- (IBAction) cancelAction:(id)sender {
    if (self.resultBlock)
        self.resultBlock(nil);
}


- (IBAction) doneAction:(id)sender {
    
    if (!_resultEssenceNameTextField.stringValue || _resultEssenceNameTextField.stringValue.length == 0)
        return;

    
    NSString *extension = [self defaultExtension];
    NSString *fileName = [_resultEssenceNameTextField.stringValue stringByAppendingPathExtension:extension];
    NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:_selectedTemplate];
    object[QCCProjectSourcePathKey] = fileName;
    
    if (_headerFileButton.state != NSOnState)
        [object removeObjectForKey:QCCProjectSourceHeaderTypeKey];
    
    
    if (self.resultBlock)
        self.resultBlock(object);
}

#pragma mark - QCCTemplateManagerWindowControllerDataSource

#pragma mark - QCCTemplateFileViewItemDelegate
-(void)selectTemplate:(id)templateObject {
    
    if (templateObject[QCCProjectSourceHeaderTypeKey])
        _headerFileButton.enabled  = YES;
    else
        _headerFileButton.enabled  = NO;
    
    
    _headerFileButton.state = NSOnState;
    _selectedTemplate = templateObject;
    [self updatePathLabel];
}

#pragma mark - NSTextFieldDelegate
-(BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    return YES;
}
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    return YES;
}
-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        [self doneAction:nil];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    
    [notification.object dependClass:[NSTextField class] performBlock:^(NSTextField *textField) {
        
        if (textField.stringValue.length == 0 || !_selectedTemplate ) {
            _filePathTextField.stringValue = @"";
            return;
        }
        [self updatePathLabel];
    }];
    
}

#pragma mark - Path helper
- (void) updatePathLabel {
    
    if (_resultEssenceNameTextField.stringValue.length == 0) {
        _filePathTextField.stringValue = @"";
        return;
    }
    
    NSString *path = ([_parentEssence pathInProjectFolder] ? [_parentEssence pathInProjectFolder] : @"...");
    NSString *file = (_resultEssenceNameTextField.stringValue ?  _resultEssenceNameTextField.stringValue : @"...");
    NSString *extension = [self defaultExtension];
    NSString *fileName = [file stringByAppendingPathExtension:(extension ? extension : @"...")];
    
    _filePathTextField.stringValue = [path stringByAppendingPathComponent:fileName];
}

- (NSString *) defaultExtension {
    NSString *fileType = _selectedTemplate[QCCProjectSourceFileTypeKey];
    
    NSString *extension = [QCCBaseDocument extensionForUTType:fileType];
    return extension;
    
}


@end
