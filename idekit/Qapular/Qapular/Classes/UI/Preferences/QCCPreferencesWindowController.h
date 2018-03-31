//
//  QCCPreferencesWindowController.h
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCBaseWindowController.h"

@class QCCDocumentController;

@interface QCCPreferencesWindowController : QCCBaseWindowController
@property (nullable, nonatomic, weak) QCCDocumentController *documentController;
@end
