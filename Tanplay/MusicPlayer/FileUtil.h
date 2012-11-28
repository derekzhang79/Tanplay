
//
//  FileUtil.h
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  
//

#pragma once
#import <Foundation/Foundation.h>


@interface FileUtil : NSObject {

}

typedef enum _PathType {
	PathTypeLibrary,
	PathTypeCaches,
	PathTypeDocument,
	PathTypeResource,
	PathTypeBundle,
	PathTypeTemp,
} PathType;

+ (NSString *)pathForDownloadSongs;

+ (NSString *)filePathForDownloadSongsPList;

+ (NSString*)pathForPathType:(PathType)type;

+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type;

+ (BOOL)fileExistsAtPath:(NSString*)path;

+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath;

+ (BOOL)deleteFileAtPath:(NSString*)path;

+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes;

+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr;

+ (NSData*)dataFromPath:(NSString*)path;

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path;

+ (unsigned long long int)sizeOfFolderPath:(NSString *)path;

+ (NSString *)md5OfString:(NSString *)str;

@end
