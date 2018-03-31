//
//  QCCWelcomeWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCWelcomeWindowController.h"
#import "QCCBaseDocument+UTType.h"
#import "QCCBaseProjectDocument.h"
#import "QCCOpenRecentCellView.h"
#import "QCCSandBoxManager.h"

#import "QCCError.h"

typedef enum : NSUInteger {
    WelcomeCreateProjectOptionReplaceFolder,
    WelcomeCreateProjectOptionChangeProjectName
} WelcomeCreateProjectOption;


@interface QCCWelcomeWindowController () <NSOpenSavePanelDelegate, NSTableViewDataSource, NSTableViewDelegate> {
                NSSavePanel         *_createProjectPanel;
    IBOutlet    NSButton            *_createNewProjectButton;
    IBOutlet    NSButton            *_visitWebSiteButton;
    IBOutlet    NSButton            *_documentationButton;
    IBOutlet    NSButton            *_contactsButton;
    IBOutlet    NSTableView         *_openRecentTableView;
}

@end

@implementation QCCWelcomeWindowController
- (IBAction) openRecentAction:(id) sender {
    NSTableRowView *rowView = [_openRecentTableView rowViewAtRow:_openRecentTableView.selectedRow makeIfNecessary:NO];
    NSCell *cell = [rowView viewAtColumn:0];
    if ([cell isKindOfClass:[QCCOpenRecentCellView class]]) {
        QCCOpenRecentCellView *openRecentCellView = (QCCOpenRecentCellView*) cell;
        if (!openRecentCellView.projectURL)
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
           [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:openRecentCellView.projectURL
                                                                                  display:YES
                                                                        completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
                                                                            [self.window close];
                                                                        }];
        });
    }
}

#pragma mark - NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSTableView class]]) {
        NSTableView *tableView = (NSTableView *) notification.object;
        [tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
            id cell = [rowView viewAtColumn:0];
            
            if ([cell isKindOfClass:[QCCOpenRecentCellView class]]) {
                QCCOpenRecentCellView *openRecentCellView = (QCCOpenRecentCellView*) cell;
                
                if (rowView.selected) {
                    openRecentCellView.projectPathTextField.textColor = [NSColor whiteColor];
                    openRecentCellView.projectTitleTextField.textColor = [NSColor whiteColor];
                }else {
                    openRecentCellView.projectPathTextField.textColor = [NSColor blackColor];
                    openRecentCellView.projectTitleTextField.textColor = [NSColor blackColor];
                }
            }
        }];
    }
    
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self recentProjectURLs] count];
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *array = [self recentProjectURLs];
    
    if ([array count] > row)
        return array[row];
    return nil;
}

- (NSArray <NSURL *> *) recentProjectURLs {
    NSMutableArray *recentProjectURLs = [NSMutableArray new];
    NSString *projectExtension = [QCCBaseDocument extensionForUTType:kUTTypeQCCProject];
    for (NSURL *recentDocument in [[NSDocumentController sharedDocumentController] recentDocumentURLs]) {
    
        if ([recentDocument.pathExtension isEqualToString:projectExtension]) {
            [recentProjectURLs addObject:recentDocument];
        }
        
    }
    
    return recentProjectURLs;

}

- (void)windowDidLoad {
    [_createNewProjectButton setAttributedTitle:[self clearColorForAttributedString:_createNewProjectButton.attributedTitle]];
    [_visitWebSiteButton setAttributedTitle:[self clearColorForAttributedString:_visitWebSiteButton.attributedTitle]];
    [_documentationButton setAttributedTitle:[self clearColorForAttributedString:_documentationButton.attributedTitle]];
    [_contactsButton setAttributedTitle:[self clearColorForAttributedString:_contactsButton.attributedTitle]];
    [_openRecentTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    
    [super windowDidLoad];    
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}


#pragma mark - Actions
- (IBAction) createDocument:(id)sender {
    
    [self showCreatePanelForFileName:@"project"
                          fieldLabel:NSLocalizedString(@"Create:", nil)
                            fileType:kUTTypeQCCProject
                        sucsessBlock:^(NSURL *fileUrl, NSString * UTType) {
                            
                            [_delegate welcomeWindowController:self
                                         createDocumentWithURL:fileUrl
                                                      fileType:UTType];
                    }];
    
    
}

- (IBAction) visitWebSite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://qapular.com?source=IDE1.0.5"]];

}

