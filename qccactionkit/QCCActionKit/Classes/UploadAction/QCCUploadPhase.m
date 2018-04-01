//
//  QCCUploadPhase.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/20/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCUploadPhase.h"
#import "QCCBasePhase+Private.h"
#import "QCCUploadActionDataSource.h"
#import "QCCUploadAction.h"

#import "NSObject+Cast.h"
#import "QCCCompileAction.h"

@interface QCCUploadPhase() {
    id <QCCUploadActionDataSource> _uploadActionDataSource;
    
}
@property (nonatomic, copy) void (^taskFinishedBlock)(QCCTaskManager * manager, NSString *  identefier);
@property (nonatomic, copy) void (^taskReceiveOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^taskReceiveErrorOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);


@end

@implementation QCCUploadPhase

-(void (^)(QCCTaskManager * taskManager, NSString *identefier))taskFinishedBlock {
    return ^(QCCTaskManager * taskManager, NSString *identefier) {
        
        NSString *output = [[NSString alloc] initWithData:[taskManager outputDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        if (output.length > 0)
            NSLog(@"Output: %@", output);
        
        NSString *errorOutput = [[NSString alloc] initWithData:[taskManager errorDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        
        if (errorOutput.length > 0)
            NSLog(@"Error: %@", errorOutput);
        
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

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Uploading is in progress.", @"Clear phase description");
}

-(void) launch {
    if (![_action.dataSource conformsToProtocol:@protocol(QCCUploadActionDataSource)]) {
        self.phaseFinishedBlock(self);
        return;
    }
    
    _uploadActionDataSource = (id <QCCUploadActionDataSource>) _action.dataSource;
    
    [_action dependClass:[QCCUploadAction class] performBlock:^(QCCUploadAction * uploadAction) {
        
        NSUInteger numberOfStepsInAction = 0;
        
        if ([_uploadActionDataSource respondsToSelector:@selector(numberOfStepsForPhase:InAction:)])
            numberOfStepsInAction = [_uploadActionDataSource numberOfStepsForPhase:self InAction:uploadAction];
        
        for (NSUInteger stepIndex = 0; stepIndex < numberOfStepsInAction; stepIndex++) {
            
            NSString * launchPath = [_uploadActionDataSource launchPathForStepNumber:stepIndex phase:self inAction:uploadAction];
            NSArray * launchArgs = [_uploadActionDataSource launchArgsForStepNumber:stepIndex phase:self inAction:uploadAction];
            NSString *launchFolder = [_uploadActionDataSource launchFolderPathForStepNumber:stepIndex phase:self inAction:uploadAction];
            
            if (!launchPath || launchPath.length == 0)
                continue;
            
            NSString *identefier = [_taskManager launch:NO path:launchPath withArgs:launchArgs fromFolder:launchFolder];
            [_taskManager launchTaskWithIdenefier:identefier];
        }
    }];
}


@end
