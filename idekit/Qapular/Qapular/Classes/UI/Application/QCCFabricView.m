//
//  QCCFabricView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFabricView.h"

@implementation QCCFabricView

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {

    self = [super awakeAfterUsingCoder:aDecoder];
    
    if (self) {
    
        self.maxNumberOfRows = 4;
        self.maxNumberOfColumns = 4;
        
    }

    return self;
}



-(void)awakeFromNib {


}


-(NSCollectionViewItem *) itemAtIndex:(NSUInteger)index {

    NSCollectionViewItem *item = [[NSCollectionViewItem alloc] init];
    
    return item;

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
