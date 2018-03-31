//
//  QCCodeLayoutManager.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCLineSignature : NSObject

extern NSString *const QCCLineSignatureUpdatedNotification;

/* Rect of line */
@property (nonatomic) NSRect        rect;

/* Range of chars in that line */
@property (nonatomic) NSRange       containsCharRange;

/* if last symbol is  '\n' (0xA char) hasSoftBreak returns YES */
@property (nonatomic) BOOL          hasSoftBreak;

/* Count of chars in line */
@property (nonatomic) NSUInteger    countOfChars;

/* Array with NSNumber includes with brackets index */
@property (nonatomic, strong) NSMutableArray    *openedBrackets;

/* Array with NSNumber includes with brackets index */
@property (nonatomic, strong) NSMutableArray    *closedBrackets;

@end


@interface QCCodeLayoutManager : NSLayoutManager

@property (nonatomic, strong, readonly) NSArray   *lineSignatureArray;

- (void) invalidatedLineSignatures;

@end
