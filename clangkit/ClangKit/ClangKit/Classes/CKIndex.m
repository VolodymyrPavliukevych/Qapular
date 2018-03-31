//
//  CKIndex.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "CKIndex.h"


@implementation CKIndex

@synthesize cxIndex = _cxIndex;


- (id)init {
    
    self = [super init];
    
    if(self) {

        _cxIndex = clang_createIndex(false, //excludeDeclsFromPCH
                                     false  //displayDiagnostics
                                     );
    }
    
    return self;
}

- (BOOL)excludeDeclarationsFromPCH {
    @synchronized(self) {
        return _excludeDeclarationsFromPCH;
    }
}

- (BOOL)displayDiagnostics {
    @synchronized(self){
        return _displayDiagnostics;
    }
}

- (void)setExcludeDeclarationsFromPCH:(BOOL)value {
    @synchronized(self) {
        if(value != _excludeDeclarationsFromPCH) {
            clang_disposeIndex(_cxIndex);
            _cxIndex = clang_createIndex((int)_excludeDeclarationsFromPCH, (int)_displayDiagnostics);
        }
    }
}

- (void)setDisplayDiagnostics: (BOOL)value {
    @synchronized(self) {
        if(value != _displayDiagnostics) {
            clang_disposeIndex(_cxIndex);
            _cxIndex = clang_createIndex((int)_excludeDeclarationsFromPCH, (int)_displayDiagnostics);
        }
    }
}


- (void)dealloc {
    clang_disposeIndex(_cxIndex);
}


@end
