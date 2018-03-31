//
//  QCCTabView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCTabView : NSTabView {
    NSArray     *_tabViewButtons;
}

- (IBAction) tabButtonAction:(id)sender;

@end
