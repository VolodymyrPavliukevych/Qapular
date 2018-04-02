//
//  QCCFormater.m
//  QCCodeFormatKit
//
//  Created by Volodymyr Pavliukevych 2014.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "QCCFormater.h"
#pragma clang diagnostic ignored "-Wshorten-64-to-32"

#define __STDC_CONSTANT_MACROS 
#define __STDC_LIMIT_MACROS

#include "clang/Tooling/Core/Replacement.h"
#include "clang/Format/Format.h"
#include "llvm/Support/FileSystem.h"
#include "clang/Basic/FileSystemOptions.h"
#include "clang/Basic/FileManager.h"
#include "clang/Basic/Diagnostic.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Basic/SourceManager.h"
#include "clang/Rewrite/Core/Rewriter.h"

using namespace llvm;
using namespace clang;
using namespace tooling;

@implementation QCCFormater

static FileID createInMemoryFile(StringRef FileName, MemoryBuffer *Source, SourceManager &Sources, FileManager &Files) {
    const FileEntry *Entry = Files.getVirtualFile(FileName == "-" ? "<stdin>" : FileName, Source->getBufferSize(), 0);
    Sources.overrideFileContents(Entry, Source, true);
    return Sources.createFileID(Entry, SourceLocation (), SrcMgr::C_User);
}

static bool fillRanges(SourceManager &Sources,
                       FileID ID,
                       const MemoryBuffer *Code,
                       std::vector<CharSourceRange> &Ranges) {
    
    std::vector<unsigned> Offsets, Lengths;
    
    if (Offsets.empty())
        Offsets.push_back (0);
    
    if (Offsets.size () != Lengths.size() && !(Offsets.size() == 1 && Lengths.empty())) {
        llvm::errs() << "error: number of -offset and -length arguments must match.\n";
        return false;
    }
    
    for (unsigned i = 0, e = Offsets.size(); i != e; ++i) {
        
        if (Offsets[i] >= Code->getBufferSize ()) {
            llvm::errs() << "error: offset " << Offsets[i] << " is outside the file\n";
            return false;
        }
        
        SourceLocation Start = Sources.getLocForStartOfFile (ID).getLocWithOffset (Offsets[i]);
        SourceLocation End;
        if (i < Lengths.size ()) {
            if (Offsets[i] + Lengths[i] > Code->getBufferSize ()) {
                llvm::errs() << "error: invalid length " << Lengths[i] << ", offset + length (" << Offsets[i] + Lengths[i] << ") is outside the file.\n";
                return false;
            }
            End = Start.getLocWithOffset (Lengths[i]);
        }
        else {
            End = Sources.getLocForEndOfFile (ID);
        }
        Ranges.push_back (CharSourceRange::getCharRange (Start, End));
    }
    return true;
}

std::string getFileStyle (const std::string &fullPath) {
    using namespace clang::format;
    FormatStyle formatStyle = format::getNoStyle ();
    formatStyle.Language = FormatStyle::LK_Cpp; // For now we're parsing only Cpp
    return format::configurationAsText (format::getStyle("File", fullPath, "LLVM"));
}


+ (std::string) styleConfiguration:(CodeStyle) style {

    switch (style) {
        case CodeStyleLLVM:
            return format::configurationAsText(format::getLLVMStyle());
        
        case CodeStyleGoogle:
            return format::configurationAsText(format::getGoogleStyle(format::FormatStyle::LK_Cpp));
            
        case CodeStyleChromium:
            return format::configurationAsText(format::getChromiumStyle (format::FormatStyle::LK_Cpp));
            
        case CodeStyleMozilla:
            return format::configurationAsText(format::getMozillaStyle());
            
        case CodeStyleWebKit:
            return format::configurationAsText(format::getWebKitStyle());
            
        case CodeStyleGNU:
            return format::configurationAsText(format::getGNUStyle());
            
        default:
            return format::configurationAsText(format::getNoStyle());
    }
}

+ (NSString *) formatCodeString:(NSString *) codeNSString withStyleFormat:(CodeStyle) style {
    if (!codeNSString || codeNSString.length == 0)
        return nil;
    
    using namespace clang::format;
    StringRef stringRef = StringRef([codeNSString cStringUsingEncoding:NSUTF8StringEncoding], codeNSString.length);
    
    FileManager Files ((FileSystemOptions ()));
    DiagnosticsEngine Diagnostics (IntrusiveRefCntPtr<DiagnosticIDs> (new DiagnosticIDs), new DiagnosticOptions);
    
    SourceManager Sources (Diagnostics, Files);
    ErrorOr<std::unique_ptr<MemoryBuffer>> CodeOrErr = MemoryBuffer::getMemBuffer(stringRef);
    
    if (std::error_code EC = CodeOrErr.getError()) {
        llvm::errs () << EC.message () << "\n";
    }
    
    std::unique_ptr<llvm::MemoryBuffer> Code = std::move(CodeOrErr.get());
    if (Code->getBufferSize() == 0) {
        printf("Empty files are formatted correctly.");
        return nil;
    }
    
    FileID fileID = createInMemoryFile("-", Code.get(), Sources, Files);
    std::vector<CharSourceRange> Ranges;
    if (!fillRanges(Sources, fileID, Code.get(), Ranges)) {
        printf("Can't fill ranges correctly.");
        return nil;
    }
    
    FormatStyle formatStyle = format::getNoStyle();
    formatStyle.Language = FormatStyle::LK_Cpp; // For now we're parsing only Cpp
   
    std::string configurationStyle = [self styleConfiguration:style];
    
    std::error_code err = parseConfiguration(configurationStyle, &formatStyle);
    if (err.value()) {
        printf("%s", err.message().c_str());
    }
    
    tooling::Replacements Replaces = reformat(formatStyle, Sources, fileID, Ranges);
    
    clang::Rewriter Rewrite(Sources, LangOptions());
    tooling::applyAllReplacements (Replaces, Rewrite);
    
    auto &buf = Rewrite.getEditBuffer(fileID);
    
    std::string resultString = {buf.begin (), buf.end ()};
    
    return [NSString stringWithCString:resultString.c_str() encoding:NSUTF8StringEncoding];
}

+ (NSString *) formatCodeString:(NSString *) codeNSString {
    return [self formatCodeString:codeNSString withStyleFormat:CodeStyleGoogle];
}



@end
