//
//  CKTranslationUnit.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "CKTranslationUnit.h"
#import "CKIndex.h"
#import "CKToken.h"
#import "CKCursor.h"
#import "CKDiagnostic.h"


@interface CKCursor(Private) {

}
- (id)initWithCXCursor: (CXCursor)cursor;

@end

@interface CKTranslationUnit() {

    struct CXUnsavedFile    *_unsavedFiles;
    unsigned int            _unsavedFilesCount;
    NSFileManager           *_fileManager;
    
    NSUInteger              _length;

    NSString                *_path;
    NSArray                 *_tokens;
    NSArray                 *_diagnostics;
    void                    *_tokensPointer;
    
    NSMutableDictionary     *_rangedTokensPointer;
}

@end


@implementation CKTranslationUnit


NSString *const CKTranslationUnitUnSavedFilenameKey     =   @"CKTranslationUnitUnSavedFilename";
NSString *const CKTranslationUnitUnSavedContentKey      =   @"CKTranslationUnitUnSavedContent";

NSString *const CKTranslationUnitTokensPointerKey       =   @"CKTranslationUnitTokensPointer";
NSString *const CKTranslationUnitTokensCountKey         =   @"CKTranslationUnitTokensCount";


- (id) initWithFilePath:(NSString *) path fileContent:(NSString *) content unSavedFiles:(NSArray *) files index:(CKIndex *) index args:(NSArray *) args {
    
    self = [self init];
    
    if(self) {
        _lock  = [NSLock new];
        _rangedTokensPointer = [NSMutableDictionary new];
        _path = path;
        _index = (index ? index : [CKIndex new]);
        
        if (content.length == 0 && ![self availableFileWithPath:_path]){
            NSLog(@"Can't create TranslationUnit check: %@ file with content lenght:%lu", _path, content.length);
            return nil;
        }
        
        if([args count] == 0) {
            NSLog(@"Can't create TranslationUnit check args.");
            return nil;
            
        }else {
            _args = (char **)calloc(sizeof(char *), [args count]);
            
            if(_args == NULL) {
                NSLog(@"Error: Can't `calloc` arguments for clang.");
                return nil;
            }
            
            int i = 0;
            for (NSString *argString in args) {
                _args[i] = calloc(sizeof(char), argString.length + 1);
                if (!_args[i]) {
                    NSLog(@"Error: Can't allocate arg %i from arguments string: %@", i, argString);
                    return nil;
                }
                strlcpy((char *)_args[i], [argString UTF8String], argString.length + 1);
                i++;
            }
            _numArgs = i;
        }
        
        _unsavedFilesCount = (unsigned int) [files count] + (content.length == 0 ? 0 : 1 );

        _unsavedFiles = calloc(sizeof(struct CXUnsavedFile), _unsavedFilesCount);
        
        if(_unsavedFiles == NULL) {
            NSLog(@"Error: can't allocate CXUnsavedFile array.");
            return nil;
        }

        int idx = 0;
        
        // Set main file to unsaved array as first index
        if (content.length != 0) {
            
            _unsavedFiles[idx].Filename = _path.fileSystemRepresentation;
            _unsavedFiles[idx].Contents = content.UTF8String;
            _unsavedFiles[idx].Length   = content.length;
            _length = content.length;
            idx = 1;
        }else {
            NSError *readingFileError;
            NSString *fileContent = [NSString stringWithContentsOfFile:_path encoding:NSUTF8StringEncoding error:&readingFileError];
            if (!readingFileError) {
                _length = fileContent.length;
            }else
                NSLog(@"Bee carefully, it could be dangerous length = 0.");
        }
        
        for (NSDictionary *obj in files) {
            
            NSString *filePath = obj[CKTranslationUnitUnSavedFilenameKey];
            NSString *fileContent = obj[CKTranslationUnitUnSavedContentKey];
        
            _unsavedFiles[idx].Filename = filePath.fileSystemRepresentation;
            _unsavedFiles[idx].Contents = fileContent.UTF8String;
            _unsavedFiles[idx].Length   = fileContent.length;
            idx++;
        }
        
    
        unsigned options = clang_defaultEditingTranslationUnitOptions() | CXTranslationUnit_DetailedPreprocessingRecord | CXTranslationUnit_PrecompiledPreamble | CXTranslationUnit_CacheCompletionResults | CXTranslationUnit_Incomplete;
        
        
        int result = clang_parseTranslationUnit2(_index.cxIndex,
                                                 _path.fileSystemRepresentation,
                                                 (const char * const *)_args,
                                                 _numArgs,
                                                 _unsavedFiles,
                                                 _unsavedFilesCount,
                                                 options,
                                                 &_cxTranslationUnit
                                                 );
        
        NSError *error = [CKTranslationUnit errorWithID:result];
        if (error)
            NSLog(@"Error:%@", error);
        
        if(!_cxTranslationUnit) {
            return nil;
        }
    }
    
    CXFile cxFile = clang_getFile(_cxTranslationUnit, _path.fileSystemRepresentation);
    CXString fileName = clang_getFileName(cxFile);
    
    const char * fileNameCString = clang_getCString(fileName);
    
    if(fileNameCString != NULL) {
        _fileName = [[NSString alloc] initWithCString:fileNameCString encoding:NSUTF8StringEncoding];
        clang_disposeString(fileName);
    }
    
    
    return self;
}


