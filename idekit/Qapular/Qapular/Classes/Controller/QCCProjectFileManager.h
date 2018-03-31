//
//  QCCProjectFileManager.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCProjectEssence;
@class QCCBaseProjectDocument;

@protocol QCCProjectFileManagerDelegate <NSObject>
@required

- (void) moveItemToTrash:(QCCProjectEssence *) essence completition:(void (^)(BOOL sucess)) block;
- (void) showItemInFinder:(QCCProjectEssence *) essence completition:(void (^)(BOOL sucess)) block;

- (BOOL) createFolder:(NSString *) fullPath;
- (BOOL) createOnFilesystem:(QCCProjectEssence *) essence;
- (BOOL) createOnFilesystem:(QCCProjectEssence *) essence withData:(NSData *) content;

@end


@interface QCCProjectFileManager : NSObject <QCCProjectFileManagerDelegate>

- (instancetype) initWithDocument:(QCCBaseProjectDocument *) document;
- (BOOL) essenceExists:(QCCProjectEssence *) essence inProjectPath:(NSString *) projectPath;

@end
