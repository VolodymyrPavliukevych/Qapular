//
//  QCCTargetManagerCellView.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QCCTargetManagerCellViewDelegate <NSObject>

- (void) installTargetWithIdentefier:(NSString *) identefier completion:(void (^)(NSInteger total, NSInteger installed, NSError *error)) completion;

@end


@interface QCCTargetManagerCellView : NSTableCellView
@property (nonatomic, weak) IBOutlet id<QCCTargetManagerCellViewDelegate> delegate;


@end
