//
//  QCCDialog.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCDialog.h"

@implementation QCCDialog

static NSString *const  QCCDialogButtonDescriptionTitleKey = @"QCCDialogButtonDescriptionTitle";
static NSString *const  QCCDialogButtonDescriptionIndexKey = @"QCCDialogButtonDescriptionIndex";

+ (void) dialogWithType:(QCCDialogType) type onWindow:(NSWindow *) window completionBlock:(void(^)(QCCDialogButton buttonPressed)) block {
    [QCCDialog dialogWithType:type forItem:nil onWindow:window completionBlock:block];
}

+ (void) dialogWithType:(QCCDialogType) type forItem:(NSString *) item onWindow:(NSWindow *) window completionBlock:(void(^)(QCCDialogButton buttonPressed)) block {

    if (!item)
        item = NSLocalizedString(@"Unknown item", "Dialog message");
    if (!block || !window)
        return;

    NSAlert *alert = [[NSAlert alloc] init];
    
    alert.messageText = [QCCDialog titleForType:type];
    alert.informativeText = [NSString stringWithFormat:[QCCDialog informationMessageForType:type], item];

    for (NSDictionary *buttonDescription in [QCCDialog buttonsForType:type]) {
        [alert addButtonWithTitle:buttonDescription[QCCDialogButtonDescriptionTitleKey]];
    }
    
    
    [alert beginSheetModalForWindow:window
                  completionHandler:^(NSModalResponse returnCode) {
                      NSArray *buttons = [QCCDialog buttonsForType:type];
                      NSUInteger buttonIndex = returnCode + NSModalResponseStop;
                      NSDictionary *buttonDescription;
                      if ([buttons count] > buttonIndex)
                          buttonDescription = buttons[buttonIndex];
                      
                      QCCDialogButton button;
                      if (buttonDescription)
                          button = [buttonDescription[QCCDialogButtonDescriptionIndexKey] unsignedIntegerValue];
                      
                      block(button);
                  }];
    
}

+ (NSArray *) buttonsForType:(QCCDialogType) dialogType {
    switch (dialogType) {
        case QCCDialogTypeNone:
            return nil;
            break;
            case QCCDialogTypeRemovingItem:
            return @[[QCCDialog buttonDescriptionForButton:QCCDialogButtonDelete],
                     [QCCDialog buttonDescriptionForButton:QCCDialogButtonCancel]];
            
            case QCCDialogTypeRemovingFolder:
            return @[[QCCDialog buttonDescriptionForButton:QCCDialogButtonDelete],
                     [QCCDialog buttonDescriptionForButton:QCCDialogButtonCancel]];

    }
}

+ (NSDictionary *) buttonDescriptionForButton:(QCCDialogButton) button {
    NSString *title = [QCCDialog titleForButton:button];
    if (!title)
        return nil;
    
    return @{QCCDialogButtonDescriptionTitleKey : title,
             QCCDialogButtonDescriptionIndexKey : @(button)};
}


+ (NSString *) titleForButton:(QCCDialogButton) button {

    switch (button) {
        case QCCDialogButtonCancel:
            return NSLocalizedString(@"Cancel", @"Dialog button title.");
            break;

        case QCCDialogButtonDelete:
            return NSLocalizedString(@"Remove", @"Dialog button title.");
            break;

        case QCCDialogButtonOK:
            return NSLocalizedString(@"OK", @"Dialog button title.");
            break;

        case QCCDialogButtonNone:
            return NSLocalizedString(@"Unknown button", @"Dialog button title.");
            break;
            
        default:
            break;
    }
    
}

+ (NSString *) titleForType:(QCCDialogType) dialogType {
    switch (dialogType) {
        
        case QCCDialogTypeNone:
            return nil;
            break;

        case QCCDialogTypeRemovingFolder:
        case QCCDialogTypeRemovingItem:
            return NSLocalizedString(@"Warning!", @"Dialog title");

    }
}
//Do you want to move “QCCProjectDocument.m” to the Trash, or only remove the reference to it?

+ (NSString *) informationMessageForType:(QCCDialogType) dialogType {

    switch (dialogType) {
        case QCCDialogTypeNone:
            return nil;
            break;
            
        case QCCDialogTypeRemovingItem:
            return NSLocalizedString(@"Do you want to move “%@” to the Trash?", @"Dialog title");
            
        case QCCDialogTypeRemovingFolder:
            return NSLocalizedString(@"Do you want to move folder “%@” to the Trash? All included files will be removed also!", @"Dialog title");
            
    }
}



@end
