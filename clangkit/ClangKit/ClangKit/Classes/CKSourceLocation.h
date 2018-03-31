//
//  CKSourceLocation.h
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class           CKSourceLocation
 * @abstract        Source location class
 */

@interface CKSourceLocation : NSObject

/*!
 * @property        fileName
 * @abstract        The source location's filename
 */
@property(atomic, readonly) NSString * fileName;

@property(atomic, readonly) unsigned int line;
@property(atomic, readonly) unsigned int column;
@property(atomic, readonly) unsigned int offset;

- (id)initWithCXSourceLocationValue:(NSValue *) locationValue;

- (NSValue *) cxLocationValue;

@end
