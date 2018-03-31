//
//  QCCFamilyAnalyser.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QCCProjectEnvironmentSource.h"
#import "QCCAnalyser.h"

@class QCCFamilyDocument;

@interface QCCFamilyAnalyser : QCCAnalyser {

    
}

@property (nonatomic, weak) id <QCCProjectEnvironmentSource> projectEnvironmentSource;

- (instancetype) initForDocument:(QCCFamilyDocument *) document
                       themaManager:(QCCThemaManager *) themaManager
                          projectEnvironmentSource:(id <QCCProjectEnvironmentSource>) projectEnvironmentSource;

- (void) setClangArgs:(NSArray *) args;

@end