- (NSArray *) includes {

    NSMutableArray *includes = [NSMutableArray new];
    
    return includes;
}

/*
 CXTranslationUnit_None — тут всё очевидно. Никаких специальных опций парсинга не устанавливается.
 CXTranslationUnit_DetailedPreprocessingRecord — установка этой опции указывает на то, что парсер должен будет генерировать детальную информацию о том, как и где в исходном тексте применяется препроцессор. Как явствует из документации, опция редкоиспользуемая, приводит к расходу большого количества памяти, и устанавливать её стоит только в тех случаях, когда такая информация действительно требуется.
 CXTranslationUnit_Incomplete — установка этой опции указывает на то, что обрабатывается не полная (не законченная) единица трансляции. Например, заголовочный файл. В этом случае транслятор не будет пытаться инстанцировать шаблоны, которые должны были бы быть инстанцированы перед завершением трансляции.
 CXTranslationUnit_PrecompiledPreamble — установка этой опции указывает на то, что парсер должен автоматически создавать precompiled header для всехзаголовочныхфайлов, которые включаются в начале единицы трансляции. Опция полезная в случае, если файл будет часто репарсится (посредством метода clang_reparseTranslationUnit), но со своими особенностями, которые будут описаны в следующем разделе.
 CXTranslationUnit_CacheCompletionResults — установка этой опции приводит к тому, что после каждого последующего репарсинга часть результатов code completion будет сохранятся.
 CXTranslationUnit_SkipFunctionBodies — установка этой опции приводит к тому, что в процессе трансляции не будут обрабатываться тела функций и методов. Полезно для быстрого поиска объявлений и определений тех или иных символов.
 
 -x language — указывает конкретный тип файла, который парсится. Совместима с аналогичной опцией компилятора gcc.
 -std=standard — указывает стандарт, которому соответствует исходный текст. По значениям совместима с аналогичной опцией компилятора gcc.
 -ferror-limit=N — устанавливает в N максимальное количество ошибок, после которого парсинг будет завершен. Если требуется распарсить файл полностью игнорируя любые ошибки, то N должно быть равно 0.
 -include <prefix-file> — указывает файл (обычно заголовочный) который должен быть распарсен до начала парсинга основного файла. Вообще, эта опция изначально предназначена для подключения PCH-заголовка, но при разборе файлов может быть полезна для, например, определения различных макросов.
 */



- (NSError *) reparseUnitWithUnSavedFiles:(NSArray *) files {
    
    NSError *error;
    if (_cxTranslationUnit == NULL)
        return [CKTranslationUnit errorWithID:CKTranslationUnitErrorIsNil];
    
    [self disposeAllTokens];

    
    _diagnostics = nil;
    
    if ([files count] > 0)
        _unsavedFiles = calloc(sizeof(struct CXUnsavedFile), [files count]);

    int idx = 0;
    for (NSDictionary *obj in files) {
        
        NSString *filePath = obj[CKTranslationUnitUnSavedFilenameKey];
        NSString *fileContent = obj[CKTranslationUnitUnSavedContentKey];
        
        if ([_path isEqualToString:filePath])
            _length = fileContent.length;
        
        _unsavedFiles[idx].Filename = filePath.fileSystemRepresentation;
        _unsavedFiles[idx].Contents = fileContent.UTF8String;
        _unsavedFiles[idx].Length   = fileContent.length;
        idx++;
    }
    
    

    //unsigned options = clang_defaultEditingTranslationUnitOptions() | CXTranslationUnit_DetailedPreprocessingRecord | CXTranslationUnit_PrecompiledPreamble | CXTranslationUnit_CacheCompletionResults | CXTranslationUnit_Incomplete;


    unsigned options = clang_defaultReparseOptions(_cxTranslationUnit) |
                                                    CXTranslationUnit_DetailedPreprocessingRecord |
                                                    CXTranslationUnit_PrecompiledPreamble |
                                                    CXTranslationUnit_CacheCompletionResults |
                                                    CXTranslationUnit_Incomplete;

    
    int result = clang_reparseTranslationUnit(_cxTranslationUnit,
                                              (unsigned) [files count],
                                              _unsavedFiles,
                                              options);
    
    error = [CKTranslationUnit errorWithID:result];
    
    return error;
}


