//
//  QCCBaseDocument+UTType.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2015 Qapular. All rights reserved.
//

#import "QCCBaseDocument.h"

@interface QCCBaseDocument (UTType)

+ (NSString *) extensionForUTType:(NSString *) type;
- (CFStringRef) unSavedDefaultUTType;
- (NSString *) UTIString;
@end
