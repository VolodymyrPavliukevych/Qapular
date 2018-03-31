//
//  QCCProjectWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectWindowController.h"
#import "QCCProjectDocument.h"
#import "QCCView.h"
#import "QCCSplitView.h"
#import "QCCThemaManager.h"
#import "QCCError.h"
#import "QCCProjectProcessor+Launcher.h"
#import "QCCProcessDocumentProtocol.h"
#import "QCCProjectProcessor.h"
#import "QCCDocumentController+Menu.h"

static NSString *const ProjectWindowControllerNibName = @"ProjectWindowController";

@interface QCCProjectWindowController () <QCCProcessReportProtocol>{
    
    id <QCCProcessDocumentProtocol> _documentProcessingDelegate;
    
}


@end

@implementation QCCProjectWindowController

#pragma mark - Notifications
- (void) subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themaManagerReplaced)
                                                 name:QCCThemaManagerReplacedNotification
                                               object:nil];
}

- (void) unsubscribe {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) themaManagerReplaced {
    QCCThemaManager *themaManager = [_projectDataSource themaManager];
    
    NSColor *borderColor = [themaManager projectWindowBorderColor];
    NSColor *normalBackgroundColor = [themaManager projectWindowBackgroundNormalColor];
    
    _navigationAreaToolBarView.borderType = QCCBorderedTypeButtom;
    _navigationAreaToolBarView.backgroundColor = normalBackgroundColor;
    _navigationAreaToolBarView.borderColor = borderColor;
    
    _sourceTreeOutlineView.backgroundColor = normalBackgroundColor;
    _sourceTreeOutlineView.themaManagerDataSource = self;
    _navigationAreaViewController.themaManagerDataSource = self;
    
    
}

+ (instancetype)initFromDefaultWindowNib {
    NSString *nibName = [QCCProjectWindowController interfaceNibName];
    return [[QCCProjectWindowController alloc] initWithWindowNibName:nibName];
}


- (instancetype) initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self subscribeForNotifications];
    [self themaManagerReplaced];
}

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [super awakeAfterUsingCoder:aDecoder];
}

-(void)setDocument:(QCCProjectDocument *)document {
    [super setDocument:document];
    
    if([document.processor conformsToProtocol:@protocol(QCCProcessDocumentProtocol)])
        _documentProcessingDelegate = document.processor;
    
    document.processor.processReportDelegate = self;
    
    _projectDataSource = document;
    [self themaManagerReplaced];
}

-(void)setSourceTreeController:(QCCSourceTreeController *)sourceTreeController {
    _sourceTreeController = sourceTreeController;
    
    if ([self.document conformsToProtocol:@protocol(QCCSourcetreeControllerDelegate)]) {
        id<QCCSourcetreeControllerDelegate> sourcetreeControllerDelegate = (id<QCCSourcetreeControllerDelegate>) self.document;
        _sourceTreeController.delegate = sourcetreeControllerDelegate;
    }
    
    
    if ([self.document conformsToProtocol:@protocol(QCCProjectDataSource)] && [self.document respondsToSelector:@selector(projectFileManager)]) {
        id <QCCProjectDataSource> projectDataSource = (id <QCCProjectDataSource>) self.document;
        _sourceTreeController.fileManagerDelegate = [projectDataSource projectFileManager];
    }
    
    if ([_projectDataSource respondsToSelector:@selector(sourceTreeContentArray)]) {
        
        if ([_projectDataSource sourceTreeContentArray]) {
            [_sourceTreeController bind:NSContentBinding
                               toObject:_projectDataSource
                            withKeyPath:NSStringFromSelector(@selector(sourceTreeContentArray))
                                options:nil];
        }
    }
}



+ (NSString *) interfaceNibName {
    return ProjectWindowControllerNibName;
}

#pragma mark - NSSplitViewDelegate
- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    return [QCCSplitView minSplitedViewWidth];
}

//- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
//    return splitView.frame.size.height - [QCCSplitView minSplitedViewWidth];
//}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