- (CXFile) cxFile {
    CXFile cxFile = clang_getFile(_cxTranslationUnit, _path.fileSystemRepresentation);
    return cxFile;
}

#pragma mark - Helpers
- (NSUInteger) fileLength {
    return _length;
}

- (BOOL) availableFileWithPath:(NSString *) path {
    
    if (!_fileManager)
        _fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    if (![_fileManager fileExistsAtPath:path isDirectory:&isDirectory])
        return NO;
    
    NSError *readingFileError;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&readingFileError];
    
    if(content.length == 0 || readingFileError) {
        NSLog(@"Error: can't get source code from file:%@.", path);
        return NO;
    }
    
    return YES;
    
}


+ (NSError *) errorWithID:(int) errorID {
    NSString *description;
    
    switch (errorID) {
        case CXError_Success:
            return nil;
            break;

        case CXError_Failure:
            description = @"A generic error code, no further details are available. Errors of this kind can get their own specific error codes in future libclang versions.";
            break;
        case CXError_Crashed:
            
            description = @"Libclang crashed while performing the requested operation.";
            break;
            
        case CXError_InvalidArguments:
            description = @"The function detected that the arguments violate the function contract.";
            break;
            
        case CXError_ASTReadError:
            description = @"An AST deserialization error has occurred.";
            break;
            
        case CKTranslationUnitErrorIsNil:
            description = @"Translation Unit is nil.";
            
        default:
            description = @"Unknown error.";
            break;
    }
    
    
    NSError *error = [[NSError alloc] initWithDomain:@"com.qapular.ClangKit" code:errorID userInfo:@{@"description": description}];
    
    return error;
    
}


#pragma mark Tokens & Diagnostics
- (NSArray *) diagnostics {

    if (!_diagnostics)
        _diagnostics = [CKDiagnostic diagnosticsForTranslationUnit:self];
    
    return _diagnostics;
}


- (NSArray *)tokens {
    @synchronized(self) {
        if(!_tokens) {
            [_lock lock];
            _tokens = [CKToken tokensForTranslationUnit:self tokens: &_tokensPointer];
            [_lock unlock];
        }
        
        return _tokens;
    }
}

- (void) disposeTokensForRange:(NSRange) range {
    NSDictionary *container = _rangedTokensPointer[NSStringFromRange(range)];
    if (!container)
        return;
    
    NSValue *pointerValue = container[CKTranslationUnitTokensPointerKey];
    unsigned int count = [container[CKTranslationUnitTokensCountKey] unsignedIntValue];
    clang_disposeTokens(_cxTranslationUnit, [pointerValue pointerValue], count);
}


- (void) disposeAllTokens {

    if(_tokens.count > 0) {
        clang_disposeTokens(_cxTranslationUnit, _tokensPointer, (unsigned int)_tokens.count);
        _tokensPointer = NULL;
    }
    
    for (NSDictionary *container in [_rangedTokensPointer allValues]) {
        NSValue *pointerValue = container[CKTranslationUnitTokensPointerKey];
        NSNumber *count = container[CKTranslationUnitTokensCountKey];
        if (count && [count unsignedIntegerValue] > 0)
            clang_disposeTokens(_cxTranslationUnit, [pointerValue pointerValue], [count unsignedIntValue]);
    }
    
    _tokens      = nil;
    [_rangedTokensPointer removeAllObjects];
    
}

- (NSArray *) tokensForRange:(NSRange) range {
    
    [self disposeTokensForRange:range];
    
    @synchronized(self) {
        [_lock lock];
        
        NSArray *tokens;
        void *tokenPointer;
        
        if (_length >= range.location + range.length) {
            tokens = [CKToken tokensForTranslationUnit:self forRange:range tokens:&tokenPointer];
            NSValue *pointer = [NSValue valueWithPointer:tokenPointer];
            
            if (pointer) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict[CKTranslationUnitTokensPointerKey] = pointer;
                dict[CKTranslationUnitTokensCountKey] = @([tokens count]);
                _rangedTokensPointer[NSStringFromRange(range)] = dict;
            }
        }
        
        [_lock unlock];
        
        return tokens;
    }
}





//- ( NSArray * )diagnostics {
//    @synchronized(self) {
//        if(_diagnostics == nil) {
//            [_lock lock];
//            
//            _diagnostics = [[CKDiagnostic diagnosticsForTranslationUnit:self] retain];
//            
//            [ _lock unlock ];
//        }
//        
//        return _diagnostics;
//    }
//}



#pragma mark Dealloc
- (void) dealloc {

    [self disposeAllTokens];
    
    clang_disposeTranslationUnit( _cxTranslationUnit );
    
    for(int i = 0; i < _numArgs; i++) {
        free( _args[i]);
    }
    
    free((void *)_args);
    free(_unsavedFiles);

}


@end
