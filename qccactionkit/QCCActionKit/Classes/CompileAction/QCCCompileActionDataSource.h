//
//  QCCCompileActionDataSource.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/16/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCCBaseAction.h"

@protocol QCCCompileActionDataSource <QCCBaseActionDataSource>
@required
- (NSString *) projectName;

- (NSSet *) sourceSet;
- (NSSet *) projectSourceSet;

- (NSSet *) librarySet;
- (NSSet *) includeSet;

- (NSArray *) compilingArgsForUTTypeString:(CFStringRef) UTTypeStringRef;
- (NSString *) compileToolPathForUTTString:(CFStringRef) UTTypeStringRef;

- (NSString *) archiveToolPath;
- (NSArray *) archiveToolArgs;

- (NSString *) includeParametrName;
- (NSString *) compileOutputParametrName;
- (NSString *) compileOutputPathExtension;
- (NSString *) executableLinkableFormatToolPath;
- (NSArray *) executableLinkableFormatToolArgs;
- (NSString *) compileLibraryParametrName;

- (NSString *) objCopyToolPath;
- (NSArray *) objCopyToolArgs;
- (NSArray *) objCopyToolEEPArgs;

@end
