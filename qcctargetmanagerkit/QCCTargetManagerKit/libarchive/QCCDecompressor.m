//
//  QCCDecompressor.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCDecompressor.h"
#import "archive.h"
#import "archive_entry.h"

typedef enum : int {
    ExtractResultUnknown,
    ExtractResultSuccess,
    ExtractResultFailCanNotReadDataBlock,
    ExtractResultFailCanNotWriteDataBlock,
    ExtractResultFailCanNotOpenSourceFile,
    ExtractResultFailCanNotReadNextHeaderWithWarnong,
    ExtractResultFailCanNotReadNextHeaderWithError,
    ExtractResultFailCanNotWriteEntryWithWarning,
    ExtractResultFailCanNotWriteEntryWithError
} ExtractResult;

typedef enum : int {
    ExtractDebugNo,
    ExtractDebugWarning,
    ExtractDebugFull,
} ExtractDebug;

static const size_t reading_block_size = 10240;
/*
 static const size_t path_max_size = 512;
*/

@implementation QCCDecompressor

static void errmsg(const char *message) {
    if (message == NULL) {
        message = "Error: No error description provided.\n";
    }
    write(2, message, strlen(message));
}

static ExtractResult copy_data(struct archive *ar, struct archive *aw) {
    int read_result;
    long write_result;
    const void *buff;
    size_t size;
    int64_t offset;
    
    for (;;) {
        read_result = archive_read_data_block(ar, &buff, &size, &offset);
        if (read_result == ARCHIVE_EOF)
            return ExtractResultSuccess;
        
        if (read_result != ARCHIVE_OK)
            return ExtractResultFailCanNotReadDataBlock;
        
        write_result = archive_write_data_block(aw, buff, size, offset);
        
        if (write_result != ARCHIVE_OK) {
            errmsg(archive_error_string(ar));
            return ExtractResultFailCanNotWriteDataBlock;
        }
    }
}


static ExtractResult extract(const char *filename, const char * destinationFolder, ExtractDebug debugLevel) {

    // Go to destination
    chdir(destinationFolder);
    
    struct archive *origin_archive;
    struct archive *extracting_archive_disk;
    struct archive_entry *entry;
    int flags;
    int result;
    
    /* Select which attributes we want to restore. */
    flags = ARCHIVE_EXTRACT_ACL;
    flags |= ARCHIVE_EXTRACT_PERM;
    flags |= ARCHIVE_EXTRACT_FFLAGS;
    flags |= ARCHIVE_EXTRACT_TIME;
    
    origin_archive = archive_read_new();
    archive_read_support_format_all(origin_archive);
    archive_read_support_compression_all(origin_archive);
    
    extracting_archive_disk = archive_write_disk_new();
    archive_write_disk_set_options(extracting_archive_disk, flags);
    archive_write_disk_set_standard_lookup(extracting_archive_disk);
    
    if ((result = archive_read_open_filename(origin_archive, filename, reading_block_size)))
        return ExtractResultFailCanNotOpenSourceFile;
        
    for (;;) {
        result = archive_read_next_header(origin_archive, &entry);
        
        const char	* destination_file_name = archive_entry_pathname(entry);
        size_t size = archive_entry_size(entry);
        
        if (debugLevel == ExtractDebugFull)
            printf("%s %zu b.\n", destination_file_name, size);
        
        if (result == ARCHIVE_EOF)
            break;

        if (result < ARCHIVE_OK && debugLevel > ExtractDebugNo)
            fprintf(stderr, "%s\n", archive_error_string(origin_archive));

        if (result < ARCHIVE_WARN)
            return ExtractResultFailCanNotReadNextHeaderWithError;
        
        /*
         char destinationPath[path_max_size];
         
         strcpy(destinationPath, destinationFolder);
         strcat(destinationPath, "/");
         strcat(destinationPath, destination_file_name);
         
         archive_entry_set_pathname(entry, destinationPath);
         */
        
        result = archive_write_header(extracting_archive_disk, entry);
        if (result < ARCHIVE_OK) {
            
            if (debugLevel > ExtractDebugNo)
                fprintf(stderr, "%s\n", archive_error_string(extracting_archive_disk));
            
        } else if (archive_entry_size(entry) > 0) {
            
            ExtractResult copy_result = copy_data(origin_archive, extracting_archive_disk);
            if (copy_result != ExtractResultSuccess)
                return copy_result;
            
        }
        
        result = archive_write_finish_entry(extracting_archive_disk);
        
        if (result < ARCHIVE_OK && debugLevel > ExtractDebugNo)
            fprintf(stderr, "%s\n", archive_error_string(extracting_archive_disk));
        
        if (result < ARCHIVE_WARN)
            return ExtractResultFailCanNotWriteEntryWithError;
        
    }
    
    archive_read_close(origin_archive);
    archive_read_free(origin_archive);

    return ExtractResultSuccess;

}

+(BOOL) decompressFileAtURL:(NSURL *) url destinationURL:(NSURL *) destination {

    if (!url || !destination)
        return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *destinationPath = destination.path;
    NSError *error;
    
    if (![fileManager fileExistsAtPath:destinationPath])
        if([fileManager createDirectoryAtURL:destination withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error);
            return NO;
        }
    
    
    ExtractResult result =  extract(url.fileSystemRepresentation, [destinationPath UTF8String], ExtractDebugWarning);
    if (result != ExtractResultSuccess)
        return NO;
    
    return YES;
}


@end
