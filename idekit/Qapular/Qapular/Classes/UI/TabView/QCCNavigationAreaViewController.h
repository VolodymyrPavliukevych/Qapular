//
//  QCCLeftSideTabViewController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTabView.h"
#import "QCCThemaManager.h"

@interface QCCNavigationAreaViewController : QCCTabView

@property (nonatomic, weak) id <QCCThemaManagerDataSource> themaManagerDataSource;

@end
