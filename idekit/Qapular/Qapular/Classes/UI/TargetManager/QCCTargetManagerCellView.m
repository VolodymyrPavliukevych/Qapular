//
//  QCCTargetManagerCellView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTargetManagerCellView.h"
#import "NSObject+Cast.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>


@interface QCCTargetManagerCellView() {
    
    IBOutlet NSTextView            *_descriptionTextView;
    IBOutlet NSButton               *_installButton;
    IBOutlet NSProgressIndicator    *_progressIndicator;
    
    QCCTarget                       *_target;
}

@end


@implementation QCCTargetManagerCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

-(void)setObjectValue:(id)objectValue {

    if(!objectValue)
        return;
    
    [objectValue dependClass:[QCCTarget class] performBlock:^(QCCTarget * target) {
        self.textField.stringValue = target.name;
        _descriptionTextView.string = target.information;
        _target = target;
    }];
    
    _progressIndicator.hidden = YES;
    _progressIndicator.doubleValue = 0;
    _progressIndicator.minValue = 0;
    _progressIndicator.maxValue = [[[[_target schema] dependencyPackageIdentifierSet] allObjects] count];
}

- (IBAction) installAction:(NSButton *) sender {

    if(!_target)
        return;
    
    sender.enabled = NO;
    _progressIndicator.hidden = NO;
    _progressIndicator.doubleValue = 0.1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_delegate installTargetWithIdentefier:_target.identifier completion:^(NSInteger total, NSInteger installed, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _progressIndicator.doubleValue =  installed;
                
                if (error) {
                    NSAlert *errorAlert = [NSAlert alertWithError:error];
                    [errorAlert runModal];
                    sender.enabled = YES;
                }
                
                if (installed == total) {
                    sender.hidden = YES;
                    _progressIndicator.hidden = YES;
                }
            });
        }];
    });
    
}



@end
