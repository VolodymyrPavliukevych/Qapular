//
//  QCCDeploymentConfigurationKitTests.m
//  QCCDeploymentConfigurationKitTests
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface QCCDeploymentConfigurationKitTests : XCTestCase {
    NSApplication       *_application;
    NSWindow            *_window;
}

@end

@implementation QCCDeploymentConfigurationKitTests

- (void)setUp {
    [super setUp];
    _application = [NSApplication sharedApplication];
    _window = [_application.windows firstObject];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

    NSLog(@"%@", _application);
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
