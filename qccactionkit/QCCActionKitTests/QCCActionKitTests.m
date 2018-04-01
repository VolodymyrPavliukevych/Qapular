//
//  QCCActionKitTests.m
//  QCCActionKitTests
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import <QCCActionKit/QCCActionKit.h>
#import <QCCTaskManagerKit/QCCTaskManagerKit.h>
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

@interface QCCActionKitTests : XCTestCase <QCCBaseActionDataSource, QCCCompileActionDataSource> {
    NSURL *_temeroryDirectoryURL;
    
    NSArray     *_librariesArray;
    NSArray     *_includesArray;
    NSArray     *_sourcesArray;

}

@end

@implementation QCCActionKitTests

#pragma mark - QCCBaseActionDataSource
- (NSURL *)temeroryDirectoryURL {
    return _temeroryDirectoryURL;
}

#pragma mark -  QCCCompileActionDataSource
- (NSArray *) compilingArgsForUTTypeString:(CFStringRef) UTTypeStringRef {
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeAssemblyLanguageSource))
        return @[];
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeCPlusPlusSource))
        return @[@"-c", @"-g", @"-Os", @"-Wall", @"-Wextra", @"-Wunused-parameter", @"-Wno-error=unused-parameter", @"-fno-exceptions", @"-ffunction-sections", @"-fdata-sections", @"-fno-threadsafe-statics", @"-MMD", @"-mmcu=atmega328p", @"-DF_CPU=16000000L", @"-DARDUINO=10604", @"-DARDUINO_AVR_UNO", @"-DARDUINO_ARCH_AVR"];
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeCSource))
        return @[@"-c", @"-g", @"-Os", @"-Wall", @"-Wextra", @"-ffunction-sections", @"-fdata-sections", @"-MMD", @"-mmcu=atmega328p", @"-DF_CPU=16000000L", @"-DARDUINO=10604", @"-DARDUINO_AVR_UNO", @"-DARDUINO_ARCH_AVR"];

    return @[];
    
}

- (NSString *) compileToolPathForUTTString:(CFStringRef) UTTypeStringRef {
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeAssemblyLanguageSource))
        return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-as";
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeCPlusPlusSource))
        return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-g++";
    
    if (UTTypeConformsTo(UTTypeStringRef, kUTTypeCSource))
        return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-gcc";

    return nil;
}

- (NSString *) archiveToolPath {
    return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-ar";
}

- (NSArray *) archiveToolArgs {
    return @[@"rcs"];
}

- (NSSet *) librarySet {
    return [NSSet setWithArray:@[]];
}
- (NSSet *) includeSet {
    return [NSSet setWithArray:@[
                                 @"/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/variants/standard/",
                                 @"/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/cores/arduino/"]];

}

- (NSString *) includeParametrName {
    return @"-I";
}

- (NSString *) compileOutputParametrName {
    return @"-o";
}

- (NSString *) compileOutputPathExtension {
    return @"o";
}

- (NSString *) projectName {
    return @"testProject";
}

- (NSString *) objCopyToolPath {
    return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-objcopy";
}

- (NSArray *) objCopyToolArgs {
    return @[@"-O", @"ihex", @"-R", @".eeprom"];
}
- (NSArray *) objCopyToolEEPArgs {
    return @[@"-O", @"ihex", @"-j", @".eeprom", @"--set-section-flags=.eeprom=alloc,load", @"--no-change-warnings", @"--change-section-lma", @".eeprom=0"];
}

- (NSSet *) sourceSet {
    NSMutableArray *array = [NSMutableArray new];

    [array addObject:[self sourceForString:@"/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/cores/" withGroup:@"arduino"]];
    return [NSSet setWithArray:array];
}

-(NSSet *)projectSourceSet {
    NSMutableArray *array = [NSMutableArray new];
    
    [array addObject:[self sourceForString:_temeroryDirectoryURL.path withGroup:@"src"]];
    
    return [NSSet setWithArray:array];
}

- (NSString *) executableLinkableFormatToolPath {
    return @"/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin/avr-gcc";
}

