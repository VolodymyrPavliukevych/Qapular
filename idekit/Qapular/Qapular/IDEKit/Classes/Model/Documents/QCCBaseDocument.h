//
//  QCCBaseDocument.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCodeStorage;
@class QCCThemaManager;
@class QCCodeView;
@class QCCPreferences;
@class QCCAnalyser;
@class QCCDocumentController;
@class QCCProjectDocument;
@protocol QCCProjectEnvironmentSource;

@protocol QCCEditorDataSource <NSObject>
@required

- (QCCodeStorage *) codeStorageForCodeView:(QCCodeView *) view;
- (QCCThemaManager *) themaManagerForCodeView:(QCCodeView *) view;
- (QCCPreferences *) preferencesForCodeView:(QCCodeView *) view;
- (QCCAnalyser *) analyserForCodeView:(QCCodeView *) view;

- (NSString *) titleForDocument;
- (NSImage *) imageForDocument;

@end


@interface QCCBaseDocument : NSDocument <QCCEditorDataSource> {
    QCCDocumentController   *_sharedDocumentController;
}



@property (nonatomic, weak) id<QCCProjectEnvironmentSource> projectEnvironmentSource;

-(instancetype)initAutoSaveFileWithType:(NSString *)typeName error:(NSError **)outError completion:(void (^)(NSError *errorOrNil))completion;



- (QCCPreferences *) preferences;

@end
