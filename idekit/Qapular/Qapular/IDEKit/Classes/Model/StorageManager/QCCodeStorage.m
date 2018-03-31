//
//  QCCodeStorage.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeStorage.h"
#import "QCCThemaManager.h"
#import "QCCodeLayoutManager.h"
#import "QCCBracketMachine.h"
#import "QCCIndentationController.h"
#import "QCCFoldedTextAttachmentCell.h"

enum {
    
    QCCFoldingNeighbourNotFound     = 0,
    QCCFoldingNeighbourLeft         = 1 << 0,
    QCCFoldingNeighbourRight        = 1 << 1
};

typedef NSUInteger QCCFoldingNeighbourMask;


NSString *const QCCLineMarkerTypeKey = @"QCCLineMarkerType";
NSString *const QCCLineMarkerMessageKey = @"QCCLineMarkerMessage";

@interface QCCodeStorage () {

    QCCThemaManager         *_themaManager;
    NSMutableDictionary     *_defaultCodeSyntaxAttributes;
    QCCBracketMachine       *_bracketMachine;
    
    NSSize                  _defaultCharSize;

    NSMutableDictionary     *_markerMutableDictionary;

}

@end

@implementation QCCodeStorage


NSString *const QCCFoldedAttributeName = @"QCCodeStorageFoldedAttributeName";

static NSString *const DefaultCharForSizeMeasuring  = @"8";

- (id)init {
    self = [super init];
    if (self) {
        _attributedString = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (id)initWithString:(NSString *)string bracketMachineClass:(Class) machineClass andThemaManager:(QCCThemaManager *) themaManager { 

    self = [super init];
    if (self) {
        _themaManager = themaManager;
        _defaultCharSize = NSZeroSize;
        _markerMutableDictionary = [NSMutableDictionary new];

        if ([machineClass isSubclassOfClass:[QCCBracketMachine class]])
            _bracketMachine = [[machineClass alloc] initWithStorage:self];
        
        _attributedString = [[NSMutableAttributedString alloc]
                             initWithString:string
                             attributes:self.defaultCodeSyntaxAttributes];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_bracketMachine updateIndexesForRange:NSMakeRange(0, string.length) withString:string];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themaReplaced)
                                                     name:QCCThemaManagerReplacedNotification
                                                   object:nil];
    }
    
    return self;
    
}

- (void) themaReplaced {
    _defaultCodeSyntaxAttributes = nil;
    [self setAttributes:[self defaultCodeSyntaxAttributes] range:NSMakeRange(0, _attributedString.length)];
    for (NSLayoutManager *manager in [self layoutManagers]) {
        if ([manager isKindOfClass:[QCCodeLayoutManager class]]) {
            QCCodeLayoutManager *codeLayoutManager = (QCCodeLayoutManager *) manager;
            [codeLayoutManager invalidatedLineSignatures];
        }
    }
    _defaultCharSize = NSZeroSize;

}

#pragma mark - Working with attributes
- (NSDictionary *) defaultCodeSyntaxAttributes {

    if (_defaultCodeSyntaxAttributes)
        return _defaultCodeSyntaxAttributes;
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.plain"]];

    _defaultCodeSyntaxAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{NSFontAttributeName:syntaxFontAttribute,
                                                                                     NSForegroundColorAttributeName:syntaxColorAttribute}];
    return _defaultCodeSyntaxAttributes;
}


- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    NSDictionary *attributes = [_attributedString attributesAtIndex:location effectiveRange:range];
    
    if ([self lineFoldingEnabled]) {
        
        id value;
        NSRange effectiveRange;
        
        value = [attributes objectForKey:QCCFoldedAttributeName];
        if (value && [value boolValue]) {
            [_attributedString attribute:QCCFoldedAttributeName
                                 atIndex:location
                   longestEffectiveRange:&effectiveRange
                                 inRange:NSMakeRange(0, [_attributedString length])];
            if (location == effectiveRange.location) {
                NSMutableDictionary *dict = [attributes mutableCopy];
                
                static NSTextAttachment *attachment;
                static QCCFoldedTextAttachmentCell *cell;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    
                    attachment = [[NSTextAttachment alloc] init];
                    cell = [[QCCFoldedTextAttachmentCell alloc] initTextCell:@"AttachmentCell"];
                    
                    [attachment setAttachmentCell:cell];
                });
                
                [dict setObject:attachment forKey:NSAttachmentAttributeName];
                
                
                attributes = dict;
                
                
                effectiveRange.length = 1;
            } else {
                ++(effectiveRange.location);
                --(effectiveRange.length);
            }
            
            if (range)
                *range = effectiveRange;
        }
    }
    
    return attributes;
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self beginEditing];
    [_attributedString setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

-(void)setTemporaryAttributes:(NSDictionary *)attrs forCharacterRange:(NSRange)charRange {
    if (attrs)
        for (NSLayoutManager *layoutManager in [self layoutManagers]) {
            [layoutManager setTemporaryAttributes:attrs forCharacterRange:charRange];
        }
}

#pragma mark - Markers
- (BOOL) addMarkerOnLineWithType:(QCCLineMarkerType) type message:(NSString *) message forCharacterRange:(NSRange) range {

    NSValue *key = [NSValue valueWithRange:range];
    

    NSMutableDictionary *container = _markerMutableDictionary[key];
    NSNumber *number;
    if (!container) {
        container = [NSMutableDictionary new];
        number = [NSNumber numberWithUnsignedInteger:type];
    }else {
        number = container[QCCLineMarkerTypeKey];
        QCCLineMarkerMask mask = [number unsignedIntegerValue];
        mask |= type;
        number = [NSNumber numberWithUnsignedInteger:mask];
    }
    
    container[QCCLineMarkerTypeKey] = number;
    container[QCCLineMarkerMessageKey] = message;
    
    _markerMutableDictionary[key] = container;
    
    return YES;
}


- (BOOL) removeAllMarkers {
    [_markerMutableDictionary removeAllObjects];
    return YES;
}

- (BOOL) removeMarkerOnLineWithType:(QCCLineMarkerType) type forCharacterRange:(NSRange) range {
    NSValue *key = [NSValue valueWithRange:range];
    
    NSNumber *number = _markerMutableDictionary[key];
    if (!number)
        return NO;
    
    QCCLineMarkerMask mask = [number unsignedIntegerValue];
    mask &= ~ type;
    if (mask == 0) {
        _markerMutableDictionary[key] = nil;
    } else {
        number = [NSNumber numberWithUnsignedInteger:mask];
        _markerMutableDictionary[key] = number;
    }
    
    return YES;
}

-(NSDictionary *) markerDictionary {
    return _markerMutableDictionary;
}


- (NSArray *) markerSortedKeys {
    return [[_markerMutableDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSValue *firstValue, NSValue *secondValue) {
        
        NSRange firstRange = [firstValue rangeValue];
        NSRange secondRange = [secondValue rangeValue];
        
        if(firstRange.location == secondRange.location) return NSOrderedSame;
        if(firstRange.location < secondRange.location) return NSOrderedAscending;
        if(firstRange.location > secondRange.location) return NSOrderedDescending;
        assert(!"Impossible");
    }];
}

- (NSArray *) markersForType: (QCCLineMarkerType) type {

    NSMutableArray *array = [NSMutableArray new];
    
    for (NSValue *key in [self markerSortedKeys]) {
    
        NSDictionary *container = _markerMutableDictionary[key];
        NSNumber *number = container[QCCLineMarkerTypeKey];
        NSString *message = container[QCCLineMarkerMessageKey];
        QCCLineMarkerMask mask = [number unsignedIntegerValue];
        if (mask & type)
            [array addObject:@{key: message}];
    }
    
    return array;
}


#pragma mark - Working with model
- (void)replaceCharactersInRange:(NSRange) rangeValue withString:(NSString *)strValue {

    NSRange range = rangeValue;
    NSString *str = strValue;

    /*
    NSString *indentString = [QCCIndentationController indent:str
                                                inTextStorage:self
                                                    withRange:range
                                             forLayoutManager:[[self layoutManagers] firstObject]];
        
    if (indentString) {
        NSLog(@"string: %@ %@", indentString, NSStringFromRange(range));
        str = indentString;
        //range = NSMakeRange(rangeValue.location, indentString.length);
    }
    */
    
    QCCFoldingNeighbourMask mask = [self foldingNeighbourAtCharIndex:range.location inserting:YES];
    
    if (mask & QCCFoldingNeighbourRight)
        [self unfoldAtCharIndex:range.location];
    if (mask & QCCFoldingNeighbourLeft)
        [self unfoldAtCharIndex:range.location - 1];

    [self beginEditing];
    [_bracketMachine updateIndexesForRange:range withString:str];
    [_attributedString replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedAttributes | NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
    [self endEditing];
}

#pragma  mark - Folding featuring
- (QCCFoldingNeighbourMask) foldingNeighbourAtCharIndex:(NSUInteger) charIndex inserting:(BOOL) inserting{
    QCCFoldingNeighbourMask mask = QCCFoldingNeighbourNotFound;
    
    if (charIndex > 1) {
        NSUInteger leftIndex = charIndex - 1;
        NSDictionary *attributes = [self attributesAtIndex:leftIndex effectiveRange:NULL];
        if (attributes[QCCFoldedAttributeName] && [attributes[QCCFoldedAttributeName] boolValue])
            mask |= QCCFoldingNeighbourLeft;
        
    }
    
    if (self.string.length > charIndex) {
        NSUInteger rightIndex = charIndex + (inserting ? 0 : 1);

        NSDictionary *attributes = [self attributesAtIndex:rightIndex effectiveRange:NULL];
        if (attributes[QCCFoldedAttributeName] && [attributes[QCCFoldedAttributeName] boolValue])
                        mask |= QCCFoldingNeighbourRight;
    }

    return mask;

}

#pragma mark - Folding

- (void) foldInRange:(NSRange)range {

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self defaultCodeSyntaxAttributes]];
    [attributes setObject:@(YES) forKey:QCCFoldedAttributeName];

    [self setAttributes:attributes range:range];

    // Invalidated LineSignatures
    [self updateRelatedLineSignatures];
    
    [self updateBracketsFromRange:range];
    
}


