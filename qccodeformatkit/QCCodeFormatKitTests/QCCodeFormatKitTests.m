//
//  QCCodeFormatKitTests.m
//  QCCodeFormatKitTests
//
//  Created by Volodymyr Pavliukevych 2014.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <QCCodeFormatKit/QCCodeFormatKit.h>

@interface QCCodeFormatKitTests : XCTestCase {
    
    NSString    *_codeFirstString;
    NSString    *_codeSecondString;
    NSString    *_codeThirdString;
    NSString    *_textFirstString;
    NSString    *_codeCPPString;
    NSString    *_cppHeaderString;
    
    NSString    *_unitestsBundlePath;
    NSString    *_tmpPath;
    
}

@end

@implementation QCCodeFormatKitTests

- (void)setUp {
    [super setUp];
    
    _tmpPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByDeletingLastPathComponent];
    
    _unitestsBundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unitests" ofType:@"bundle"];
    NSError *error;
    
    _codeFirstString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"DS18x20_Temperature.txt"] encoding:NSUTF8StringEncoding error:&error];
    _codeSecondString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"DS2408_Switch.txt"] encoding:NSUTF8StringEncoding error:&error];
    _codeThirdString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"DS250x_PROM.txt"] encoding:NSUTF8StringEncoding error:&error];
    _textFirstString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"keywords.txt"] encoding:NSUTF8StringEncoding error:&error];
    _codeCPPString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"OneWire.cpp.txt"] encoding:NSUTF8StringEncoding error:&error];
    _cppHeaderString = [NSString stringWithContentsOfFile:[_unitestsBundlePath stringByAppendingPathComponent:@"OneWire.h.txt"] encoding:NSUTF8StringEncoding error:&error];
    
    XCTAssertNil(error);
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testCodeFirstStringString {
    NSString *result = [QCCFormater formatCodeString:_codeFirstString];
    
    [[_codeFirstString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"codeFirstString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_codeFirstString.txt"] atomically:YES];
    
    XCTAssertNotNil(result);
}

- (void)testCodeSecondStringString {
    NSString *result = [QCCFormater formatCodeString:_codeSecondString];

    [[_codeSecondString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"codeSecondString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_codeSecondString.txt"] atomically:YES];

    XCTAssertNotNil(result);
}

- (void)testCodeThirdStringString {
    NSString *result = [QCCFormater formatCodeString:_codeThirdString];
    
    [[_codeThirdString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"codeThirdString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_codeThirdString.txt"] atomically:YES];

    XCTAssertNotNil(result);
}

- (void)testTextFirstStringString {
    NSString *result = [QCCFormater formatCodeString:_textFirstString];
    
    [[_textFirstString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"textFirstString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_textFirstString.txt"] atomically:YES];

    XCTAssertNotNil(result);
}

- (void)testCodeCPPStringString {
    NSString *result = [QCCFormater formatCodeString:_codeCPPString];
    
    [[_codeCPPString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"codeCPPString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_codeCPPString.txt"] atomically:YES];

    XCTAssertNotNil(result);
}

- (void)testCppHeaderStringString {
    NSString *result = [QCCFormater formatCodeString:_cppHeaderString];
    
    [[_cppHeaderString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"cppHeaderString.txt"] atomically:YES];
    [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_tmpPath stringByAppendingPathComponent:@"result_cppHeaderString.txt"] atomically:YES];

    XCTAssertNotNil(result);
}

- (void)testEmptyString {
    NSString *result = [QCCFormater formatCodeString:@""];
    XCTAssertNil(result);
}

- (void)testNilString {
    NSString *result = [QCCFormater formatCodeString:nil];
    XCTAssertNil(result);

}


- (void)testPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSString *result = [QCCFormater formatCodeString:_codeCPPString];
        XCTAssertNotNil(result);
    }];
}

@end
