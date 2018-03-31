//
//  QCCPreferencesLibraryCellView.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPreferencesLibraryCellView.h"

@implementation QCCPreferencesLibraryCellView
-(void)setObjectValue:(id)objectValue {
    if (objectValue && [objectValue isKindOfClass:[NSURL class]]) {
        NSURL *url = (NSURL *) objectValue;
        NSString *path = [url path];
        if (path)
            self.textField.stringValue = path;
        else
            self.textField.stringValue = url.absoluteString;
        
    }
}


@end
