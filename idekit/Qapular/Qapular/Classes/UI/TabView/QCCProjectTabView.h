//
//  QCCProjectTabView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCTabBarView.h"

@interface QCCProjectTabView : NSTabView <QCCTabBarViewDelegate>

@property (nonatomic, weak) IBOutlet    QCCTabBarView   *tabBarView;

@end
