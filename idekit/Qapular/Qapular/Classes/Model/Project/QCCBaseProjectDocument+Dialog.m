//
//  QCCBaseProjectDocument+Dialog.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseProjectDocument+Dialog.h"
#import "QCCProjectWindowController.h"


@implementation QCCBaseProjectDocument (Dialog)

- (void) dialogWithType:(QCCDialogType) type
        completionBlock:(void(^)(QCCDialogButton buttonPressed)) block {
    
    [QCCDialog dialogWithType:type
                     onWindow:_projectWindowController.window
              completionBlock:block];
}


- (void) dialogWithType:(QCCDialogType) type
                forItem:(NSString *) item
        completionBlock:(void(^)(QCCDialogButton buttonPressed)) block {
    
    [QCCDialog dialogWithType:type
                      forItem:item
                     onWindow:_projectWindowController.window
              completionBlock:block];
    
}

@end
