//
//  QCCWindowTitleBar.m
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCWindowTitleBar.h"
#import "QCCWindowButton.h"
#import "QCCThemaManager.h"



@interface QCCWindowTitleBar() {
    
    IBOutlet QCCWindowButton *_windowCloseButton;
    IBOutlet QCCWindowButton *_windowMiniaturizeButton;
    IBOutlet QCCWindowButton *_windowFullScreenButton;

    IBOutlet NSTextField    *_titleLabel;

}

@end


@implementation QCCWindowTitleBar
#pragma mark - Init
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    
    return self;
}

-(id) awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [super awakeAfterUsingCoder:aDecoder];
}

-(void)awakeFromNib {
    [_windowCloseButton setWindowButtonType:NSWindowCloseButton];
    [_windowMiniaturizeButton setWindowButtonType:NSWindowMiniaturizeButton];
    [_windowFullScreenButton setWindowButtonType:NSWindowFullScreenButton];
    
}


-(BOOL)mouseDownCanMoveWindow {
    return YES;
}
#pragma mark - ThemaManager

- (void) updateColors {
    [super updateColors];
    
    switch (_themaManager.spectrum) {
        case QCCThemaSpectrumUnknown:
            _titleLabel.textColor = [NSColor grayColor];
            break;
            
        case QCCThemaSpectrumDark:
            _titleLabel.textColor = [NSColor lightGrayColor];
            break;
            
        case QCCThemaSpectrumLight:
            _titleLabel.textColor = [NSColor darkGrayColor];
            break;
    }
}
#pragma mark - ViewWillAppear
- (void) setTitle:(NSString *) title {
    if (title)
        _titleLabel.stringValue = title;
}


#pragma mark - Actions
- (IBAction) windowButtonAction:(id)sender {
    if (sender == _windowCloseButton)
        [_delegate titleBarHandleActionWithButton:NSWindowCloseButton];
    
    if (sender == _windowMiniaturizeButton)
        [_delegate titleBarHandleActionWithButton:NSWindowMiniaturizeButton];
    
    if (sender == _windowFullScreenButton)
        [_delegate titleBarHandleActionWithButton:NSWindowFullScreenButton];
}

@end
