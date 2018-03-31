//
//  QCCProjectDocument.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectDocument.h"
#import "QCCDocumentController.h"

#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

#import "QCCProjectWindowController.h"
#import "QCCodeViewController.h"
#import "NSObject+Cast.h"
#import "QCCDialog.h"
#import "QCCTemplateManager.h"
#import "QCCBaseProjectDocument+Dialog.h"
#import "QCCImportPanel.h"

#import "QCCProjectProcessor.h"
#import "QCCProjectProcessor+Project.h"
#import "Qapular-Swift.h"

#import "QCCDocumentController+Menu.h"


#import <AppKit/AppKit.h>

@interface QCCProjectDocument () {

    QCCDocumentController   *_sharedDocumentController;
    QCCImportPanel          *_panel;
    QCCProjectProcessor     *_projectProcessor;
}

@end

@implementation QCCProjectDocument

static NSString *const  QCCProjectDocumentTemplate      = @"QCCProjectDocumentTemplate.plist";
static NSString *const  QCCProjectDocumentFileName      = @"project.plist";
static NSString *const  QCCProjectDocumentVersionKey    = @"QCCProjectDocumentVersion";



#pragma mark - Init

- (instancetype) initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    self = [super initWithType:typeName error:outError];
    if (self) {
    }
    return self;
}

- (void) loadEnviroment {
    [super loadEnviroment];
    _sharedDocumentController = [QCCDocumentController sharedDocumentController];
}

#pragma mark - Template
- (NSString *) projectTemplate {
    return QCCProjectDocumentTemplate;
}


#pragma mark - Read
-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {

   
    NSString *projectFileFullPath = [url.path stringByAppendingPathComponent:QCCProjectDocumentFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:projectFileFullPath isDirectory:nil])
        return NO;
    
    NSData *projectData = [NSData dataWithContentsOfFile:projectFileFullPath options:NSDataReadingMappedIfSafe error:outError];

    if (projectData.length == 0 && !projectData)
        return NO;
    
    NSDictionary *projectFile = [NSPropertyListSerialization propertyListWithData:projectData options:0 format:nil error:outError];
    
    QCCProjectEssence *root = [_templateManager instanceProjectStructure:projectFile[QCCProjectSourceConfigurationKey]
                                                              isTemplate:NO];
    
    [_sourceTreeContentArray addObject:root];
    
    _buildsConfiguration = [NSMutableDictionary dictionaryWithDictionary:projectFile[QCCProjectBuildsConfigurationKey]];
    _includesConfiguration = [NSMutableArray arrayWithArray:projectFile[QCCProjectIncludesConfigurationKey]];
    _linksConfiguration = [NSMutableArray arrayWithArray:projectFile[QCCProjectLinksConfigurationKey]];
    _deploymentsConfiguration = [[QCCDeploymentConfiguration alloc] initWithDictionary:projectFile[QCCProjectDeploymentConfigurationKey]];
    _deploymentsConfiguration.delegate = self;

    
    return YES;
}

#pragma mark - Write
-(void)saveDocument:(id)sender {
    
    for (NSDocument *document in [_sharedDocumentController documents]) {
        if (![document isKindOfClass:[QCCBaseProjectDocument class]])
            [document saveDocument:sender];
    }
    
    [super saveDocument:sender];
}

-(void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
}

