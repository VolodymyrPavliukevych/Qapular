//
//  QCCPortManager.h
//  QCCActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const QCCPortBSDNameKey;
extern NSString *const QCCPortDescriptionKey;
extern NSString *const QCCPortTransportKey;
extern NSString *const QCCPortAddressKey;
extern NSString *const QCCPortVIDKey;
extern NSString *const QCCPortPIDKey;
extern NSString *const QCCPortManufacturerKey;
extern NSString *const QCCPortSerialKey;

@class ORSSerialPort;
@class ORSSerialPortManager;
@interface QCCPortManager : NSObject

@property (nonatomic, strong, readonly) NSArray *availableBaudRates;
@property (nonatomic, strong, readonly) NSArray <NSString *> * lineEndingStrings;
@property (nonatomic, strong, readonly) ORSSerialPortManager * serialPortManager;

// Return array of dictionaries
- (NSArray *) availablePorts;
- (NSArray <ORSSerialPort *> *) availableSerialPorts;


- (void) consoleWithBSDName:(NSString *) BSDname pause:(BOOL) pause;

@end
