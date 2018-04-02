//
//  ORSSerialPort+Hardware.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavlyukevich on 5/24/16.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "ORSSerialPort+Hardware.h"
#import <IOKit/serial/IOSerialKeys.h>

@implementation ORSSerialPort (Hardware)
/*
 printf("Found matching USB bus:address %03d:%03d\n", bus, address);
 printf("Found matching USB VID:PID %04X:%04X\n", vid, pid);
 */

- (NSString *) readBSDName {
    return [self readStringValueForKey:@kIOCalloutDeviceKey];
}

- (NSString *) readTTYDevice {
    return [self readStringValueForKey:@kIOTTYDeviceKey];
}

- (NSString *) readUSBInterfaceName {
    return [self readStringValueForKey:@"USB Interface Name"];
}

- (NSString *) readUSBProductName {
    return [self readStringValueForKey:@"USB Product Name"];
}

- (NSString *) readProductName {
    return [self readStringValueForKey:@"Product Name"];
}

- (NSNumber *) readUSBBusNumber {
    return [self readNumberValueForKey:@"USBBusNumber"];
}

- (NSNumber *) readUSBAddress {
    return [self readNumberValueForKey:@"USB Address"];
}

- (NSNumber *) readIDVendor {
    return [self readNumberValueForKey:@"idVendor"];
}

- (NSNumber *) readIDProduct {
    return [self readNumberValueForKey:@"idProduct"];
}

- (NSString *) readUSBVendorName {
    return [self readStringValueForKey:@"USB Vendor Name"];
}

- (NSString *) readUSBSerialNumber {
    return [self readStringValueForKey:@"USB Serial Number"];
}


- (NSString *) readStringValueForKey:(NSString *) key {
    CFTypeRef value = [self searchValueForKey:key];
    NSString *string =  [self readCFString:value size:512];
    if (value)
        CFRelease(value);
    
    return string;
}

- (NSNumber *) readNumberValueForKey:(NSString *) key {
    CFTypeRef value = [self searchValueForKey:key];
    
    
    if (!value)
        return nil;

    int intValue;
    bool result = CFNumberGetValue(value , kCFNumberIntType, &intValue);
    
    if (value)
        CFRelease(value);
    
    if (!result)
        return nil;
    
    return @(intValue);
}

- (CFTypeRef) searchValueForKey:(NSString *) key {
    if (!key)
        return nil;
    CFStringRef keyRef = (__bridge CFStringRef)(key);
    return [self searchValueInEntry:self.IOKitDevice forKeyRef:keyRef];
}

- (CFTypeRef) searchValueInEntry:(io_object_t) entry forKeyRef:(CFStringRef) key {

    CFTypeRef cf_property = IORegistryEntrySearchCFProperty(entry,
                                                            kIOServicePlane,
                                                            key,
                                                            kCFAllocatorDefault,
                                                            kIORegistryIterateRecursively | kIORegistryIterateParents);
    return cf_property;
}

- (NSString *) readCFString:(CFStringRef) stringRef size:(size_t) size {
    
    char  * cString = calloc(size, sizeof(char));
    
    if (!stringRef)
        return nil;
    
    Boolean string_is_ready = CFStringGetCString(stringRef, cString, sizeof(char) * size, kCFStringEncodingASCII);
    
    if (string_is_ready) {
        return [NSString stringWithCString:cString encoding:NSASCIIStringEncoding];
    }
    
    return nil;
}



@end
