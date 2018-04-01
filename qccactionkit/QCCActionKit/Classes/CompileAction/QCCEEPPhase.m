//
//  QCCEEPPhase.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/20/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCEEPPhase.h"
#import "QCCBasePhase+Private.h"

#import "QCCCompileAction.h"
#import "QCCCompileAction+Private.h"

#import "NSObject+Cast.h"

@interface QCCEEPPhase() {
    id <QCCCompileActionDataSource> _compileActionDataSource;

}

@property (nonatomic, copy) void (^taskFinishedBlock)(QCCTaskManager * manager, NSString *  identefier);
@property (nonatomic, copy) void (^taskReceiveOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^taskReceiveErrorOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);


@end

@implementation QCCEEPPhase

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
        
        /* Only copy section <name> into the output
         $(HARDWARE_FOLDER)tools/avr/bin/avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 /$(TMP_FOLDER)/sketch.cpp.elf /$(TMP_FOLDER)/sketch.cpp.eep
         */
        
        NSMutableArray *args = [NSMutableArray new];
        [args addObjectsFromArray:[self objCopyToolEEPArgs]];
        
        NSString *elfFilePath = [[[self temeroryDirectoryURL] path] stringByAppendingPathComponent:[self compileELFOutputFileName]];
        [args addObject:elfFilePath];
        
        NSString *outputFilePath = [[[self temeroryDirectoryURL] path] stringByAppendingPathComponent:[self compileOutputFileName]];
        [args addObject:outputFilePath];
        
        
        NSString *identefier = [_taskManager launch:NO path:[self objCopyToolPath] withArgs:args fromFolder:nil];
        [_taskManager launchTaskWithIdenefier:identefier];
    }];
    
}

- (NSString *) compileELFOutputFileName {
    return QCCCompileActionELFFileName;
}

- (NSString *) compileOutputFileName {
    return QCCCompileActionEEPFileName;
}

- (NSString *) objCopyToolPath {
    return [_compileActionDataSource objCopyToolPath];
}

- (NSArray *) objCopyToolEEPArgs {
    return [_compileActionDataSource objCopyToolEEPArgs];
}


+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Combining EEP file is in progress.", @"Compile phase description");
}
@end
