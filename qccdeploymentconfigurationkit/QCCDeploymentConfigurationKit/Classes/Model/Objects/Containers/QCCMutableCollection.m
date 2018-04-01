//
//  QCCMutableCollection.m
//  QCCDeploymentConfigurationKit
//
//  Created by Qapular team on 2014.
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCMutableCollection.h"
@interface QCCMutableCollection() {
     NSMutableArray *_innerArray;
}
@end

@implementation QCCMutableCollection

-(instancetype)init {
    self = [super init];
    if (self) {
        _innerArray = [NSMutableArray new];
    }
    return self;

}

- (NSUInteger)count {
    return [_innerArray count];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [_innerArray insertObject:anObject atIndex:index];
    [_delegate addedObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_innerArray removeObjectAtIndex:index];
    [_delegate removedObject];
}

- (void)addObject:(id)anObject {
    [_innerArray addObject:anObject];
    [_delegate addedObject];
}

- (void)removeLastObject {
    [_innerArray removeLastObject];
    [_delegate removedObject];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    [_innerArray insertObjects:objects atIndexes:indexes];
    [_delegate addedObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_innerArray replaceObjectAtIndex:index withObject:anObject];
    [_delegate addedObject];
}

- (void)removeObject:(id)object {
    [_innerArray removeObject:object];
    [_delegate removedObject];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained []) buffer count:(NSUInteger)len {
    return [_innerArray countByEnumeratingWithState:state objects:buffer count:len];
}


@end
