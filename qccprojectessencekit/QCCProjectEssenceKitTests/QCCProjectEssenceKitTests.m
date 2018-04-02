//
//  QCCProjectEssenceKitTests.m
//  QCCProjectEssenceKitTests
//
//  Created by Volodymyr Pavliukevych 2014
//  Copyright (c) Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

@interface QCCProjectEssenceKitTests : XCTestCase

@end

@implementation QCCProjectEssenceKitTests

- (void)setUp {
    [super setUp];

    
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testExample {

    NSURL *url = [[NSURL alloc] initWithString:[@"/Users/Roaming/Library/Application Support/com.qapular.Qapular/packages/8E73C6C6-44F3-497E-8CE4-5A52AA6F8818/1.6.7/cores" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    QCCProjectGroup *root = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey : @"arduino"}
                                                             identifier:nil
                                                             projectURL:url];
    
    QCCProjectEssence *essence = [[QCCProjectEssence alloc] initWithDictionary:@{QCCProjectSourcePathKey : @"file.c"} identifier:nil];
    QCCProjectEssence *essence1 = [[QCCProjectEssence alloc] initWithDictionary:@{QCCProjectSourcePathKey : @"file1.c"} identifier:nil];
    
    essence.parent = root;
    essence1.parent = root;
    
    NSLog(@"%@", root.projectFolderURL.path);
    XCTAssert((essence), @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