-(void)dealloc {
    [self unsubscribe];
}


#pragma mark - QCCThemaManagerDataSource
-(QCCThemaManager *)themaManager {
    return [_projectDataSource themaManager];
}


#pragma mark - Project Action
- (IBAction) runButtonAction:(NSButton *)sender {
    @synchronized(sender) {
        if (!sender.enabled)
            return;
        
        BOOL isWorking = [_documentProcessingDelegate processDocument:QCCProcessDocumentFullBuild
                                                      completionBlock:^(QCCProcessDocumentMask processed, NSError *error) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (processed == QCCProcessDocumentFlagBuild ||
                                                                  error.code == QCCErrorCodeActionTerminated ||
                                                                  error.code == ErrorPhaseResultFail){
                                                                  sender.enabled = YES;
                                                              }
                                                              
                                                              if(error && (error.code != QCCErrorCodeActionTerminated /*&& error.code != ErrorPhaseResultFail*/))
                                                                  [[NSAlert alertWithError:error] runModal];
                                                          });
                                                      }];
        
        sender.enabled = !isWorking;
        sender.state = NSOffState;
    }
}


- (IBAction) stopButtonAction:(NSButton *)sender {
    @synchronized(sender) {
        if (!sender.enabled)
            return;
        
        BOOL isWorking = [_documentProcessingDelegate processDocument:QCCProcessDocumentMaskStop
                                                      completionBlock:^(QCCProcessDocumentMask processed, NSError *error) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              sender.enabled = YES;
                                                              if(error && error.code != QCCErrorCodeActionTerminated)
                                                                  [[NSAlert alertWithError:error] runModal];
                                                          });
                                                      }];
        
        sender.enabled = !isWorking;
        sender.state = NSOffState;
    }
}

- (IBAction) uploadButtonAction:(NSButton *) sender {
    @synchronized(sender) {
        if (!sender.enabled)
            return;
        
        BOOL isWorking = [_documentProcessingDelegate processDocument:QCCProcessDocumentFullUpload
                                                      completionBlock:^(QCCProcessDocumentMask processed, NSError *error) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (processed == QCCProcessDocumentFlagUploadOnTarget ||
                                                                  error.code == QCCErrorCodeActionTerminated ||
                                                                  error.code == ErrorPhaseResultFail) {
                                                                  sender.enabled = YES;
                                                              }
                                                              
                                                              if(error && (error.code != QCCErrorCodeActionTerminated && error.code != ErrorPhaseResultFail))
                                                                  [[NSAlert alertWithError:error] runModal];
                                                          });
                                                      }];
        
        
        sender.enabled = !isWorking;
        sender.state = NSOffState;
    }
}

- (IBAction) openSerialConsole:(NSButton *) sender {
    sender.state = NSOffState;

    if ([[NSDocumentController sharedDocumentController] isKindOfClass:[QCCDocumentController class]]) {
        QCCDocumentController *documentController = (QCCDocumentController *) [NSDocumentController sharedDocumentController];
        [documentController showSerialConsole:sender];
    }
    
}


#pragma mark - QCCProcessReportProtocol

-(void)insertReportLine:(NSAttributedString *) reportLine {
    [self.debugTextView insertLineBreak:nil];
    [self.debugTextView insertText:reportLine replacementRange:NSMakeRange(self.debugTextView.textStorage.string.length, 0)];
    [self.debugTextView insertLineBreak:nil];
}

- (void) clearReport {
    [self.debugTextView insertText:[NSAttributedString new] replacementRange:NSMakeRange(0, self.debugTextView.textStorage.string.length)];
}

#pragma mark - QCCDeploymentConfigurationDataSource
- (QCCDeploymentConfiguration *) deploymentConfiguration {
    if ([self.document conformsToProtocol:@protocol(QCCDeploymentConfigurationProvider)])
        return [self.document deploymentConfiguration];
    
    return nil;
}

@end
