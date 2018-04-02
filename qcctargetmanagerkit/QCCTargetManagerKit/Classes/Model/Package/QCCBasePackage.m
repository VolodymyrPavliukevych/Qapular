//
//  QCCBasePackage.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCBasePackage.h"
#import "QCCDecompressor.h"

NSString *const QCCPackageNameKey = @"QCCPackageName";
NSString *const QCCPackageDescriptionKey = @"QCCPackageDescription";

NSString *const QCCPackageURLKey = @"QCCPackageURL";
NSString *const QCCPackageVersionKey = @"QCCPackageVersion";
NSString *const QCCPackageContentVersionKey = @"QCCPackageContentVersion";
NSString *const QCCPackageIdentifierKey = @"QCCPackageIdentifier";
NSString *const QCCPackageMD5HashKey = @"QCCPackageMD5Hash";

static char *const QCCBasePackageOperationQueue  = "QCCBasePackageOperationQueue";

static NSString *const QCCBasePackageStorageFolderName = @"packages";

static NSString *const QCCBasePackageInstallSuccessFileKey = @"positive";


@interface QCCBasePackage() <NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    
    NSMutableURLRequest     *_urlRequest;
    NSURLSession            *_downloadURLSession;
    NSURL                   *_downloadedFileURL;
    
    QCCPackageUnpackState   _unpackState;
    QCCPackageInstallState  _installState;
    QCCPackageDownloadState _downloadState;
    
    NSOperationQueue        *_downloadOperationQueue;
    
    dispatch_queue_t        _packageOperationQueue;
    NSURLSessionDownloadTask *_downloadTask;

}

@property (nonatomic, copy) void (^ installProgressBlock)(QCCBasePackage *, QCCPackageInstallState, NSError *);
@end

@implementation QCCBasePackage

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if (!dictionary)
        return nil;
    
    self = [super init];
    
    if (self) {
        
        _rawContentDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
        
        _name = dictionary[QCCPackageNameKey];
        _packageDescription = dictionary[QCCPackageDescriptionKey];
        
        _urlArray = dictionary[QCCPackageURLKey];
        _version = dictionary[QCCPackageVersionKey];
        _contentVersion = dictionary[QCCPackageContentVersionKey];
        _identifier = dictionary[QCCPackageIdentifierKey];
        _md5Hash = dictionary[QCCPackageMD5HashKey];
        _packageOperationQueue = dispatch_queue_create(QCCBasePackageOperationQueue, 0);
        
        if (!_urlArray || !_version || !_contentVersion || !_identifier || !_md5Hash)
            return nil;
    }
    
    return self;
    
}

-(BOOL)installWithStateBlock:(void (^)(QCCBasePackage *, QCCPackageInstallState, NSError *))progressBlock {

    if (_installState == QCCPackageInstallStateDownload || _installState == QCCPackageInstallStateUnpack)
        return NO;
    
    _installProgressBlock = progressBlock;
    
    [self installProgress:QCCPackageInstallStateDownload];
    
    return YES;
}

- (void) installProgress:(QCCPackageInstallState) state {
    _installState = state;
    
    switch (state) {
        case QCCPackageInstallStateUnknown:
            break;
            
        case QCCPackageInstallStateDownload:
            [self download];
            break;
            
        case QCCPackageInstallStateUnpack:
            [self unpack];
            break;
            
        case QCCPackageInstallStateFinishWithError: {
            NSError *error;
            if (_downloadedFileURL)
                [[NSFileManager defaultManager] removeItemAtURL:_downloadedFileURL error:&error];
        }
            break;
            
        case QCCPackageInstallStateSuccessFinish:{
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:_downloadedFileURL error:&error];
            
            NSString *positiveContent = _downloadTask.originalRequest.URL.absoluteString;
            NSData *positiveURLContent = [[NSData alloc] initWithBytes:[positiveContent UTF8String] length:positiveContent.length];
            NSString *positivePath = [[self packageFolder] stringByAppendingPathComponent:QCCBasePackageInstallSuccessFileKey];
            [positiveURLContent writeToFile:positivePath atomically:YES];
        }
            break;
    }
    

    if (_installState == QCCPackageInstallStateFinishWithError && _downloadTask.error && self.installProgressBlock)
        self.installProgressBlock(self, _installState, _downloadTask.error);
    
    else if (self.installProgressBlock)
        self.installProgressBlock(self, _installState, nil);
}