- (IBAction) openDocumentation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://qapular.com/documentation/?source=IDE1.0.5"]];

}

- (IBAction) openContacts:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://qapular.com/contact/?source=IDE1.0.5"]];

}



#pragma mark - Ceate Panel
- (void) showCreatePanelForFileName:(NSString *) file fieldLabel:(NSString *) fieldLabel fileType:(NSString *) fileType sucsessBlock:(void (^)(NSURL *fileUrl, NSString * UTType)) block {
    
    _createProjectPanel = [NSSavePanel savePanel];
    _createProjectPanel.nameFieldStringValue = file;
    _createProjectPanel.nameFieldLabel = fieldLabel;
    
    _createProjectPanel.directoryURL = [self defaultURL];
    _createProjectPanel.allowedFileTypes = @[];
    _createProjectPanel.allowsOtherFileTypes = NO;
    _createProjectPanel.delegate = self;
    
    [_createProjectPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
            NSError *error;
            
            [[NSFileManager defaultManager] createDirectoryAtURL:_createProjectPanel.URL
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
            
            NSString *projectName = [_createProjectPanel.URL.lastPathComponent  stringByAppendingPathExtension:[QCCBaseDocument extensionForUTType:fileType]];
            
            if (error)
                NSLog(@"Can't create project folder, error: %@", error);
            
            
            NSURL *url = [_createProjectPanel.URL URLByAppendingPathComponent:projectName];

            [QCCSandBoxManager saveBookmarkForURL:_createProjectPanel.URL relatedProjectURL:url];
            
            block(url, fileType);
        }
    }];

}




- (IBAction) closeWindow:(id)sender {
    [self.window close];
}


#pragma mark - NSOpenSavePanelDelegate
- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    
    NSString *projectFolderURLString = [url.path stringByDeletingPathExtension];
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:projectFolderURLString];
    
    if (exist) {
        *outError = [QCCError errorForCode:QCCErrorCodeProjectFolderExist attempter:self recoveryOptions:@[@"Replace folder", @"Change project name"]];
        return NO;
    }
    
    return YES;
}


- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo {
    BOOL success =  NO;
    NSError *processError;
    
    if ([delegate isKindOfClass:[NSSavePanel class]] && (recoveryOptionIndex == WelcomeCreateProjectOptionReplaceFolder)) {
        NSSavePanel *savePanel = (NSSavePanel *) delegate;
        BOOL canDelete = [[NSFileManager defaultManager] isDeletableFileAtPath:[savePanel.URL.path stringByDeletingPathExtension]];
        
        if (canDelete){
            success = [[NSFileManager defaultManager] removeItemAtURL:[savePanel.URL URLByDeletingPathExtension] error:&processError];
        }
    }
    
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didRecoverSelector]];
    [invoke setSelector:didRecoverSelector];
    [invoke setArgument:(void *)&success atIndex:2];
    
    if (processError)
        [invoke setArgument:&processError atIndex:3];
    
    [invoke invokeWithTarget:delegate];
}



- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url {
//    NSLog(@"didChangeToDirectoryURL: %@", url);
}

- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag {
//    NSLog(@"%s %@ ", __FUNCTION__, filename);
    return filename;
}

#pragma mark - Helper
- (NSURL *) defaultURL {
    
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask,YES);
    id path = [pathArray firstObject];
    if (![path isKindOfClass:[NSString class]])
        return nil;
    NSString *pathString = [NSString stringWithString:path];
    return [NSURL URLWithString:pathString];

}

- (NSAttributedString *) clearColorForAttributedString:(NSAttributedString *) attributedString {

    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, attributedString.string.length)];
    
    
    
    
    return mutableAttributedString;
}

@end
