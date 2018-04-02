//
//  QCCTaskManagerKitTests.m
//  QCCTaskManagerKitTests
//
//  Created by Volodymyr Pavliukevych
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <QCCTaskManagerKit/QCCTaskManagerKit.h>

@interface QCCTaskManagerKitTests : XCTestCase {
    QCCTaskManager      *_manager;
    NSArray             *_searchKeys;
    NSMutableArray      *_taskIdentefiers;
}

@end

@implementation QCCTaskManagerKitTests

- (void)setUp {
    [super setUp];
    _manager = [[QCCTaskManager alloc] initForSerialTasks];
    _searchKeys = @[@"import" /*, @"src", @"library", @"home", @"include"*/];
    _taskIdentefiers = [NSMutableArray new];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    return;
//    
//    QCCTask *task = [[QCCTask alloc] init];
//    [task launchedTask:NO
//        withLaunchPath:@"/usr/bin/grep"
//             arguments:@[@"-R", @"intel", @"/Applications/Xcode.app/Contents/Developer/Toolchains/"]
//     fromDirectoryPath:nil];
//    
//    
//    task.errorDataCallbackBlock = ^(NSUInteger lenght, QCCTask *someTask) {
//        NSLog(@"error lenght: %lu", lenght);
//        NSLog(@"error:\n\n%@\n\n", [[NSString alloc] initWithData:someTask.errorData encoding:NSUTF8StringEncoding]);
//    };
//    
//    task.outputDataCallbackBlock = ^(NSUInteger lenght, QCCTask *someTask) {
//        NSLog(@"lenght->: %lu", lenght);
//        NSLog(@"output:\n\n%@\n\n", [[NSString alloc] initWithData:someTask.outputData encoding:NSUTF8StringEncoding]);
//    };
//    
//    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    NSLog(@"start");
//    
//    task.finishedCallbackBlock = ^(QCCTask *someTask) {
//        dispatch_semaphore_signal(semaphore);
//    };
//    
//    [task launch];
//
//    
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
////        dispatch_semaphore_signal(semaphore);
////    });
//    
//    NSLog(@"pre");
//
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"finish");
//
////    [task terminate];
//    
//    XCTAssert((task.outputData || task.errorData), @"Pass");
//}



-(void) testLaunchWithTaskManager {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    
    _manager.taskFinishedBlock = ^(QCCTaskManager *__nonnull manager, NSString * identefier) {
        NSLog(@"finished: %lu", [[manager finishedTaskIdentefiers] count]);

        NSData *output = [manager outputDataForTaskIdenefier:identefier];
        
        NSLog(@"output: %@", [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding]);
        
        if ([[manager finishedTaskIdentefiers] count] == [[manager taskIdentefiers] count])
            dispatch_semaphore_signal(semaphore);
    };
    
    _manager.taskReceiveOutputDataBlock = ^(QCCTaskManager *__nonnull manager, NSString * identefier, NSUInteger lenght) {
        NSLog(@"taskReceiveOutputDataBlock: %@ %lu", identefier, lenght);
    };

    _manager.taskReceiveErrorOutputDataBlock = ^(QCCTaskManager *__nonnull manager, NSString * identefier, NSUInteger lenght) {
        NSLog(@"taskReceiveErrorOutputDataBlock: %@ %lu", identefier, lenght);
    };
    
    for (NSString *key in _searchKeys) {
        NSString *taskIdentefier = [_manager launch:NO path:@"/usr/bin/grep" withArgs:@[@"-R", key, @"/Applications/Xcode.app/Contents/Developer/Toolchains/"] fromFolder:nil];
        if (!taskIdentefier) {
            NSLog(@"Can't create task for key: %@", key);
            continue;
        }
        
        [_taskIdentefiers addObject:taskIdentefier];
        [_manager launchTaskWithIdenefier:taskIdentefier];
        
        NSLog(@"%@ %@ %@",
              [_manager launchPathForTaskIdenefier:taskIdentefier],
              [[_manager argsForTaskIdenefier:taskIdentefier] componentsJoinedByString:@" "],
              [_manager launchFolderForTaskIdenefier:taskIdentefier]);
    }
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    NSUInteger count = [[_manager taskIdentefiers] count];
    XCTAssert((count != 0), @"Pass");
    
}



//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