- (void) unfoldAtCharIndex:(NSUInteger) charIndex {

    [self beginEditing];
    
    NSRange effectiveRange;
    
    [_attributedString attribute:QCCFoldedAttributeName
                         atIndex:charIndex
           longestEffectiveRange:&effectiveRange
                         inRange:NSMakeRange(0, self.string.length)];
    
    [self removeAttribute:QCCFoldedAttributeName range:effectiveRange];
    [self endEditing];

    // Invalidated LineSignatures
    [self updateRelatedLineSignatures];

    [self updateBracketsFromRange:effectiveRange];

}

#pragma mark - Update relates
- (void) updateRelatedLineSignatures {
    for (NSLayoutManager *layoutManager in [self layoutManagers]) {
        if ([layoutManager isKindOfClass:[QCCodeLayoutManager class]]){
            QCCodeLayoutManager * codeLayoutManager = (QCCodeLayoutManager *) layoutManager;
            [codeLayoutManager invalidatedLineSignatures];
        }
    }
}


- (void) updateBracketsFromRange:(NSRange) range {
    NSRange effectedRange = NSMakeRange(range.location, self.string.length - range.location);
    [_bracketMachine updateIndexesForRange:effectedRange withString:[self.string substringFromIndex:effectedRange.location]];
}

/*
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange {
    NSRange foldRange = [self foldRangeForRange:range];
    
    if (foldRange.location == NSNotFound)
        return NO;
    
    [self removeAttribute:LineFoldingAttributeName range:foldRange];
    //    [self removeAttribute:NSCursorAttributeName range:foldRange];
    
    if (effectiveRange)
        *effectiveRange = foldRange;
    
    return YES;
}

- (NSRange)foldRangeForRange:(NSRange)range; {
    NSRange effectiveRange;
    id attribute = [self attribute:LineFoldingAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, self.length)];
    
    if ([attribute boolValue])
        return effectiveRange;
    
    
    NSRange notFound;
    notFound.location = NSNotFound;
    
    return notFound;
}


*/

#pragma mark - Signatures
- (NSArray *) signatureForType:(QCCodeStorageSignature) type {

    switch (type) {
        case QCCodeStorageSignatureForOpenBrackets:
            return [_bracketMachine openBrackets];
            break;
            
        case QCCodeStorageSignatureForClosedBrackets:
            return [_bracketMachine closedBrackets];
            break;
            
            case QCCodeStorageSignatureForBracketPairs:
            return [_bracketMachine bracketPairs];
            
    }
}

#pragma mark - Helpers
- (void)fixAttachmentAttributeInRange:(NSRange)range {
    NSRange effectiveRange;
    id value;
    //NSLog(@"fixAttachmentAttributeInRange: %@", NSStringFromRange(range));
    while (range.length) {
        if ((value = [self attribute:NSAttachmentAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
            for (NSUInteger charIndex=effectiveRange.location; charIndex<NSMaxRange(effectiveRange); charIndex++) {
                if ([self.string characterAtIndex:charIndex] != NSAttachmentCharacter) {
                    NSLog(@"remove NSAttachmentAttributeName range:%@", NSStringFromRange(NSMakeRange(charIndex, 1)));
                    [self removeAttribute:NSAttachmentAttributeName range:NSMakeRange(charIndex, 1)];
                    
                }
                
            }
        }
        
        range = NSMakeRange(NSMaxRange(effectiveRange), NSMaxRange(range) - NSMaxRange(effectiveRange));
    }
}

- (NSSize) defaultCharSize {

    if (NSEqualSizes(NSZeroSize, _defaultCharSize)) {
        _defaultCharSize = [DefaultCharForSizeMeasuring sizeWithAttributes:[self defaultCodeSyntaxAttributes]];
    }
    
    return _defaultCharSize;
}

- (NSString *)string; {
    return [_attributedString string];
}

-(NSString *) description {
    return [[NSString stringWithFormat:@"<CodeStorage: %p>\n\n", self] stringByAppendingString:[super description]];
}

@end


