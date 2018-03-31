//
//  QCCodeStorage.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCThemaManager;

typedef enum : NSUInteger {
    QCCodeStorageSignatureForOpenBrackets,
    QCCodeStorageSignatureForClosedBrackets,
    QCCodeStorageSignatureForBracketPairs,

} QCCodeStorageSignature;

typedef enum :NSUInteger {
    QCCLineMarkerTypeNULL       = 0,
    QCCLineMarkerTypeIgnored    = 1 << 0,
    QCCLineMarkerTypeNote       = 1 << 1,
    QCCLineMarkerTypeWarning    = 1 << 2,
    QCCLineMarkerTypeError      = 1 << 3,
    QCCLineMarkerTypeFatal      = 1 << 4
    
} QCCLineMarkerType;

typedef NSUInteger QCCLineMarkerMask;

extern NSString *const QCCLineMarkerTypeKey;
extern NSString *const QCCLineMarkerMessageKey;

@interface QCCodeStorage : NSTextStorage

// Attribute Name
extern NSString *const QCCFoldedAttributeName;

@property (nonatomic, strong) NSMutableAttributedString * attributedString;
@property (readwrite, assign, nonatomic) BOOL lineFoldingEnabled;
@property (nonatomic, readonly) NSDictionary    *markerDictionary;


- (id)initWithString:(NSString *)string bracketMachineClass:(Class) machineClass andThemaManager:(QCCThemaManager *) themaManager;

- (NSSize) defaultCharSize;
- (NSDictionary *) defaultCodeSyntaxAttributes;
// Get indexes for special char
- (NSArray *) signatureForType:(QCCodeStorageSignature) type;

// Unfolding
- (void) unfoldAtCharIndex:(NSUInteger) charIndex;
- (void) foldInRange:(NSRange)range;

// Set Temporary Attributes for all related layoutmanagers
- (void)setTemporaryAttributes:(NSDictionary *)attrs forCharacterRange:(NSRange)charRange;

- (BOOL) addMarkerOnLineWithType:(QCCLineMarkerType) type message:(NSString *) message forCharacterRange:(NSRange) range;
- (BOOL) removeAllMarkers;
- (NSArray *) markerSortedKeys;
- (NSArray *) markersForType: (QCCLineMarkerType) type;
@end
