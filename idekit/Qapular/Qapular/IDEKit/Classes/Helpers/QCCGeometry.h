//
//  QCCGeometry.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSRect truncNSRect(NSRect rect);

/// Round to largest integral value less than or equal to x
extern CGFloat floorCGFloat(CGFloat x);

/// Round to closest integral value to x
extern CGFloat roundCGFloat(CGFloat x);

/// Round to the nearest integer towards zero to x.
extern CGFloat truncCGFloat(CGFloat x);

/// Returns the floating-point remainder of numer/denom
extern CGFloat modCGFloat(CGFloat numer, CGFloat denom);
