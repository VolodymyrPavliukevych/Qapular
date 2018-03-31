//
//  QCCSourceTreeController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCOutlineView.h"
#import "QCCProjectFileManager.h"
#import "QCCSourcetreeControllerInterfaceDelegate.h"

@class QCCProjectEssence;
@class QCCProjectGroup;


@protocol QCCSourcetreeControllerDelegate <NSObject>

- (void) openFileWithObject:(QCCProjectEssence *) object inTab:(BOOL) inTab;
- (void) closeFileWithObject:(QCCProjectEssence *) object;

- (void) addFileToObject:(QCCProjectGroup *) group completion:(void (^)(QCCProjectEssence * essence)) resultEssenceBlock;
- (void) addFolderToObject:(QCCProjectGroup *) group completion:(void (^)(QCCProjectGroup * group)) resultGroupBlock;
- (void) importEssencesToObject:(QCCProjectGroup *) group completion:(void (^)(NSArray * essences)) resultEssenceBlock;

- (void) moveEssenceToTrash:(QCCProjectEssence *) essence completion:(void (^)(BOOL result, NSError *error)) resultEssenceBlock;

- (void) asyncSave;

- (void) openProjectConfigurationWithObject:(QCCProjectEssence *) object;

@end

@interface QCCSourceTreeController : NSTreeController <NSOutlineViewDelegate, NSOutlineViewDataSource, QCCOutlineViewDelegate, NSMenuDelegate>

@property (nonatomic, weak) id <QCCSourcetreeControllerDelegate> delegate;
@property (nonatomic, weak) id <QCCProjectFileManagerDelegate> fileManagerDelegate;
@property (nonatomic, weak) IBOutlet id <QCCSourcetreeControllerInterfaceDelegate> interfaceDelegate;

- (IBAction) addFile:(id)sender;
- (IBAction) addFolder:(id)sender;
- (IBAction) removeNode:(id)sender;
- (IBAction) showInFinder:(id)sender;
- (IBAction) openInEditor:(id)sender;
- (IBAction) importToFolder:(id)sender;

@end
