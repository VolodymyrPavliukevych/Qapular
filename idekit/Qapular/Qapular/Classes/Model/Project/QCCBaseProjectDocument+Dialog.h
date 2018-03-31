//
//  QCCBaseProjectDocument+Dialog.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseProjectDocument.h"
#import "QCCDialog.h"

@interface QCCBaseProjectDocument (Dialog)

- (void) dialogWithType:(QCCDialogType) type
        completionBlock:(void(^)(QCCDialogButton buttonPressed)) block;


- (void) dialogWithType:(QCCDialogType) type
                forItem:(NSString *) item
        completionBlock:(void(^)(QCCDialogButton buttonPressed)) block;
@end
