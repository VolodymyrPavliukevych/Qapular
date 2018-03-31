//
//  QCCDocumentController+Menu.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCDocumentController+Menu.h"
#import "QCCDocumentController.h"

#import "QCCTargetManagerMenuItem.h"
#import "QCCProjectDocument.h"
#import "NSObject+Cast.h"
#import "QCCTargetManager+MenuFabric.h"
#import "QCCProjectProcessor.h"
#import "QCCPreferencesViewController.h"
#import "QCCProjectWindowController.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>
#import "QCCDeploymentConfigurationMenuItem.h"
#import "QCCSerialConsoleWindowController.h"
    
typedef enum : NSUInteger {
    
    QCCDocumentControllerMenuTagShowSourceTreeNavigator = 211,
    QCCDocumentControllerMenuTagShowTargetNavigator     = 212,
    QCCDocumentControllerMenuTagShowSearchNavigator     = 213,
    
    QCCDocumentControllerMenuTagShowEditArea            = 221,
    QCCDocumentControllerMenuTagShowReportArea          = 222,
    QCCDocumentControllerMenuTagShowConfigurationArea   = 223,
    
    QCCDocumentControllerMenuTagShowDebug               = 231,

    QCCDocumentControllerMenuTagFullScreen              = 240,

    
    QCCDocumentControllerMenuTagTargetManager           = 110,
    QCCDocumentControllerMenuTagAttachedPorts           = 120,
    
    QCCDocumentControllerMenuTagProject                 = 300,
    QCCDocumentControllerMenuTagDeployemntConfiguration = 310
    
} QCCDocumentControllerMenuTag;


@implementation QCCDocumentController (Menu)

#pragma mark - UI Actions
- (IBAction)newDocument:(id)sender {
    if (![self currentDocument])
        [self showWelcomeWindow];
    else {
        QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
        [projectWindowController.sourceTreeController addFile:sender];
    }
}

-(IBAction)saveAllDocuments:(id)sender {
    [super saveAllDocuments:sender];
}

-(IBAction)saveDocument:(id)sender {
    [[self currentDocument] saveDocument:sender];
}

#pragma mark - Menu section
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    switch (menuItem.tag) {
        case QCCDocumentControllerMenuTagAttachedPorts: {
            if (![[self currentDocument] isKindOfClass:[QCCProjectDocument class]])
                return NO;
            
            [menuItem.submenu removeAllItems];
            
            for (QCCTargetManagerMenuItem *portItem in [self.applicationTargetManager attachedPortMenuArray]) {
                portItem.action = @selector(selectAttachedPortWithMenu:);
                [menuItem.submenu addItem:portItem];
                
                [[self currentDocument] dependClass:[QCCProjectDocument class] performBlock:^(QCCProjectDocument *project) {
                    if ([project.processor.selectedBSDPortName isEqualToString:portItem.selectedBSDPortName])
                        [portItem setState:NSOnState];
                }];
            }
        }
            break;
            
        case QCCDocumentControllerMenuTagDeployemntConfiguration: {
            if (![[self currentDocument] isKindOfClass:[QCCProjectDocument class]])
                return NO;
            
            [menuItem.submenu removeAllItems];
            
            if ([self.currentDocument isKindOfClass:[QCCProjectDocument class]]) {
                QCCProjectDocument *projectDocument = (QCCProjectDocument *) self.currentDocument;
                NSDictionary *configurationContainers = [[projectDocument.deploymentConfiguration projectConfigurationContainer] deployemntConfigurationContainers];
                for (NSString *identefier in [configurationContainers allKeys]) {
                    QCCDeploymentConfigurationContainer *deploymentConfigurationContainer = configurationContainers[identefier];
                    
                    QCCDeploymentConfigurationMenuItem *configurationMenuItem = [[QCCDeploymentConfigurationMenuItem alloc] initWithTitle:deploymentConfigurationContainer.name
                                                                                                                               identifier:deploymentConfigurationContainer.identifier];
                    configurationMenuItem.action = @selector(selectDeploymentConfigurationWithMenu:);
                    [menuItem.submenu addItem:configurationMenuItem];
                    
                    if ([deploymentConfigurationContainer.identifier isEqualToString:projectDocument.processor.selectedDeploymentConfigurationContainerIdentifier]) {
                        [configurationMenuItem setState:NSOnState];
                    }
                }
            }
        }
            break;
            
        case QCCDocumentControllerMenuTagShowSourceTreeNavigator:
            return NO;
            
        case QCCDocumentControllerMenuTagShowTargetNavigator:
            return NO;
            
        case QCCDocumentControllerMenuTagShowSearchNavigator:
            return NO;
            
        case QCCDocumentControllerMenuTagShowEditArea: {
            QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
            if ([projectWindowController.manipulationTabView selectedArea] == QCCManipulationEditArea){
                [menuItem setState:NSOnState];
            }else {
                [menuItem setState:NSOffState];
            }
            return YES;
        }
        

        case QCCDocumentControllerMenuTagShowReportArea:
            return NO;
            /*
             QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
             if ([projectWindowController.manipulationTabView selectedArea] == QCCManipulationReportArea) {
             [menuItem setState:NSOnState];
             }else {
             [menuItem setState:NSOffState];
             }
             return YES;
             */
            
        case QCCDocumentControllerMenuTagShowConfigurationArea: {
            QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
            if ([projectWindowController.manipulationTabView selectedArea] == QCCManipulationConfigurationArea) {
                [menuItem setState:NSOnState];
            }else {
                [menuItem setState:NSOffState];
            }
        }
            
            return YES;
            break;

        case QCCDocumentControllerMenuTagShowDebug:
            return YES;

        case QCCDocumentControllerMenuTagFullScreen:
            return NO;

        default:
            break;
    }
    return YES;
}

