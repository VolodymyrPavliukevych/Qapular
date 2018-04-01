//
//  QCCCompilePhase.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/14/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCCompilePhase.h"
#import "QCCCompileActionDataSource.h"
#import "NSObject+Cast.h"
#import "QCCBasePhase+Private.h"
#import "QCCCompileAction+Private.h"
#import "NSObject+Cast.h"

#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

NSString *const QCCCompilePhaseReportSourceFileNameKey      = @"QCCCompilePhaseReportSourceFileName";
NSString *const QCCCompilePhaseReportProjectFileNameKey     = @"QCCCompilePhaseReportProjectFileName";


@interface QCCCompilePhase(){

    NSMutableDictionary *_processingSourceFiles;
    NSMutableDictionary *_processingProjectFiles;

    NSMutableDictionary *_compiledSourceFiles;
    NSMutableDictionary *_compiledProjectFiles;

    id <QCCCompileActionDataSource> _compileActionDataSource;

}

@property (nonatomic, copy) void (^taskFinishedBlock)(QCCTaskManager * manager, NSString *  identefier);
@property (nonatomic, copy) void (^taskReceiveOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);
@property (nonatomic, copy) void (^taskReceiveErrorOutputDataBlock)(QCCTaskManager * manager, NSString *  identefier, NSUInteger lenght);

@end

@implementation QCCCompilePhase
#pragma mark - Task Manager Blocks

-(void (^)(QCCTaskManager * taskManager, NSString *identefier))taskFinishedBlock {
    return ^(QCCTaskManager * taskManager, NSString *identefier) {
        
        NSMutableDictionary *report = [NSMutableDictionary new];
        
        NSString *command = [taskManager launchPathForTaskIdenefier:identefier];
        if (command)
            report[QCCPhaseReportComandKey] = command;
        
        NSArray *commandArgs = [taskManager argsForTaskIdenefier:identefier];
        if (commandArgs)
            report[QCCPhaseReportComandArgsKey] = commandArgs;
        
        
        NSString *output = [[NSString alloc] initWithData:[taskManager outputDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        if (output.length > 0)
            report[QCCPhaseReportOutputKey] = output;
        
        
        NSString *errorOutput = [[NSString alloc] initWithData:[taskManager errorDataForTaskIdenefier:identefier] encoding:NSUTF8StringEncoding];
        if (errorOutput.length > 0) {
            NSRange range = [[errorOutput lowercaseString] rangeOfString:@"error"];
            if (range.location != NSNotFound)
                _result = QCCPhaseResultFail;
            
            report[QCCPhaseReportErrorKey] = errorOutput;
        }
        
        
        if (_processingSourceFiles[identefier])
            report[QCCCompilePhaseReportSourceFileNameKey] = _processingSourceFiles[identefier];
        

        if (_processingProjectFiles[identefier])
            report[QCCCompilePhaseReportProjectFileNameKey] = _processingProjectFiles[identefier];
        
        if (_action.actionReportBlock)
            _action.actionReportBlock(_action, self, report);

        [_action dependClass:[QCCCompileAction class] performBlock:^(QCCCompileAction * compileAction) {
            // If it is core - library source file, add it.
            NSString *sourceFilePath = _compiledSourceFiles[identefier];
            if (sourceFilePath)
                [compileAction addCompiledSourceFilePath:sourceFilePath];
            
            
            // If it is project source file, add it.
            NSString *projectFilePath = _compiledProjectFiles[identefier];
            if (projectFilePath)
                [compileAction addCompiledProjectFilePath:projectFilePath];
            
        }];
        
        
        
        
        if ([taskManager.runingTaskIdentefiers count] == 0) {
            self.phaseFinishedBlock(self);
            //NSLog(@"finished");
        }
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskManager = [[QCCTaskManager alloc] init];
        _taskManager.taskFinishedBlock = self.taskFinishedBlock;
        _compiledSourceFiles = [NSMutableDictionary new];
        _compiledProjectFiles = [NSMutableDictionary new];
        
        _processingSourceFiles = [NSMutableDictionary new];
        _processingProjectFiles = [NSMutableDictionary new];

    }
    return self;
}

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Compiling is in progress.", @"Compile phase description");
}

-(void) launch {

    if (![_action.dataSource conformsToProtocol:@protocol(QCCCompileActionDataSource)]) {
        self.phaseFinishedBlock(self);
        return;
    }
    
    _compileActionDataSource = (id <QCCCompileActionDataSource>) _action.dataSource;

    NSSet *sourceSet = [_compileActionDataSource sourceSet];
    NSSet *projectSourceSet = [_compileActionDataSource projectSourceSet];
    
    for (QCCProjectEssence *essence in [sourceSet allObjects]) {
        [self compileSourceEssence:essence isProjectSource:NO];
    }
    
    for (QCCProjectEssence *essence in [projectSourceSet allObjects]) {
        [self compileSourceEssence:essence isProjectSource:YES];
    }
}

- (void) compileSourceEssence:(QCCProjectEssence *) essence isProjectSource:(BOOL) projectSource {
    
    [essence dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup * group) {
        
        for (NSURL *path in [group allChildrenURLsInRoot]) {

            NSString *extension = [path pathExtension];
            CFStringRef fileUTT = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)(extension), NULL);
            if (UTTypeConformsTo(fileUTT, kUTTypeSourceCode)) {
                [self compileFile:path fileUTT:fileUTT isProjectSource:projectSource];
            }
        }
    }];
}

