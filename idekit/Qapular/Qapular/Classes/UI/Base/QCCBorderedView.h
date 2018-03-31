//
//  QCCBorderedView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCView.h"

typedef enum : NSUInteger{
    
    QCCBorderedTypeNone            = 0,
    QCCBorderedTypeLeft            = 1 << 0,
    QCCBorderedTypeRight           = 1 << 1,
    QCCBorderedTypeTop             = 1 << 2,
    QCCBorderedTypeButtom          = 1 << 3
    
} QCCBorderedType;



@interface QCCBorderedView : QCCView
@property (nonatomic) QCCBorderedType borderType;
@end
