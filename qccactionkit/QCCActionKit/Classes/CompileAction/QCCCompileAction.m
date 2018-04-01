//
//  QCCCompileAction.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCCompileAction.h"

#import "QCCCompilePhase.h"
#import "QCCArchivePhase.h"
#import "QCCELFPhase.h"
#import "QCCEEPPhase.h"
#import "QCCObjCopyPhase.h"


@implementation QCCCompileAction

NSString *const QCCCompileActionCoreFileName = @"core.a";
NSString *const QCCCompileActionProjectFileName = @"project";
NSString *const QCCCompileActionELFFileName = @"project.elf";
NSString *const QCCCompileActionEEPFileName = @"project.eep";
NSString *const QCCCompileActionHEXFileName = @"project.hex";

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _compiledProjectFiles = [NSMutableArray new];
        _compiledSourceFiles = [NSMutableArray new];
        
    }
    
    return self;
}

+ (NSArray *)phasesQueue {
    return @[[QCCCompilePhase class], [QCCArchivePhase class], [QCCELFPhase class], [QCCEEPPhase class], [QCCObjCopyPhase class]];
}

@end