- (void) compileFile:(NSURL *)filePath fileUTT:(CFStringRef) UTTypeStringRef isProjectSource:(BOOL) projectSource {

    NSString *toolPath = [self compileToolPathForUTTString:UTTypeStringRef];
    NSMutableArray *toolArgs = [NSMutableArray new];
    
    [toolArgs addObjectsFromArray:[self compileArgsForUTTString:UTTypeStringRef]];
    
    for (NSString *includePath in [[self includeSet] allObjects]) {
        NSString *include = [[self includeParametrName] stringByAppendingString:includePath];
        [toolArgs addObject:include];
    }

    // Compiling file
    [toolArgs addObject:filePath.path];
    
    // output
    [toolArgs addObject:[self compileOutputParametrName]];
    NSString *compiledFilePath = [self outputFilePathForFile:filePath.path];
    [toolArgs addObject:compiledFilePath];
    
    NSString *idenefier = [_taskManager launch:NO path:toolPath withArgs:toolArgs fromFolder:nil];
    [_taskManager launchTaskWithIdenefier:idenefier];
    
    if (projectSource && idenefier)
        _processingProjectFiles[idenefier] = filePath.path;
    else if (idenefier)
        _processingSourceFiles[idenefier] = filePath.path;
    
    if (idenefier && compiledFilePath) {
        if (projectSource) {
            _compiledProjectFiles[idenefier] = compiledFilePath;
        } else {
            _compiledSourceFiles[idenefier] = compiledFilePath;
        }
    }
    
}

- (NSString *) compileToolPathForUTTString:(CFStringRef) UTTypeStringRef {
    return [_compileActionDataSource compileToolPathForUTTString:UTTypeStringRef];
}

- (NSArray *) compileArgsForUTTString:(CFStringRef) UTTypeStringRef {
   return [_compileActionDataSource compilingArgsForUTTypeString:UTTypeStringRef];
}

- (NSSet *) includeSet {
    return [_compileActionDataSource includeSet];
}

- (NSSet *) librarySet {
    return [_compileActionDataSource librarySet];
}

- (NSString *) includeParametrName {
    return [_compileActionDataSource includeParametrName];
}

- (NSString *) compileOutputParametrName {
    return [_compileActionDataSource compileOutputParametrName];
}

- (NSString *) compileOutputPathExtension {
    return [_compileActionDataSource compileOutputPathExtension];
}

- (NSString *) outputFilePathForFile:(NSString *) sourceFile {
    
    NSString *fileFullName = [sourceFile lastPathComponent];
/*    NSString *fileName = [fileFullName stringByDeletingPathExtension];*/
    NSString *outputFileName = [fileFullName stringByAppendingPathExtension:[self compileOutputPathExtension]];
    
    return [[[self temeroryDirectoryURL] path] stringByAppendingPathComponent:outputFileName];
}


@end
