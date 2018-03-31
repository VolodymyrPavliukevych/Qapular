//
//  QCCWindowButton.h
//  UISamples
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct {

    float red;
    float green;
    float blue;
    float alpha;

} QCCStructColor;


typedef struct {
    
    QCCStructColor  backgroundColor;
    QCCStructColor  strokeColor;
    
} QCCButtonColor;

@interface QCCWindowButton : NSButton

- (void) setWindowButtonType:(NSWindowButton) type;

@end