#pragma mark - Target Manager Menu
- (IBAction) attachedPortMenu:(id)sender {
    
}

- (IBAction) deploymentConfigurationMenu:(id)sender {
    
}

- (void) selectAttachedPortWithMenu:(NSMenuItem *) sender {
    [sender dependClass:[QCCTargetManagerMenuItem class] performBlock:^(QCCTargetManagerMenuItem * targetManagerMenuItem) {
        [[self currentDocument] dependClass:[QCCProjectDocument class] performBlock:^(QCCProjectDocument *project) {
            [project selectAttachedPort:targetManagerMenuItem.selectedBSDPortName];
        }];
    }];
}

- (void) selectDeploymentConfigurationWithMenu:(NSMenuItem *) sender {
    if ([sender isKindOfClass:[QCCDeploymentConfigurationMenuItem class]]) {
        QCCDeploymentConfigurationMenuItem *configurationMenuItem = (QCCDeploymentConfigurationMenuItem *) sender;
        if ([self.currentDocument isKindOfClass:[QCCProjectDocument class]]) {
            QCCProjectDocument *projectDocument = (QCCProjectDocument *) self.currentDocument;
            [projectDocument selectDeploymentConfigurationContainerIdentifier:configurationMenuItem.identifier];
            [sender setState:NSOnState];
            [self updateDocumentEnvironments];
        }
    }
}


#pragma mark - View Menu
- (IBAction) showSourceTreeNavigator:(id)sender {
    
}

- (IBAction) showTargetNavigator:(id)sender {
    
}

- (IBAction) showSearchNavigator:(id)sender {
    
}

- (IBAction) showDebug:(id)sender {
    
}

- (IBAction) showEditArea:(id)sender {
    QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
    [projectWindowController.manipulationTabView showArea:QCCManipulationEditArea];
}

- (IBAction) showReportArea:(id)sender {
    QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
    [projectWindowController.manipulationTabView showArea:QCCManipulationReportArea];
}


- (IBAction) showProjectConfigurationArea:(id)sender {
    QCCProjectWindowController *projectWindowController = [self currentProjectWindowController];
    [projectWindowController.manipulationTabView showArea:QCCManipulationConfigurationArea];

}

- (IBAction) showFullScreen:(id)sender {}

- (IBAction) showSerialConsole:(id)sender {
    if (!_serialConsoleWindowController) {
        _serialConsoleWindowController = [[QCCSerialConsoleWindowController alloc] initWithWindowNibName:NSStringFromClass([QCCSerialConsoleWindowController class])];
        [_serialConsoleWindowController setContentViewController:self.applicationTargetManager.serialConsoleViewController];
    }
    [_serialConsoleWindowController.window makeKeyAndOrderFront:self];
}

#pragma mark - Helper 
- (QCCProjectWindowController *) currentProjectWindowController {
    id document = [self currentDocument];
    
    if ([document isKindOfClass:[QCCProjectDocument class]]){
        QCCProjectDocument *projectDocument = (QCCProjectDocument *) document;
        if ([[[projectDocument windowControllers] firstObject] isKindOfClass:[QCCProjectWindowController class]]) {
            QCCProjectWindowController *projectWindowController = (QCCProjectWindowController *) [[projectDocument windowControllers] firstObject];
            return projectWindowController;
        }
    }
    
    return nil;
}



@end
