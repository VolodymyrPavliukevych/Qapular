//
//  QCCBaseToolView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class QCCThemaManager;

@interface QCCBaseToolView : NSView {
    
    QCCThemaManager *_themaManager;
    
    NSColor         *_backgroundColor;
    NSColor         *_gradientColor;
    
    NSColor         *_darkLineColor;
    NSColor         *_lightLineColor;
    
}

- (void) setThemaManager:(QCCThemaManager *) themaManager;
- (void) prepareAppearence;
- (void) updateColors;

@end
