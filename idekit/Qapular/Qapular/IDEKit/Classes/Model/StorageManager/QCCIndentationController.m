//
//  QCCIndentationController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCIndentationController.h"
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextStorage.h>

@implementation QCCIndentationController

static NSString *const QCCIndentTrigerString    = @"\n";
static NSString *const QCCIndentSpaceString     = @" ";
static NSString *const QCCIndentTabString       = @"\t";
static const NSUInteger countSpaceInTab         = 3;

+ (NSString *) indent:(NSString *) string inTextStorage:(NSTextStorage *) storage withRange:(NSRange) range forLayoutManager:(NSLayoutManager *) layoutManager{

    if (![string isEqualToString:QCCIndentTrigerString] || range.location == 0)
        return nil;
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:--range.location];
    NSRange effectiveRange;
    [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&effectiveRange];
    
    NSRange leftLineRange = NSMakeRange(effectiveRange.location,  ++range.location - effectiveRange.location);
    
    NSMutableString *relatedLineString = [NSMutableString stringWithString:[storage.string substringWithRange:leftLineRange]];

    static NSMutableString *tabeForChange;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabeForChange = [NSMutableString new];
        for (int i=0; i < countSpaceInTab; i++) {
            [tabeForChange appendString:QCCIndentSpaceString];
        }
    });
    
    [relatedLineString replaceOccurrencesOfString:QCCIndentTabString
                                       withString:tabeForChange
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [relatedLineString length])];
    
    if (![relatedLineString hasSuffix:@"{"])
        return nil;
    
    
    NSError *error = NULL;
    //NSString *objReturn = @"[-\\s*\\(\\w+\\s*\\*\\s*\\)\\s*]?";
    NSString *funcName = @"(\\w+\\s*\\w+|\\w+)";
    NSString *anySpace = @"\\s*";
    NSString *dubleDots = @"\\:?";
    NSString *breaket = @"\\(";
    NSString *anyArguments = @"[A-Z0-9a-z)*:,=<>+-;\\s]*";
    NSString *openBreaket = @"\\{+";

    
    NSMutableString *pattern = [NSMutableString new];
    //[pattern appendString:objReturn];
    [pattern appendString:funcName];
    [pattern appendString:anySpace];
    [pattern appendString:dubleDots];
    [pattern appendString:anySpace];
    [pattern appendString:breaket];
    [pattern appendString:anyArguments];
    [pattern appendString:anySpace];
    [pattern appendString:anyArguments];
    [pattern appendString:anySpace];
    [pattern appendString:openBreaket];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    __block NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    [regex enumerateMatchesInString:relatedLineString
                            options:0
                              range:NSMakeRange(0, relatedLineString.length)
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             
                             NSUInteger matchIndex = match.numberOfRanges - 1;
                             matchedRange = [match rangeAtIndex:matchIndex];
                             
                         }];
    
    if (matchedRange.location == NSNotFound)
        return nil;

//    NSLog(@"related: '%@'", [relatedLineString substringWithRange:matchedRange]);
//    NSLog(@"add %lu spaces", matchedRange.location);
    
    NSMutableString *resultString = [[NSMutableString alloc] initWithString:@"\n"];
    for (int i = 0; i < matchedRange.location; i++) {
        [resultString appendString:QCCIndentSpaceString];
        
    }
    
    [resultString appendString:@"}\n"];
    
    return resultString;
}

@end
