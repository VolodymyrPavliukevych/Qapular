//
//  QCCFormater.h
//  QCCodeFormatKit
//
//  Created by Volodymyr Pavliukevych 2014.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    
    CodeStyleNone,
    
    /// http://llvm.org/docs/CodingStandards.html
    CodeStyleLLVM,
    
    /// https://github.com/google/styleguide
    CodeStyleGoogle,
    
    /// http://www.chromium.org/developers/coding-style
    CodeStyleChromium,
    
    /// https://developer.mozilla.org/en-US/docs/Developer_Guide/Coding_Style
    CodeStyleMozilla,
    
    /// http://www.webkit.org/coding/coding-style.html
    CodeStyleWebKit,
    
    /// http://www.gnu.org/prep/standards/standards.html
    CodeStyleGNU
    
} CodeStyle;

@interface QCCFormater : NSObject

// CodeStyleGoogle by default
+ (NSString *) formatCodeString:(NSString *) codeNSString;

+ (NSString *) formatCodeString:(NSString *) codeNSString withStyleFormat:(CodeStyle) style;

@end
