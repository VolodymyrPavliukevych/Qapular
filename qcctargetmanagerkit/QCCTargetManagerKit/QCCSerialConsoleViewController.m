//
//  QCCSerialConsoleViewController.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavlyukevich on 5/22/16.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "QCCSerialConsoleViewController.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialPort.h"
#import "QCCPortManager.h"

@interface QCCSerialConsoleViewController () <ORSSerialPortDelegate>

@property (nonatomic, weak) IBOutlet    NSPopUpButton           *serialPortPopUpButton;
@property (nonatomic, weak) IBOutlet    NSPopUpButton           *serialPortBaudRatePopUpButton;
@property (nonatomic, weak) IBOutlet    NSButton                *openPortButton;
@property (nonatomic, weak) IBOutlet    NSButton                *sendDataButton;
@property (nonatomic, weak) IBOutlet    NSTextField             *outputTextField;
@property (nonatomic, weak) IBOutlet    NSButton                *autoscrollCheckField;

@property (nonatomic, strong) IBOutlet  NSTextView              *inputTextView;

@property (nonatomic, weak) IBOutlet    ORSSerialPort           *selectedSerialPort;

@end

@implementation QCCSerialConsoleViewController

+(nullable instancetype) consoleWithPortManager:(nonnull QCCPortManager *) portManager {
    if (!portManager)
        return nil;
    
    QCCSerialConsoleViewController *viewController = [[QCCSerialConsoleViewController alloc] initWithPortManager:portManager];
    return viewController;
    
}

-(instancetype)initWithPortManager:(nonnull QCCPortManager *) portManager {
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[QCCSerialConsoleViewController class]];
    self = [super initWithNibName:NSStringFromClass([QCCSerialConsoleViewController class]) bundle:frameworkBundle];
    if (self) {
        _portManager = portManager;
    }
    
    return self;
}
-(void)dealloc {
    [self setSelectedSerialPort:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction) openOrClosePort:(id) sender {
    _selectedSerialPort.isOpen ? [_selectedSerialPort close] : [_selectedSerialPort open];
}

- (IBAction) sendStringAction:(id) sender {
    NSString *string = self.outputTextField.stringValue;
    string = [string stringByAppendingString:[self.portManager.lineEndingStrings firstObject]];

    NSData *dataToSend = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.selectedSerialPort sendData:dataToSend];
}

#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort {
   self.openPortButton.title = @"Close";
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort {
    self.openPortButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([string length] == 0) return;
    [self.inputTextView.textStorage.mutableString appendString:string];
    [self.inputTextView setNeedsDisplay:YES];
    
    if (self.autoscrollCheckField.state == NSOnState)
        [self.inputTextView scrollRangeToVisible: NSMakeRange(self.inputTextView.string.length, 0)];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort; {
    self.openPortButton.stringValue = @"Open";
    self.selectedSerialPort = nil;
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error {
    NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

-(void)setSelectedSerialPort:(ORSSerialPort *)selectedSerialPort {
    if (_selectedSerialPort == selectedSerialPort)
        return;
    
    [_selectedSerialPort close];
    [_selectedSerialPort setDelegate:nil];
    _selectedSerialPort = selectedSerialPort;
    [_selectedSerialPort setDelegate:self];
}


@end