-(BOOL)writeSafelyToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {

    NSMutableDictionary * projectFile = [NSMutableDictionary new];

    projectFile[QCCProjectDocumentVersionKey]           = @(0.1);
    projectFile[QCCProjectSourceConfigurationKey]       = [[_sourceTreeContentArray firstObject] serialize];
    projectFile[QCCProjectIncludesConfigurationKey]     = _includesConfiguration;
    projectFile[QCCProjectLinksConfigurationKey]        = _linksConfiguration;
    projectFile[QCCProjectBuildsConfigurationKey]       = _buildsConfiguration;
    projectFile[QCCProjectDeploymentConfigurationKey]   = [_deploymentsConfiguration serialize];

    NSData *projectData = [NSPropertyListSerialization dataWithPropertyList:projectFile format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
    
    NSString *projectFileFullPath = [url.path stringByAppendingPathComponent:QCCProjectDocumentFileName];

    if (projectData) {
        BOOL result = [projectData writeToFile:projectFileFullPath options:NSDataWritingAtomic error:outError];
        if (!result)
            return NO;
    }else {
        return NO;
    }
    
    return YES;
}



#pragma mark - QCCProjectDataSource
- (QCCThemaManager *) themaManager {
    return  _sharedDocumentController.applicationThemaManager;
}

- (QCCPreferences *) preferences {
    return _sharedDocumentController.applicationPreferences;
}

- (NSString *) titleForDocument; {return nil;}

- (NSImage *) imageForDocument; {return nil;}

#pragma mark - Open\Close document
- (void) openDocument:(NSDocument *) document documentWasAlreadyOpen:(BOOL) openned {
  
    QCCBaseDocument * baseDocument;
    if (document && [document isKindOfClass:[QCCBaseDocument class]]) {
        baseDocument = (QCCBaseDocument *) document;
        baseDocument.projectEnvironmentSource = self.processor;
    }
    
    if (!baseDocument)
        return;
    
    if (openned) {
        NSString * identifier = baseDocument.fileURL.path;
        if ([_projectWindowController.projectTabView indexOfTabViewItemWithIdentifier:identifier] != NSNotFound) {
            [_projectWindowController.projectTabView.tabBarView selectTabWithIdentifier:identifier];
            return;
        }
    }
  
    
    QCCodeViewController *codeViewController = [[QCCodeViewController alloc] initWithNibName:nil bundle:nil];

    codeViewController.identifier = document.fileURL.path;
    [codeViewController replaceEditorDataSource:baseDocument];
    
    NSTabViewItem *item  = [NSTabViewItem tabViewItemWithViewController:codeViewController];
    item.label = document.fileURL.lastPathComponent;
    item.identifier = codeViewController.identifier;
    [_projectWindowController.projectTabView addTabViewItem:item];

}

#pragma mark - QCCSourcetreeControllerDelegate
-(void)openProjectConfigurationWithObject:(QCCProjectEssence *)object {
    if (object.root)
        [_sharedDocumentController showProjectConfigurationArea:self];
}

- (void) openFileWithObject:(QCCProjectEssence *) essence inTab:(BOOL) inTab {
    
    if (essence.root)
        [_sharedDocumentController showProjectConfigurationArea:self];
    else
        [_sharedDocumentController showEditArea:self];
    
    NSString *urlString = [self projectFolderPath];
    
    [_sharedDocumentController openDocumentWithContentsOfURL:[essence fileURLWithProjectPath:urlString]
                                                     display:(!inTab)
                                           completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                                               if (!error) {
                                                   if (inTab)
                                                       [self openDocument:document documentWasAlreadyOpen:documentWasAlreadyOpen];
                                               }else  {
                                                   NSLog(@"Error: %@", error);
                                               }
                                           }];
}

- (void) closeFileWithObject:(QCCProjectEssence *) essence {
    
    for (QCCProjectEssence *childe in essence.children) {
        [self closeFileWithObject:childe];
    }
    
    NSString *urlString = [self projectFolderPath];
    id document = [_sharedDocumentController documentForURL:[essence fileURLWithProjectPath:urlString]];
    if (document && [document isKindOfClass:[QCCBaseDocument class]]) {
        QCCBaseDocument * baseDocument = (QCCBaseDocument *) document;
        NSString * identifier = baseDocument.fileURL.path;
        
        if ([_projectWindowController.projectTabView.tabBarView respondsToSelector:@selector(closeTabWithIdentifier:)])
            [_projectWindowController.projectTabView.tabBarView closeTabWithIdentifier:identifier];
        
        [document close];
    }
}

-(void)addFileToObject:(QCCProjectGroup *)group completion:(void (^)(QCCProjectEssence * file))resultEssenceBlock {

    [_templateManager createInGroup:group newFile:^(QCCProjectEssence *essence, NSError *error) {
        
        if (error) {
            NSAlert *errorAlert = [NSAlert alertWithError:error];
            [errorAlert runModal];
            return;
        }
        
        if (resultEssenceBlock && essence && !error)
            resultEssenceBlock(essence);
    }];
}

