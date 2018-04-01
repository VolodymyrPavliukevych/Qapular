//
//  QCCCompileAction+Private.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/19/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCCompileAction+Private.h"

@implementation QCCCompileAction (Private)



- (void) addCompiledProjectFilePath:(NSString *) filePath {
    if(filePath)
        [_compiledProjectFiles addObject:filePath];
}

- (NSArray *) compiledProjectFiles {
    return _compiledProjectFiles;
}

- (void) addCompiledSourceFilePath:(NSString *) filePath {
    if (filePath)
        [_compiledSourceFiles addObject:filePath];
}

- (NSArray *) compiledSourceFiles {
    return _compiledSourceFiles;
}


@end
