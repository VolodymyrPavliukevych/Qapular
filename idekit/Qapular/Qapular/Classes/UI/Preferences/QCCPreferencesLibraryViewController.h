//
//  QCCPreferencesLibraryViewController.h
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QCCPreferencesLibraryDataSource <NSObject>

- (nonnull NSArray <NSURL *> *) libraryURLs;

@end

@protocol QCCPreferencesLibraryDelegate <NSObject>
- (void) addLibraryFolder;
- (void) removeLibraryFolder:(nonnull NSURL *) folderURL;
@end

@interface QCCPreferencesLibraryViewController : NSViewController

@property (nullable, nonatomic, weak) id <QCCPreferencesLibraryDataSource> dataSource;
@property (nullable, nonatomic, weak) id <QCCPreferencesLibraryDelegate> delegate;

- (void) reloadContent;

@end