-(void)addFolderToObject:(QCCProjectGroup *)group completion:(void (^)(QCCProjectGroup *))resultGroupBlock {
    
    [_templateManager createInGroup:group newGrup:^(QCCProjectEssence *essence, NSError *error) {
        
        if (error) {
            NSAlert *errorAlert = [NSAlert alertWithError:error];
            [errorAlert runModal];
            return;
        }
        
        
        [essence dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup * object) {
            if (resultGroupBlock)
                resultGroupBlock(object);
        }];
        
    }];

}

#warning (NeedsBetterSolution) Move Import panel to UI classes
- (void) importEssencesToObject:(QCCProjectGroup *) group completion:(void (^)(NSArray * essences)) resultEssenceBlock {
    
    _panel = [[QCCImportPanel alloc] initWithRootURL:[group fileURLWithProjectPath:[self projectFolderPath]]
                                         excludeURLs:[group allChildrenURLsWithProjectPath:[self projectFolderPath]]
                                    allowedFileTypes:[_sharedDocumentController supportedTypesWithProject:NO]
                                              window:_projectWindowController.window];
    
    [_panel importItems:^(NSArray *items, NSError *error) {

       NSArray *esences = [_templateManager essenceWithURLs:items importedInGroup:group];
        if (resultEssenceBlock)
            resultEssenceBlock(esences);
    }];
}

- (void) moveEssenceToTrash:(QCCProjectEssence *) essence completion:(void (^)(BOOL result, NSError *error)) resultEssenceBlock {
    
    QCCDialogType dialogType = QCCDialogTypeRemovingItem;
    
    if ([essence isKindOfClass:[QCCProjectGroup class]])
        dialogType = QCCDialogTypeRemovingFolder;
    
    
    [self dialogWithType:dialogType forItem:essence.path completionBlock:^(QCCDialogButton buttonPressed) {
        if (buttonPressed == QCCDialogButtonDelete && essence && !essence.root) {
            [self closeFileWithObject:essence];
            
            [_projectFileMnager moveItemToTrash:essence completition:^(BOOL sucess) {
                if (sucess)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultEssenceBlock(sucess, nil);
                    });
            }];
        }
    }];
}

- (void) asyncSave {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveDocument:self];
    });
}

- (QCCProjectProcessor *) processor {
    if (_projectProcessor)
        return _projectProcessor;
    
    _projectProcessor = [[QCCProjectProcessor alloc] initForProjectDocument:self
                                                         documentController:_sharedDocumentController];
    
    
    _deploymentsConfiguration.dataSource = (id<QCCDeploymentConfigurationDataSource>) _projectProcessor;
    _deploymentsConfiguration.localizationDataSource = (id<QCCDeploymentConfigurationLocalization>) _projectProcessor;
    return _projectProcessor;
}

#pragma mark - Deployment configuration
- (QCCProjectConfigurationContainer *) projectConfigurationContainer {
    return [_deploymentsConfiguration projectConfigurationContainer];
}

#pragma mark - QCCDeploymentConfigurationProvider
- (QCCDeploymentConfiguration *) deploymentConfiguration {
    return _deploymentsConfiguration;
}

#pragma mark - Processor interface
- (NSSet *) sourcePathSet {
    QCCProjectGroup *group = [_sourceTreeContentArray firstObject];
    
    NSMutableSet *files = [NSMutableSet new];
    for (QCCProjectEssence *essence in [group allChildren]) {
        if ([essence isKindOfClass:[QCCProjectFile class]]) {
            NSURL *url = [essence fileURLWithProjectPath:[self projectFolderPath]];
            [files addObject:url];
        }
    }
    
    return files;
}


#pragma mark - Changed Attached port
- (void) selectAttachedPort:(NSString *) port {
    [self.processor selectAttachedPort:port];
}

- (void) selectDeploymentConfigurationContainerIdentifier:(NSString *) identifier {
    [self.processor selectDeploymentConfigurationContainerIdentifier:identifier];
}


#pragma mark - QCCMutableCollectionDelegate

-(void) addedObject {
    [_sharedDocumentController updateDocumentEnvironments];
}

-(void) removedObject {
    [_sharedDocumentController updateDocumentEnvironments];
}
@end
