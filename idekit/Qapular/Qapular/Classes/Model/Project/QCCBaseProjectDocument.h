//
//  QCCBaseProjectDocument.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCSourceTreeController.h"
#import "QCCProjectFileManager.h"
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@class QCCThemaManager;
@class QCCPreferences;
@class QCCTemplateManager;
@class QCCProjectWindowController;

@protocol QCCProjectDataSource <NSObject>

@required

- (QCCThemaManager *) themaManager;
- (QCCPreferences *) preferences;
- (NSArray <QCCProjectEssence *> *) sourceTreeContentArray;
- (QCCProjectFileManager *) projectFileManager;
- (NSString *) titleForDocument;
- (NSImage *) imageForDocument;

@end

extern NSString  *const  kUTTypeQCCProject;

extern NSString  *const  QCCProjectTemplatesFolder;

extern NSString  *const  QCCProjectIncludesConfigurationKey;
extern NSString  *const  QCCProjectLinksConfigurationKey;
extern NSString  *const  QCCProjectBuildsConfigurationKey;
extern NSString  *const  QCCProjectDeploymentConfigurationKey;


@interface QCCBaseProjectDocument : NSDocument <QCCProjectDataSource, QCCMutableCollectionDelegate> {
    
    NSMutableArray              *_includesConfiguration;
    NSMutableArray              *_linksConfiguration;
    NSMutableDictionary         *_buildsConfiguration;
    QCCDeploymentConfiguration  *_deploymentsConfiguration;
    
    NSMutableArray              *_sourceTreeContentArray;
    QCCProjectFileManager       *_projectFileMnager;
    
    QCCProjectWindowController  *_projectWindowController;
    
    QCCTemplateManager          *_templateManager;
    dispatch_queue_t            _project_model_queue;
    
}


- (BOOL) loadProjectTemplate;
- (NSString *) projectTemplate;
- (void) loadEnviroment;
- (NSString *) projectFolderPath;

@end
