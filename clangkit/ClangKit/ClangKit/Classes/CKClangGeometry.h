//
//  CKClangGeometry.h
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#ifndef ClangKit_CKClangGeometry_h
#define ClangKit_CKClangGeometry_h

NSRange NSRangeFromCXSourceRange(CXSourceRange sourceRange) {
    unsigned start, end;
    CXSourceLocation s = clang_getRangeStart(sourceRange);
    CXSourceLocation e = clang_getRangeEnd(sourceRange);
    clang_getInstantiationLocation(s, 0, 0, 0, &start);
    clang_getInstantiationLocation(e, 0, 0, 0, &end);
    if (end < start) {
        return NSMakeRange(end, start-end);
    }
    return NSMakeRange(start, end - start);
}

#endif
