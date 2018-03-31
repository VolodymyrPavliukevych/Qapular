//
//  QCCOpenRecentCellView.m
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCOpenRecentCellView.h"

@implementation QCCOpenRecentCellView

-(void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    
    if (objectValue && [objectValue isKindOfClass:[NSURL class]]) {
        NSURL *url = (NSURL *)objectValue;
        _projectURL = url;
        _projectTitleTextField.stringValue = url.lastPathComponent;
        _projectPathTextField.stringValue = [url.path stringByDeletingLastPathComponent];
        [[_projectPathTextField cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
}



@end
