//
//  QCCOpenRecentCellView.h
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCOpenRecentCellView : NSTableCellView

@property (nullable, nonatomic, weak) IBOutlet    NSTextField     *projectTitleTextField;
@property (nullable, nonatomic, weak) IBOutlet    NSTextField     *projectPathTextField;
@property (nullable, nonatomic, strong) NSURL   * projectURL;

@end
