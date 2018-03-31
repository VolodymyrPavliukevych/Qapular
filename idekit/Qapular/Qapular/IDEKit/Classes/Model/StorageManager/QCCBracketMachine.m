//
//  QCCBracketMachine.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBracketMachine.h"
#import "QCCodeStorage.h"

@interface QCCBracketMachine() {
    QCCodeStorage *_codeStorage;
    
    NSMutableArray  *_openBracketsArray;
    NSMutableArray  *_closedBracketsArray;
    BOOL            _inProgress;
}

@end

@implementation QCCBracketMachine

static const unichar OpenBracketChar = '{';
static const unichar ClosedBracketChar = '}';

NSString *const QCCBracketMachineUpdatedNotification = @"QCCBracketMachineUpdatedNotificationKey";

- (instancetype) initWithStorage:(QCCodeStorage *) codeStorage {

    self = [super init];
    if (self) {
        _codeStorage = codeStorage;
        _openBracketsArray = [NSMutableArray new];
        _closedBracketsArray = [NSMutableArray new];
        
    }
    return self;
}

- (void) updateIndexesForRange:(NSRange)range withString:(NSString *) newStrings {
    BOOL hasUpdate = NO;
    
    // Clear all;
    if (range.length == _codeStorage.string.length  && range.location == 0) {
        [_openBracketsArray removeAllObjects];
        [_closedBracketsArray removeAllObjects];
        hasUpdate = YES;
    }

    // Remove indexes from removed range;
    if (range.length > 0) {
        [self removeIndexesForRange:range];
        hasUpdate = YES;
    }
    
    // Increment old indexes with shift;
    NSUInteger shift = newStrings.length - range.length;
    if (shift != 0) {
        [self updateIndexesWithShift:shift fromLocation:range.location hasUpdate:&hasUpdate];
    }
    
    // Add new indexes from string;
    [self iterating:newStrings fromRange:range hasUpdate:&hasUpdate];

    if (hasUpdate)
        [[NSNotificationCenter defaultCenter] postNotificationName:QCCBracketMachineUpdatedNotification object:_codeStorage];

}

- (void) removeIndexesForRange:(NSRange) range {

    NSUInteger index = range.location;
    
    for (;index != NSMaxRange(range); index ++) {
        [_closedBracketsArray removeObject:[NSNumber numberWithInteger:index]];
        [_openBracketsArray removeObject:[NSNumber numberWithInteger:index]];
    }
}

- (void) iterating:(NSString *) string fromRange:(NSRange)range hasUpdate:(BOOL *) hasUpdate {
    
    unsigned long length = string.length;
    unichar buffer[length];
    
    [string getCharacters:buffer range:NSMakeRange(0, length)];
    
    for(int i = 0; i < length; ++i) {
        char current = buffer[i];
        
        if (current == OpenBracketChar) {
            NSUInteger insertedIndex = range.location + i;
            [_openBracketsArray addObject:@(insertedIndex)];
            *hasUpdate = YES;
        }
        
        if (current == ClosedBracketChar) {
            NSUInteger insertedIndex = range.location + i;
            [_closedBracketsArray addObject:@(insertedIndex)];
            *hasUpdate = YES;
        }
    }
}

- (void) updateIndexesWithShift:(NSUInteger) shift fromLocation:(NSUInteger) location hasUpdate:(BOOL *) hasUpdate{
    [_closedBracketsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *index = (NSNumber *) obj;
        if ([index intValue] >= location){
            [_closedBracketsArray replaceObjectAtIndex:idx withObject:[NSNumber numberWithInteger:[index integerValue] + shift]];
            *hasUpdate = YES;
        }
    }];
    
    [_openBracketsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *index = (NSNumber *) obj;
        if ([index intValue] >= location){
            [_openBracketsArray replaceObjectAtIndex:idx withObject:[NSNumber numberWithInteger:[index integerValue] + shift]];
            *hasUpdate = YES;
        }
    }];
}


- (NSArray *) closedBrackets {

    return [_closedBracketsArray sortedArrayUsingSelector:@selector(compare:)];
}


- (NSArray *) openBrackets {

    return [_openBracketsArray sortedArrayUsingSelector:@selector(compare:)];
}


- (NSArray *) bracketPairs {

    NSMutableArray *pairs = [NSMutableArray new];
    
    NSMutableArray *openBrackets = [[NSMutableArray alloc] initWithArray:self.openBrackets];
    NSMutableArray *closedBrackets = [[NSMutableArray alloc] initWithArray:self.closedBrackets];
    
    if (([openBrackets count] == 0) || ([closedBrackets count] == 0))
        return nil;
    
    for (NSNumber *closedBracket in closedBrackets) {
        
        NSUInteger openBracketIndex = 0;
        BOOL found = NO;
        for (NSNumber *openBracket in openBrackets) {
            
            if ([openBracket integerValue] < [closedBracket integerValue]) {
                openBracketIndex = [openBrackets indexOfObject:openBracket];
                found = YES;
            }else {
                break;
            }
        }
        
        if (([openBrackets count] > 0) && ([closedBrackets count] > 0) && found) {
            NSDictionary *pair = @{@(QCCodeStorageSignatureForOpenBrackets): [openBrackets objectAtIndex:openBracketIndex],
                                   @(QCCodeStorageSignatureForClosedBrackets): closedBracket};
            [pairs addObject:pair];
            
            [openBrackets removeObjectAtIndex:openBracketIndex];
        }
        
    }
    
    return pairs;
}



@end
