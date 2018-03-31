//
//  QCCodeTypesetter.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeTypesetter.h"
#import "QCCodeStorage.h"

@implementation QCCodeTypesetter

- (id)init {
    self = [super init];
    
    if (self) {
        
    }
    return self;
}


- (NSTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(NSUInteger)charIndex {
    id attributeValue = [[self attributedString] attribute:QCCFoldedAttributeName atIndex:charIndex effectiveRange:NULL];
    
    if (attributeValue && [attributeValue boolValue])
        return NSTypesetterZeroAdvancementAction;
    
    return [super actionForControlCharacterAtIndex:charIndex];
}


- (NSUInteger)layoutParagraphAtPoint:(NSPointPointer)lineFragmentOrigin {

    NSUInteger result;
    QCCodeStorage *codeStorage;

    if ([self.attributedString isKindOfClass:[QCCodeStorage class]]) {
        codeStorage = (QCCodeStorage *) self.attributedString;
    }
    
    codeStorage.lineFoldingEnabled = YES;
    
    result = [super layoutParagraphAtPoint:lineFragmentOrigin];
    
    codeStorage.lineFoldingEnabled = NO;
    
    return result;
}

@end
