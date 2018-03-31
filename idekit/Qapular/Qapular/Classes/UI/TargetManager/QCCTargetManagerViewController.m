//
//  QCCTargetManagerViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTargetManagerViewController.h"
#import "QCCTargetManagerCellView.h"
#import "QCCDocumentController.h"
#import "QCCError.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>


@interface QCCTargetManagerViewController () <NSTableViewDelegate, QCCTargetManagerCellViewDelegate> {
    QCCDocumentController       *_documentController;
    IBOutlet NSTableView        *_tableView;
    
}

@end

@implementation QCCTargetManagerViewController

-(instancetype)initWithCoder:(NSCoder *)coder {

    self = [super initWithCoder:coder];
    
    if (self) {
        
        _documentController = [QCCDocumentController sharedDocumentController];
        
    }
    
    return self;
}

#pragma mark - NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self targetIdentefiers] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identefier = [self targetIdentefiers][row];
    return [_documentController.applicationTargetManager targets][identefier];
}

- (NSArray *) targetIdentefiers {

    NSArray *targetIdentefiers = [[_documentController.applicationTargetManager targets] allKeys];
    return [targetIdentefiers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


#pragma mark - QCCTargetManagerCellViewDelegate
- (void) installTargetWithIdentefier:(NSString *) identefier completion:(void (^)(NSInteger total, NSInteger installed, NSError *error)) completion {
    
    if (identefier) {
        QCCTarget *target = [_documentController.applicationTargetManager targets][identefier];
        
        NSUInteger total = [[[target.schema dependencyPackageIdentifierSet] allObjects] count];
        __block NSUInteger installed = 0;
        
        for (NSString *packageIdentefier in [[target.schema dependencyPackageIdentifierSet] allObjects]) {
            QCCPackage *package = [_documentController.applicationTargetManager packages][packageIdentefier];
            if (!package)
                continue;
            
            if (!package.isInstalled) {
                package.downloadProgressBlock = ^ (QCCPackageDownloadState state,
                                                   NSError *error,
                                                   int64_t totalBytesWritten,
                                                   int64_t expectedTotalBytes) {
                    if (error || state != QCCPackageDownloadStateIsInProgress)
                        NSLog(@"QCCPackageDownloadState: %lu Error: %@", (QCCPackageDownloadState)state, (error?: @"no"));
                };
                
                package.unpackProgressBlock = ^ (QCCPackageUnpackState state) {
                    NSLog(@"QCCPackageUnpackState :%lu", state);
                };
                
                [package installWithStateBlock:^(QCCBasePackage *package, QCCPackageInstallState state, NSError *error) {
                    NSLog(@"Install package: %@ state: %lu error:%@", package, (QCCPackageDownloadState)state, (error?: @"no"));
                    if (state == QCCPackageInstallStateSuccessFinish) {
                        installed++;
                        completion(total, installed, nil);
                    } else if (state == QCCPackageInstallStateFinishWithError)
                        completion(total, installed, [QCCError errorForCode:QCCErrorCodeCanNotInstallPackage]);
                    
                }];
            } else {
                installed++;
                completion(total, installed, nil);
            }
        }
    }
    
}

@end
