//
//  ORSSerialPort+Hardware.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavlyukevich on 5/24/16.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <QCCTargetManagerKit/QCCTargetManagerKit.h>
#import "ORSSerialPort.h"
@interface ORSSerialPort (Hardware)

- (NSString *) readBSDName;
- (NSString *) readTTYDevice;
- (NSString *) readUSBInterfaceName;
- (NSString *) readUSBProductName;
- (NSString *) readProductName;
- (NSNumber *) readUSBBusNumber;
- (NSNumber *) readUSBAddress;
- (NSNumber *) readIDVendor;
- (NSNumber *) readIDProduct;
- (NSString *) readUSBVendorName;
- (NSString *) readUSBSerialNumber;

@end
