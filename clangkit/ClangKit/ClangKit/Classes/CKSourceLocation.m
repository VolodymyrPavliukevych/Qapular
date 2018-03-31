//
//  CKSourceLocation.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "CKSourceLocation.h"
@interface CKSourceLocation() {

    CXSourceLocation _cxLocation;
}

@end

@implementation CKSourceLocation

- (id)initWithCXSourceLocationValue:(NSValue *) locationValue {

    CXSourceLocation location;
    [locationValue getValue:&location];
    
    CXFile          file;
    CXString        fileName;

    
    _cxLocation = location;
    self = [self init];
    if(self) {
        clang_getExpansionLocation(location, &file, &_line, &_column, &_offset);
        
        fileName = clang_getFileName(file);
        
        const char * fileNameCString = clang_getCString(fileName);
        
        if(fileNameCString != NULL) {
            _fileName = [[NSString alloc] initWithCString:fileNameCString encoding:NSUTF8StringEncoding];
            clang_disposeString(fileName);
        }
    }
    
    return self;
}

- (NSValue *) cxLocationValue {
    NSValue *value = [NSValue value:&_cxLocation withObjCType:@encode(CXSourceLocation)];
    return value;
}

- (NSString *) description {

    NSString * description;
    
    description = [super description];
    description = [description stringByAppendingFormat:@"[line:%i column:%i, offset:%i ]\n", _line, _column, _offset];

    return description;
}

@end
