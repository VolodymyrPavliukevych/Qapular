//
//  QCCMutableCollection.h
//  QCCDeploymentConfigurationKit
//
//  Created by Qapular team on 2014.
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QCCMutableCollectionDelegate <NSObject>

-(void) addedObject;
-(void) removedObject;

@end

@interface QCCMutableCollection : NSObject
@property (nonatomic, weak) id <QCCMutableCollectionDelegate> delegate;

- (NSUInteger)count;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(id)anObject;
- (void)removeLastObject;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)removeObject:(id)object;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained []) buffer count:(NSUInteger)len;


@end
