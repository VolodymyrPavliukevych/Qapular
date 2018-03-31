//
//  QCCWelcomeWindowController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseWindowController.h"

@class QCCWelcomeWindowController;
@protocol QCCWelcomeDelegate <NSObject>

- (void) welcomeWindowController:(QCCWelcomeWindowController *) controller createDocumentWithURL:(NSURL *) url fileType:(NSString *) fileType;

@end

@interface QCCWelcomeWindowController : QCCBaseWindowController
@property (nonatomic, weak) id <QCCWelcomeDelegate> delegate;
@end
