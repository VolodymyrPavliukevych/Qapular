//
//  QCCHighlighter.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QCCodeStorage;
@class QCCThemaManager;


@interface QCCHighlighter : NSObject {
    
    QCCodeStorage       *_codeStorage;
    QCCThemaManager     *_themaManager;
    
}


- (instancetype) initWithCodeStorage:(QCCodeStorage *) codeStorage themaManager:(QCCThemaManager *) themaManager;
- (BOOL) highlighteByTokenArray:(NSArray *) tokens;

@end
