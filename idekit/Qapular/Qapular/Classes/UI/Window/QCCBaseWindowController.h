//
//  QCCBaseWindowController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCBaseWindowController : NSWindowController

+ (instancetype)initFromDefaultWindowNib;
+ (NSString *) interfaceNibName;

@end