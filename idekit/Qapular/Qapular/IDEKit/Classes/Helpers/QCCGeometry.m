//
//  QCCGeometry.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCGeometry.h"

extern NSRect truncNSRect( NSRect rect) {

    NSRect newRect = NSMakeRect(truncCGFloat(rect.origin.x),
                                truncCGFloat(rect.origin.y),
                                truncCGFloat(rect.size.width),
                                truncCGFloat(rect.size.height));
    return newRect;
}

extern CGFloat roundCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return round(x);
#else
    return roundf(x);
#endif
}

extern CGFloat floorCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return floor(x);
#else
    return floorf(x);
#endif
}

extern CGFloat truncCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return trunc(x);
#else
    return truncf(x);
#endif
}

extern CGFloat modCGFloat(CGFloat numer, CGFloat denom) {
#if CGFLOAT_IS_DOUBLE
    return fmod(numer, denom);
#else
    return fmodf(numer, denom);
#endif
}
