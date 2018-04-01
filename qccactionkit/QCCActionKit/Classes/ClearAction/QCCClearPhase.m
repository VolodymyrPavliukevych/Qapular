//
//  QCCClearPhase.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCClearPhase.h"
#import "QCCBasePhase+Private.h"

@interface QCCClearPhase() {
}

@end

@implementation QCCClearPhase

- (instancetype) init {
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"Clearing temporary folder is in progress.", @"Clear phase description");
}

-(void) launch {
    
    NSURL *temeroryDirectoryURL = [self temeroryDirectoryURL];
    NSError *error;

    if (!temeroryDirectoryURL) {
    
        self.phaseFinishedBlock(self);
        return;
    }
    
    NSArray *contentArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:temeroryDirectoryURL
                                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:&error];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned long long idx = 0;
        for (NSString *path in contentArray) {
            if (!_action.progress.isCancelled) {
                NSError *error;
                
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                _action.progress.completedUnitCount++;
                float persent = (_action.progress.totalUnitCount / [contentArray count]);
                _action.progress.completedUnitCount = idx * persent;
                idx++;
                
                if (self.phaseProgressBlock)
                    self.phaseProgressBlock(self);
            } else
                break;
        }
        if (self.phaseFinishedBlock)
            self.phaseFinishedBlock(self);
    });
}



@end
