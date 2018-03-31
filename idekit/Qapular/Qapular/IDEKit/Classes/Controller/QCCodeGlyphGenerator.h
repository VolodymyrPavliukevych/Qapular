//
//  QCCodeGlyphGenerator.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QCCodeGlyphGenerator : NSGlyphGenerator <NSGlyphStorage> {
    id <NSGlyphStorage> _destination;
}

@end
