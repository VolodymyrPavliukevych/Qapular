//
//  QCCHighlighter.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCHighlighter.h"

@interface QCCHighlighter() 

@end

@implementation QCCHighlighter

- (instancetype) initWithCodeStorage:(QCCodeStorage *) codeStorage themaManager:(QCCThemaManager *) themaManager {

    self = [super init];

    if (self) {
    
        _codeStorage = codeStorage;
        _themaManager = themaManager;
    
    }
    
    return self;
}

- (BOOL) highlighteByTokenArray:(NSArray *) tokens {

    return NO;
}

@end
