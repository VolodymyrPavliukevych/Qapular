//
//  QCCTemplateFileViewItem.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTemplateFileViewItem.h"
#import "QCCTemplateManager.h"
#import "QCCView.h"
#import "NSColor+QCColor.h"

@interface QCCTemplateFileViewItem () {
    __weak IBOutlet NSTextField     *_titleLabel;
    __weak IBOutlet NSImageView     *_iconImageView;
    __weak IBOutlet QCCView         *_backgroundView;
}

@end

@implementation QCCTemplateFileViewItem

-(void)awakeFromNib {
    [super awakeFromNib];
    if ([self.representedObject isKindOfClass:[NSDictionary class]]) {
        
        
        NSString *title = self.representedObject[QCCProjectSourceTitleKey];
        _titleLabel.stringValue = (title ? title : @"");
        
        NSString *iconName = self.representedObject[QCCProjectSourceIconKey];
        if (iconName)
            _iconImageView.image = [NSImage imageNamed:iconName];
        
    }
}


-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected)
        _backgroundView.backgroundColor = [NSColor colorWithHexString:@"0xf9f9f9"];
    else
        _backgroundView.backgroundColor = [NSColor whiteColor];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if ([_delegate respondsToSelector:@selector(selectTemplate:)])
        [_delegate selectTemplate:self.representedObject];
    
}


@end
