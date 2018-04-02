//
//  QCCDecompressor.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCCDecompressor : NSObject

+(BOOL) decompressFileAtURL:(NSURL *) url destinationURL:(NSURL *) destination;

@end
