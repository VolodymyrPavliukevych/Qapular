//
//  CKFixItManager.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "CKFixItManager.h"
#import "CKDiagnostic.h"
#import "CKClangGeometry.h"


@implementation CKFixItManager

@synthesize string = _string;
@synthesize range  = _range;

+ (NSArray *)fixItsForDiagnostic: (CKDiagnostic *)diagnostic {
    
    NSMutableArray * fixIts;
    CKFixItManager * fixIt;
    
    unsigned int countOfFixIt = clang_getDiagnosticNumFixIts(diagnostic.cxDiagnostic);
    fixIts = [NSMutableArray new];
    
    for (unsigned int i = 0; i < countOfFixIt; i++) {
        fixIt = [self fixItWithDiagnostic:diagnostic index:i];
        
        if (fixIt) {
            [ fixIts addObject:fixIt];
        }
    }
    
    return [NSArray arrayWithArray: fixIts];
}

+ (id)fixItWithDiagnostic:(CKDiagnostic *) diagnostic index:(NSUInteger)index {
    
    CKFixItManager *manager = [[CKFixItManager alloc] initWithDiagnostic:diagnostic index:index];
    return manager;
}

- (id)initWithDiagnostic: (CKDiagnostic *)diagnostic index: (NSUInteger)index {
    CXSourceRange range;
    CXString      string;
    
    self = [super init];
    if(self) {
        
        string  = clang_getDiagnosticFixIt(diagnostic.cxDiagnostic, (unsigned int)index, &range);
        _string = [[NSString alloc] initWithCString: clang_getCString(string) encoding: NSUTF8StringEncoding];
        
        _range = NSRangeFromCXSourceRange(range);
        clang_disposeString(string);
    }
    
    return self;
}

-(void)dealloc {
}


- (NSString *)description {
    NSString * description;
    
    description = [super description];
    description = [description stringByAppendingFormat: @": %@ %@", self.string, NSStringFromRange(self.range)];
    
    return description;
}
@end
