//
//  QCCBaseProjectDocument.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseProjectDocument.h"
#import "QCCProjectWindowController.h"

#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import "QCCSandBoxManager.h"
#import "QCCTemplateManager.h"


@implementation QCCBaseProjectDocument

NSString  *const  kUTTypeQCCProject                     =   @"com.qapular.project";

NSString  *const  QCCProjectIncludesConfigurationKey    =   @"IncludesConfigurationKey";
NSString  *const  QCCProjectLinksConfigurationKey       =   @"LinksConfigurationKey";
NSString  *const  QCCProjectBuildsConfigurationKey      =   @"BuildsConfigurationKey";
NSString  *const  QCCProjectDeploymentConfigurationKey  =   @"DeploymentConfiguration";

NSString *const QCCProjectTemplatesFolder               =  @"Templates";

//static NSString *const QCCSourceTreeChildrenKey         =   @"children";
//static NSString *const QCCSourceTreeObjectKey           =   @"object";

-(instancetype)init {
    
    self = [super init];
    if (self) {
        _includesConfiguration = [NSMutableArray new];
        _linksConfiguration = [NSMutableArray new];
        _buildsConfiguration = [NSMutableDictionary new];
        _sourceTreeContentArray = [NSMutableArray new];
        
        _projectFileMnager = [[QCCProjectFileManager alloc] initWithDocument:self];
        _templateManager = [[QCCTemplateManager alloc] initWithDocument:self];
        
        _project_model_queue = dispatch_queue_create("QCCProjectModelQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(instancetype)initForURL:(NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    if (!contentsURL)
        self = [super initWithType:typeName error:outError];
    else
        self = [super initForURL:urlOrNil withContentsOfURL:contentsURL ofType:typeName error:outError];
    
    
    if (self) {
        
        self.fileURL = urlOrNil;
        [self loadEnviroment];

        if (!contentsURL)
            [self loadProjectTemplate];
        
    }
    return self;
    
}
-(void)close {
    
    [QCCSandBoxManager closeAccessToProjectURL:self.fileURL];
    [super close];
}

-(instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    self = [super initWithContentsOfURL:url ofType:typeName error:outError];
    if (self) {
        [self loadEnviroment];
    }
    
    return self;
}
- (void) loadEnviroment {

}

- (BOOL) loadProjectTemplate {

    __block BOOL result = NO;

    dispatch_sync(_project_model_queue, ^{
       result = [self loadProjectTemplateInSerialQueue];
    });

    return result;
}

- (BOOL) loadProjectTemplateInSerialQueue {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self templatePathString]])
        return NO;
    NSError *readingError;
    
    NSData *content = [NSData dataWithContentsOfFile:[self templatePathString]
                                             options:NSDataReadingUncached
                                               error:&readingError];
    
    if (!content || content.length == 0)
        return NO;
    NSPropertyListFormat format;
    NSDictionary * template = [NSPropertyListSerialization propertyListWithData:content
                                                                        options:NSPropertyListImmutable
                                                                         format:&format
                                                                          error:&readingError ];
    
    NSDictionary * deploymentConfigurationTemplate = template[QCCProjectDeploymentConfigurationKey];
    NSDictionary * sourceConfigurationTemplate = template[QCCProjectSourceConfigurationKey];

    
    if (deploymentConfigurationTemplate) {
        _deploymentsConfiguration = [[QCCDeploymentConfiguration alloc] initWithDictionary:deploymentConfigurationTemplate];
        _deploymentsConfiguration.delegate = self;
    }
    QCCProjectEssence *root = [_templateManager instanceProjectStructure:sourceConfigurationTemplate isTemplate:YES];
    [_sourceTreeContentArray addObject:root];
    
    [self saveDocument:self];
    return YES;
}

- (NSString *) projectFolderPath {
    return [self.fileURL.path stringByDeletingPathExtension];
}

- (NSString *) projectTemplate {

    return nil;
}

- (NSString *) templatePathString {

    NSURL *resourceURL = [[NSBundle mainBundle] resourceURL];
    NSString *urlString = [resourceURL.path stringByAppendingPathComponent:QCCProjectTemplatesFolder];
    urlString = [urlString stringByAppendingPathComponent:[self projectTemplate]];
    return urlString;
}


-(void)makeWindowControllers {
    QCCProjectWindowController *windowController = [QCCProjectWindowController initFromDefaultWindowNib];
    _projectWindowController = windowController;
    [self addWindowController:windowController];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return NO;
}

+ (BOOL)autosavesInPlace {
    return NO;
}



#pragma mark - QCCProjectDataSource
- (QCCThemaManager *) themaManager; {return nil;}
- (QCCPreferences *) preferences; {return nil;}
- (NSString *) titleForDocument; {return nil;}
- (NSImage *) imageForDocument; {return nil;}

- (QCCProjectFileManager *) projectFileManager {
    return _projectFileMnager;
}

- (NSArray *)sourceTreeContentArray {
    return _sourceTreeContentArray;
}

#pragma mark - QCCMutableCollectionDelegate

-(void) addedObject {}
-(void) removedObject {}

@end