-(BOOL)isInstalled {
    NSString *positivePath = [[self packageFolder] stringByAppendingPathComponent:QCCBasePackageInstallSuccessFileKey];
    return [[NSFileManager defaultManager] fileExistsAtPath:positivePath];
}

- (NSString *) installedURLString {
    if (![self isInstalled])
        return nil;
    
    NSString *positivePath = [[self packageFolder] stringByAppendingPathComponent:QCCBasePackageInstallSuccessFileKey];
    NSURL *path = [[NSURL alloc] initFileURLWithPath:positivePath];
    NSData *content = [NSData dataWithContentsOfURL:path];
    if (!content)
        return nil;
    
    return [NSString stringWithUTF8String:[content bytes]];
}

-(BOOL)uninstall {
    return NO;
}

- (void) download {
    
    if (_downloadState == QCCPackageDownloadStateIsInProgress || (_downloadTask && _downloadTask.state == NSURLSessionTaskStateRunning))
        return;
    
    _downloadState = QCCPackageDownloadStateIsInProgress;
    
    if (!_downloadOperationQueue)
        _downloadOperationQueue = [NSOperationQueue new];
    
    NSURL *url = [[NSURL alloc] initWithString:[_urlArray firstObject]];
    if (!url) {
        [self installProgress:QCCPackageInstallStateFinishWithError];
        return;
    }
    _urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    _downloadURLSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:_downloadOperationQueue];
    _downloadTask = [_downloadURLSession downloadTaskWithRequest:_urlRequest];
    [_downloadTask resume];

}

- (void) unpack {
    if (self.unpackProgressBlock)
        self.unpackProgressBlock(QCCPackageUnpackStateIsInProgress);
    
    dispatch_async(_packageOperationQueue, ^{
        NSURL *destinationURL = [[NSURL alloc] initFileURLWithPath:[self packageFolder] isDirectory:YES];
        
        BOOL result = [QCCDecompressor decompressFileAtURL:_downloadedFileURL
                                            destinationURL:destinationURL];
        
        if (self.unpackProgressBlock) {
            if (result) {
                self.unpackProgressBlock(QCCPackageUnpackStateFinish);
                [self installProgress:QCCPackageInstallStateSuccessFinish];
            }
            else {
                self.unpackProgressBlock(QCCPackageUnpackStateError);
                [self installProgress:QCCPackageInstallStateFinishWithError];
            }
        }
    });
}

#pragma mark - NSURLSessionDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *) location {
    
    NSString *fileName = [location.path lastPathComponent];
    _downloadedFileURL = [[NSURL alloc] initFileURLWithPath:[[self packageFolder] stringByAppendingPathComponent:fileName]];
    NSError *error;
    
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:_downloadedFileURL error:&error]) {
        NSLog(@"%@", error);
    }
    
    
    _downloadState = QCCPackageDownloadStateFinish;
    
    if (self.downloadProgressBlock)
        self.downloadProgressBlock(QCCPackageDownloadStateFinish, nil, 1, 1);
    
    [self installProgress:QCCPackageInstallStateUnpack];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _downloadState = QCCPackageDownloadStateIsInProgress;
    if (self.downloadProgressBlock)
        self.downloadProgressBlock(QCCPackageDownloadStateIsInProgress, nil, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error)
        return;
    
    _downloadState = QCCPackageDownloadStateError;
    if (self.downloadProgressBlock)
        self.downloadProgressBlock(QCCPackageDownloadStateError, error, 1, 1);
    
    [self installProgress:QCCPackageInstallStateFinishWithError];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler {
    
    completionHandler(request);    
}

- (NSString *) packageFolder {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *packagePath = [[[self class] storageFolder] stringByAppendingPathComponent:_identifier];
    if (![fileManager fileExistsAtPath:packagePath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:packagePath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    return packagePath;
}

+ (NSString *) storageFolder {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    NSString *rootFolderPath = [[NSBundle mainBundle] pathForResource:@"Packages" ofType:@"bundle"];
    
    if (![fileManager fileExistsAtPath:rootFolderPath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    return rootFolderPath;
}

@end