- (NSArray *) executableLinkableFormatToolArgs {
    return @[@"-Wall", @"-Wextra", @"-Os", @"-Wl,--gc-sections", @"-mmcu=atmega328p", @"-lm"];
}
- (NSString *) compileLibraryParametrName {
    return @"-L";
}


- (QCCProjectGroup *) sourceForString:(NSString *) path withGroup:(NSString *) groupName {
    NSURL *url = [[NSURL alloc] initWithString:path];
    
    QCCProjectGroup *arduinoCoreSourceGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey: groupName,
                                                                                            QCCProjectSourceRootFileKey : @(YES)}
                                                                               identifier:nil
                                                                               projectURL:url];
    NSError *error;
    NSString *folder = [arduinoCoreSourceGroup.projectFolderURL.path stringByAppendingPathComponent:arduinoCoreSourceGroup.path];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];

    for (NSString *file in files) {
        
        if ([[file pathExtension] isEqualToString:@"cpp"] || [[file pathExtension] isEqualToString:@"c"] || [[file pathExtension] isEqualToString:@"S"]) {
            QCCProjectFile *projectFile = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : file} identifier:nil];
            projectFile.parent = arduinoCoreSourceGroup;
        }
    }
    return arduinoCoreSourceGroup;
}

- (void)setUp {
    [super setUp];

    NSError *error;
    NSString *tempUUID = [[[NSProcessInfo processInfo] globallyUniqueString] lowercaseString];
    NSURL *directoryURL = [[NSURL alloc] initWithString:[NSTemporaryDirectory() stringByAppendingPathComponent:tempUUID]];
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:directoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
    if (result)
        _temeroryDirectoryURL = directoryURL;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"build" ofType:@"bundle"];

    NSArray *sources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    for (NSString *sourceFile in sources) {
        NSString *filePath = [path stringByAppendingPathComponent:sourceFile];
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:[_temeroryDirectoryURL.path stringByAppendingPathComponent:sourceFile] error:&error];
    }
    
    
    
//    for (int idx = 0; idx < 100; idx++) {
//        NSString *content = [NSString stringWithFormat:@"\n\ntest file for idx: %i\n\n", idx];
//        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
//        NSURL *fileURL = [_temeroryDirectoryURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
//        [data writeToFile:[fileURL filePathURL].path atomically:YES];
//    }
}

- (void) prepareForCompiling {
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void) testCompileAction {
    QCCProjectEssence *essence = [[QCCProjectEssence alloc] initWithDictionary:@{QCCProjectSourcePathKey : @"file.c"} identifier:nil];
    
    QCCCompileAction *action = [QCCCompileAction new];
    action.dataSource = self;
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    action.actionProgressBlock = ^(QCCBaseAction *action,  NSProgress *progress, NSError *error) {
        NSLog(@"progress %@ : %llu", progress.localizedDescription , progress.completedUnitCount);
        if (error)
            NSLog(@"Error: %@", error);
        
//        if ([action isKindOfClass:[QCCArchivePhase class]] && progress.totalUnitCount == progress.completedUnitCount)
            dispatch_semaphore_signal(semaphore);
    };
    NSLog(@"tmp: %@", _temeroryDirectoryURL.path);
    
    action.actionReportBlock = ^(QCCBaseAction *action, QCCBasePhase *phase, NSDictionary *report) {
    
        NSLog(@"report: %@", report);
    };
    
    
    [action start];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    XCTAssert((essence), @"Pass");

}
 

/*
- (void)testClearAction {
    if (!_temeroryDirectoryURL)
        XCTAssert(NO, @"Pass");
    NSLog(@"Clear URL:%@", _temeroryDirectoryURL);
    
    
    QCCClearAction *action = [QCCClearAction new];
    action.dataSource = self;
    [action start];
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    action.actionProgressBlock = ^(QCCBaseAction *action,  NSProgress *progress, NSError *error) {
        NSLog(@"progress: %llu", progress.completedUnitCount);
        if (progress.totalUnitCount == progress.completedUnitCount)
            dispatch_semaphore_signal(semaphore);
    };

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssert(YES, @"Pass");
}
*/



@end
