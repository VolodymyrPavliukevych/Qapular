//
//  QCCNewFolderWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCNewFolderWindowController.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

@interface QCCNewFolderWindowController () <NSTextFieldDelegate>{
    
    __weak IBOutlet NSTextField         *_resultEssenceNameTextField;
    
    __weak IBOutlet NSButton            *_positiveButton;
    __weak IBOutlet NSButton            *_negativeButton;
    
    QCCProjectGroup                     *_selectedEssence;
    
}

@property (nonatomic, copy) void (^ resultBlock) (QCCProjectEssence *object);

@end

@implementation QCCNewFolderWindowController

- (instancetype) initWithFolder:(QCCProjectGroup *) group completion:(void (^) (QCCProjectEssence *group)) resultBlock {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        
        self.resultBlock = resultBlock;
        _selectedEssence = group;
        
    }
    return self;
}

- (IBAction) cancelAction:(id)sender {
    if (self.resultBlock)
        self.resultBlock(nil);
}


- (IBAction) doneAction:(id)sender {

    _selectedEssence.path = _resultEssenceNameTextField.stringValue;
    
    if (self.resultBlock)
        self.resultBlock(_selectedEssence);
}

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        [self doneAction:nil];
    }
}

@end
