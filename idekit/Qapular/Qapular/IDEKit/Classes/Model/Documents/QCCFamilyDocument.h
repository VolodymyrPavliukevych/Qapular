//
//  QCCFamilyDocument.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseDocument.h"

@interface QCCFamilyDocument : QCCBaseDocument
- (QCCodeStorage *) codeStorage;
- (BOOL) loadAnalyzer;
@end
