//
//  QCCArchivePhase.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/14/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCArchivePhase.h"
#import "QCCBasePhase+Private.h"

#import "QCCCompileAction.h"
#import "QCCCompileAction+Private.h"

#import "NSObject+Cast.h"
#import <QCCTaskManagerKit/QCCTaskManagerKit.h>

@interface QCCArchivePhase() {
    id <QCCCompileActionDataSource> _compileActionDataSource;
}

@property (nonatomic, copy) void (^taskFinishedBlock)(QCCTaskManager * manager, NSString *  identefier);
@property (nonatomic, copy) void (^taskReceiveOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^taskReceiveErrorOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);

@end

@implementation QCCArchivePhase
#pragma mark - Task Manager Blocks

-(void (^)(QCCTaskManager * taskManager, NSString *identefier))taskFinishedBlock {
    return ^(QCCTaskManager * taskManager, NSString *identefier) {
        
        NSString *output = [[NSString alloc] initWithData:[taskManager outputDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        if (output.length > 0)
            NSLog(@"Output: %@", output);
        
        NSString *errorOutput = [[NSString alloc] initWithData:[taskManager errorDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        
        if (errorOutput.length > 0) {
            NSRange range = [[errorOutput lowercaseString] rangeOfString:@"error"];
            if (range.location != NSNotFound)
                _result = QCCPhaseResultFail;
            NSLog(@"Error: %@", errorOutput);
        }
        
//        NSLog(@"done: %@", [[taskManager argsForTaskIdenefier:identefier] componentsJoinedByString:@" "]);
        
        if ([taskManager.runingTaskIdentefiers count] == 0)
            self.phaseFinishedBlock(self);
        
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskManager = [[QCCTaskManager alloc] initForSerialTasks];
        _taskManager.taskFinishedBlock = self.taskFinishedBlock;
        
    }
    return self;
}


-(void)launch {
    if (![_action.dataSource conformsToProtocol:@protocol(QCCCompileActionDataSource)]) {
        self.phaseFinishedBlock(self);
        return;
    }
    
    _compileActionDataSource = (id <QCCCompileActionDataSource>) _action.dataSource;

    [_action dependClass:[QCCCompileAction class] performBlock:^(QCCCompileAction * compileAction) {
        for (NSString *compiledFile in [compileAction compiledSourceFiles]) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:compiledFile])
                continue;
            
            NSMutableArray *archiveArgs = [[NSMutableArray alloc] initWithArray:[self archiveToolArgs]];
            NSURL *coreFileURL = [[self temeroryDirectoryURL] URLByAppendingPathComponent:QCCCompileActionCoreFileName];

            [archiveArgs addObject:[coreFileURL path]];
            [archiveArgs addObject:compiledFile];
            
            NSString *identefier = [_taskManager launch:NO path:[self archiveToolPath] withArgs:archiveArgs fromFolder:nil];
            [_taskManager launchTaskWithIdenefier:identefier];
            
        }
    }];

}

- (NSString *) archiveToolPath {
    return [_compileActionDataSource archiveToolPath];
}

- (NSArray *) archiveToolArgs {
    return [_compileActionDataSource archiveToolArgs];
}

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Archive is in progress.", @"Compile phase description");
}

@end
