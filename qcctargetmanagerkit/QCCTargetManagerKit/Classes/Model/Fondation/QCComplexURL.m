//
//  QCCPackageURL.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych on 2015
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCComplexURL.h"
#import "QCCPackage.h"

static NSString *const QCCEnvironmentKeyPattern     = @"\\$\\((.*?)\\)";
static NSString *const QCCPackageURLLinkPattern     = @"\\$\\{(.*?)\\}";

NSString *const QCCPackageURLAnchorKey              = @"PACKAGE";
NSString *const QCCPackageURLContainerAnchorKey       = @"PACKAGE_CONTAINER";

static NSString *const QCCPackagePathSeparator          = @"/";
static NSString *const QCCPackageLinkSeparator          = @":";


@implementation NSString (TargetManager)

- (NSArray *) valuePathComponents {
    return [self componentsSeparatedByString:QCCPackagePathSeparator];
}

@end


@interface QCComplexURL () {

    QCCPackage  *_basePackage;
    NSString    *_basePackageIdentifier;
    NSString    *_packageString;
    NSArray     *_pathComponents;
    NSArray     *_processedComponents;
}

@property (nonatomic, copy) QCCPackage * (^ packageManagerBlock)(NSString *identifier);
@property (nonatomic, copy) NSString * (^ environmentBlock)(NSString *environmentKey);

@end

@implementation QCComplexURL

- (instancetype) initWithString:(NSString *) string
                 packageManager:(QCCPackage * (^)(NSString *identifier)) managerBlock
                    environment:(NSString * (^)(NSString *environmentKey)) environmentBlock  {
    self = [self initWithString:string packageManager:managerBlock];
    
    self.environmentBlock = environmentBlock;
    
    return self;
    
}
- (instancetype) initWithString:(NSString *) string packageManager:(QCCPackage * (^)(NSString *identifier)) managerBlock {
    
    self = [super init];
    if (self) {
        
        _packageString = string;
        _pathComponents = [string valuePathComponents];
        if ([_pathComponents count] == 0)
            return nil;
        
        self.packageManagerBlock = managerBlock;
        
    }
    
    return self;
}

- (NSString *) processConponent:(NSString *) component
                      key:(NSString * (^)(NSString *key)) keyProcessorBlock
                     link:(NSString * (^)(NSString *key, NSString *value)) linkProcessorBlock {

    __block NSString *returnValue = nil;
    
    NSRange componentRange = NSMakeRange(0, [component length]);
    
    NSRegularExpression *linkRegex = [self linkRegularExpression];
    NSRegularExpression *environmentRegex = [self environmentRegularExpression];

    
    [linkRegex enumerateMatchesInString:component options:0 range:componentRange usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags , BOOL *stop){
        NSUInteger numberOfRanges = [match numberOfRanges];
        if (numberOfRanges > 1) {
            NSString *linkString = [component substringWithRange:[match rangeAtIndex:numberOfRanges-1]];
            NSArray *linkComponents = [linkString componentsSeparatedByString:QCCPackageLinkSeparator];
            if ([linkComponents count] == 2)
                returnValue = linkProcessorBlock([linkComponents firstObject], [linkComponents lastObject]);
        }
    }];

    [environmentRegex enumerateMatchesInString:component options:0 range:componentRange usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags , BOOL *stop){
        NSUInteger numberOfRanges = [match numberOfRanges];
        if (numberOfRanges > 1) {
            NSString *environmentString = [component substringWithRange:[match rangeAtIndex:numberOfRanges-1]];
            returnValue = keyProcessorBlock(environmentString);
        }
    }];

    return returnValue;
}

- (NSRegularExpression *) linkRegularExpression {
    NSError *error;
    return [NSRegularExpression regularExpressionWithPattern:QCCPackageURLLinkPattern options:NSRegularExpressionCaseInsensitive error:&error];
}

- (NSRegularExpression *) environmentRegularExpression {
    NSError *error;
    return [NSRegularExpression regularExpressionWithPattern:QCCEnvironmentKeyPattern options:NSRegularExpressionCaseInsensitive error:&error];
}


- (NSArray *) pathComponents {
    return _pathComponents;
}

- (nullable NSString *) packageIdentifier {
    return [self basePackageIdentifier];
}

- (nullable NSString *) basePackageIdentifier {
    if (_basePackageIdentifier)
        return  _basePackageIdentifier;
    
    NSString *baseComponent = [_pathComponents firstObject];
    __block NSString *keyValue;
    NSRange range = NSMakeRange(0, baseComponent.length);
    NSRegularExpression *linkRegex = [self linkRegularExpression];
    
    [linkRegex enumerateMatchesInString:baseComponent options:0 range:range usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags , BOOL *stop){
        NSUInteger numberOfRanges = [match numberOfRanges];
        if (numberOfRanges > 1)
            keyValue = [baseComponent substringWithRange:[match rangeAtIndex:numberOfRanges-1]];
    }];
    
    NSArray *keyValueComponents = [keyValue componentsSeparatedByString:QCCPackageLinkSeparator];
    
    if ([keyValueComponents count] != 2)
        return nil;
    
    if ([[keyValueComponents firstObject] isEqualToString:QCCPackageURLAnchorKey]) {
        _basePackageIdentifier = [keyValueComponents lastObject];
        return _basePackageIdentifier;
    }
    
    return nil;
}


- (QCCPackage *) basePackage {
    if (_basePackage)
        return _basePackage;
    
    if (self.packageManagerBlock && [self basePackageIdentifier])
        _basePackage = self.packageManagerBlock([self basePackageIdentifier]);

    return _basePackage;
}


- (NSArray *) processedComponents {
    if (_processedComponents)
        return _processedComponents;
    
    __block NSMutableArray *components = [NSMutableArray new];
    QCCPackage  *package = [self basePackage];

    [_pathComponents enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {

        if (idx == 0 && package) {
            NSString *packagePath = [[QCCPackage storageFolder] stringByAppendingPathComponent:[self basePackageIdentifier]];
            if (packagePath)
                [components addObject:packagePath];
        }else {
            
            NSString *processedValue = [self processConponent:obj
                                                          key:^NSString * (NSString *key) {
                                                              if (self.environmentBlock)
                                                                  return self.environmentBlock(key);
                                                              return nil;
                                                              
                                                          } link:^NSString *(NSString *key, NSString *value) {
                                                              
                                                              if([key isEqualTo:QCCPackageURLContainerAnchorKey])
                                                                  return [package containerPathForKey:value];
                                                              
                                                              return nil;
                                                          }];
            
            if (processedValue)
                [components addObject:processedValue];
        }
    }];
    
    _processedComponents = [NSArray arrayWithArray:components];
    
    return _processedComponents;
}

- (NSDictionary *) packageBranchForKey:(NSString *) key {

    if (![self basePackage]|| !key)
        return nil;
    
    if ([key isEqualToString:QCCPackageURLContainerAnchorKey])
        return  [[self basePackage] valueForKey:QCCPackageContainerKey];

    return nil;
    
}

- (NSString *) fullPath {
    if ([[self processedComponents] count] == 0 || ![self processedComponents])
        return _packageString;
    
    return [[self processedComponents] componentsJoinedByString:QCCPackagePathSeparator];
}


-(NSString *)description {
    
    return [self fullPath];
}

@end
