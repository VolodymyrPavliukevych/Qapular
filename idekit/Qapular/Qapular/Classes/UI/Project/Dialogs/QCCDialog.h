//
//  QCCDialog.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef enum : NSUInteger {
    QCCDialogButtonNone     =   0,
    QCCDialogButtonOK       = 1 << 1,
    QCCDialogButtonCancel   = 1 << 2,
    QCCDialogButtonDelete   = 1 << 3,
} QCCDialogButton;

typedef enum : NSUInteger {
    QCCDialogTypeNone,
    QCCDialogTypeRemovingItem,
    QCCDialogTypeRemovingFolder,
} QCCDialogType;



@interface QCCDialog : NSObject

+ (void) dialogWithType:(QCCDialogType) type onWindow:(NSWindow *) window completionBlock:(void(^)(QCCDialogButton buttonPressed)) block;
+ (void) dialogWithType:(QCCDialogType) type forItem:(NSString *) item onWindow:(NSWindow *) window completionBlock:(void(^)(QCCDialogButton buttonPressed)) block;


@end

