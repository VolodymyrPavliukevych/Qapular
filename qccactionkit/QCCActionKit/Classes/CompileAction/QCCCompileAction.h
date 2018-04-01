//
//  QCCCompileAction.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <QCCActionKit/QCCActionKit.h>


@interface QCCCompileAction : QCCBaseAction {
    NSMutableArray *_compiledProjectFiles;
    NSMutableArray *_compiledSourceFiles;

}

extern NSString *const QCCCompileActionCoreFileName;
extern NSString *const QCCCompileActionProjectFileName;
extern NSString *const QCCCompileActionELFFileName;
extern NSString *const QCCCompileActionEEPFileName;
extern NSString *const QCCCompileActionHEXFileName;
@end
