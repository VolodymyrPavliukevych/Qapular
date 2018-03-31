//
//  QCCProjectEnvironmentSource.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

static  NSString * _Nonnull QCCProjectEnvironmentSourceDocumentUTTypeOptionKey = @"DocumentUTTypeOption";

@protocol QCCProjectEnvironmentSource <NSObject>

- (nonnull NSArray <NSString *> *) clangOptionsForFileOptions:(nullable NSDictionary <NSString *, NSString *>  *) fileOptions;

@end
