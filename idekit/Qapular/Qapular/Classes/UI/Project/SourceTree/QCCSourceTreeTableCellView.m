//
//  QCCSourceTreeTableCellView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCSourceTreeTableCellView.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import "NSObject+Cast.h"


@implementation QCCSourceTreeTableCellView


-(void)setObjectValue:(id)objectValue {
    if (!objectValue)
        return;
    
   [objectValue dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup * object) {
       NSImage *image = [NSImage imageNamed:@"source-tree-folder-icon"];
       [image setTemplate:YES];
       self.imageView.image = image;

       if (!object.valid)
           self.textField.textColor = [NSColor redColor];
       else
           self.textField.textColor = [NSColor blackColor];
    
   }];
    
    [objectValue dependClass:[QCCProjectFile class] performBlock:^(QCCProjectFile * object) {
        NSImage *image = [NSImage imageNamed:@"source-tree-file-icon"];
        [image setTemplate:YES];
        self.imageView.image = image;
        
        if (!object.valid)
            self.textField.textColor = [NSColor redColor];
        else
            self.textField.textColor = [NSColor blackColor];
        
    }];
    
    if ([objectValue respondsToSelector:@selector(path)])
        self.textField.stringValue = [objectValue path];
    else
        NSLog(@"Error with source tree object :%@", objectValue);
    
    self.backgroundStyle = NSBackgroundStyleDark;
    [super setObjectValue:objectValue];
    
}


@end
