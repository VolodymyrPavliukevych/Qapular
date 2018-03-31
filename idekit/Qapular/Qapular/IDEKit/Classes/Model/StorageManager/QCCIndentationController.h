//
//  QCCIndentationController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSLayoutManager;
@class NSTextStorage;

@interface QCCIndentationController : NSObject

+ (NSString *) indent:(NSString *) string
        inTextStorage:(NSTextStorage *) storage
            withRange:(NSRange) range
     forLayoutManager:(NSLayoutManager *) layoutManager;

@end
