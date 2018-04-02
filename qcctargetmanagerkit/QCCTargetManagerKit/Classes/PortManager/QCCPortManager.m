//
//  QCCPortManager.m
//  QCCActionKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPortManager.h"

#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"


NSString *const QCCPortBSDNameKey       =   @"QCCPortBSDName";
NSString *const QCCPortDescriptionKey   =   @"QCCPortDescription";
NSString *const QCCPortTransportKey     =   @"QCCPortTransport";
NSString *const QCCPortAddressKey       =   @"QCCPortAddress";
NSString *const QCCPortVIDKey           =   @"QCCPortVID";
NSString *const QCCPortPIDKey           =   @"QCCPortPID";
NSString *const QCCPortManufacturerKey  =   @"QCCPortManufacturer";
NSString *const QCCPortSerialKey        =   @"QCCPortSerial";


@interface QCCPortManager() {
}

@end

@implementation QCCPortManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
    
        _serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
        _availableBaudRates = @[@300, @1200, @2400, @4800, @9600, @14400, @19200, @28800, @38400, @57600, @115200, @230400];
    
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
    }
    
    return self;
}

- (NSArray *) availablePorts {
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (ORSSerialPort *port in [_serialPortManager availablePorts]) {
        NSMutableDictionary *portDictionary = [NSMutableDictionary new];
        if (port.BSDName)
            portDictionary[QCCPortBSDNameKey] = port.BSDName;
        
        if (port.IDVendor)
            portDictionary[QCCPortVIDKey] = port.IDVendor;

        if (port.IDProduct)
            portDictionary[QCCPortPIDKey] = port.IDProduct;
        
        [array addObject:portDictionary];

    }
    
    return array;
}

- (NSArray <ORSSerialPort *> *) availableSerialPorts {
    return _serialPortManager.availablePorts;
}

- (NSArray <NSString *> *) lineEndingStrings {
    
    static dispatch_once_t onceToken;
    static NSArray *lineEndingStrings;
    dispatch_once(&onceToken, ^{
        lineEndingStrings = @[@"\r", @"\n", @"\r\n"];
    });
    return lineEndingStrings;

}

#pragma mark - NSUserNotificationCenterDelegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [center removeDeliveredNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - NotificateCenter
- (void)serialPortsWereConnected:(NSNotification *)notification {
    NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
    [self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification {
    NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
    [self postUserNotificationForDisconnectedPorts:disconnectedPorts];
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts{
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    for (ORSSerialPort *port in connectedPorts) {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected.", @"Serial port connected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [userNotificationCenter deliverNotification:userNote];
    }
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts {
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in disconnectedPorts) {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected.", @"Serial port disconnected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [userNotificationCenter deliverNotification:userNote];
    }
}

- (void) consoleWithBSDName:(NSString *) BSDname pause:(BOOL) pause {

    for (ORSSerialPort *port in _serialPortManager.availablePorts) {
        if ([port.BSDName isEqualToString:BSDname]) {
        
            if (pause)
                [port close];
            else
                [port open];
        
            break;
        }
    }
}


@end
