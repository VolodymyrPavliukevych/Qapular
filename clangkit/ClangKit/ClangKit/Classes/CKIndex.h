//
//  CKIndex.h
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

/*!
 * @class           CKIndex
 * @abstract        Index class
 */


@interface CKIndex : NSObject {

@protected
    
    CXIndex _cxIndex;
    BOOL    _excludeDeclarationsFromPCH;
    BOOL    _displayDiagnostics;
}

/*!
 * @property        cxIndex
 * @abstract        Internal libclang index object
 */
@property(atomic, readonly) CXIndex cxIndex;

/*!
 * @property        excludeDeclarationsFromPCH
 * @abstract        Whether to exclude declarations from the PCH file or not
 */
@property(atomic, readwrite) BOOL excludeDeclarationsFromPCH;

/*!
 * @property        displayDiagnostics
 * @abstract        Whether to display diagnostics or not
 */
@property(atomic, readwrite) BOOL displayDiagnostics;

/*!
 * @method          index
 * @abstract        Gets an index object
 * @return          The index object
 * @discussion      The returned object.
 */


@end
