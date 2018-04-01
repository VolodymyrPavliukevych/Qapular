//
//  QCCELFPhase.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/14/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCELFPhase.h"
#import "QCCBasePhase+Private.h"

#import "QCCCompileAction.h"
#import "QCCCompileAction+Private.h"

#import "NSObject+Cast.h"

@interface QCCELFPhase() {
    id <QCCCompileActionDataSource> _compileActionDataSource;

}

@property (nonatomic, copy) void (^taskFinishedBlock)(QCCTaskManager * manager, NSString *  identefier);
@property (nonatomic, copy) void (^taskReceiveOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^taskReceiveErrorOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);


@end

@implementation QCCELFPhase

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
        
        NSMutableArray *args = [NSMutableArray new];
        [args addObjectsFromArray:[self executableLinkableFormatToolArgs]];
        [args addObject:[self compileOutputParametrName]];

        NSString *outputFilePath = [[[self temeroryDirectoryURL] path] stringByAppendingPathComponent:[self compileOutputFileName]];
        [args addObject:outputFilePath];
        
        for (NSString *projectFile in [compileAction compiledProjectFiles]) {
            [args addObject:projectFile];
        }
        
        NSURL *coreFileURL = [[self temeroryDirectoryURL] URLByAppendingPathComponent:QCCCompileActionCoreFileName];
        [args addObject:[coreFileURL path]];
        
        for (NSString *libraryFolder in [self libraryFolderArray]) {
            NSString *libraryArg =  [[self compileLibraryParametrName] stringByAppendingString:libraryFolder];
            [args addObject:libraryArg];
        }
        
        NSString *identefier = [_taskManager launch:NO path:[self executableLinkableFormatToolPath] withArgs:args fromFolder:nil];
        [_taskManager launchTaskWithIdenefier:identefier];
        
    }];
    
    
}



- (NSArray *) libraryFolderArray {
    return @[[self temeroryDirectoryURL].path];
}

- (NSString *) compileOutputFileName {
    return QCCCompileActionELFFileName;
}

- (NSString *) compileOutputParametrName {
    return [_compileActionDataSource compileOutputParametrName];
}

- (NSString *) executableLinkableFormatToolPath {
    return [_compileActionDataSource executableLinkableFormatToolPath];
}

- (NSArray *) executableLinkableFormatToolArgs {
    return [_compileActionDataSource executableLinkableFormatToolArgs];
}

- (NSString *) compileLibraryParametrName {
    return [_compileActionDataSource compileLibraryParametrName];
}

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Removing unused symbols.", @"Compile phase description");
}


@end
