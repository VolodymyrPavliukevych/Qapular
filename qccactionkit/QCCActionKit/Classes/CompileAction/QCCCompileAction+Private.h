//
//  QCCCompileAction+Private.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/19/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <QCCActionKit/QCCActionKit.h>


@interface QCCCompileAction (Private)

- (void) addCompiledProjectFilePath:(NSString *) filePath;
- (NSArray *) compiledProjectFiles;

- (void) addCompiledSourceFilePath:(NSString *) filePath;
- (NSArray *) compiledSourceFiles;

@end
