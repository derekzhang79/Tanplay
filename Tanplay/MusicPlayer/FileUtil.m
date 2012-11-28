
//
//  FileUtil.h
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  
//

#import "FileUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FileUtil

#pragma mark -
#pragma mark file-related functions

+ (NSString*)pathForPathType:(PathType)type
{
	NSSearchPathDirectory directory;
	switch(type)
	{
		case PathTypeDocument:
			directory = NSDocumentDirectory;
			break;
		case PathTypeLibrary:
			directory = NSLibraryDirectory;
			break;
		case PathTypeCaches:
			directory = NSCachesDirectory;
			break;
		case PathTypeBundle:
			return [[NSBundle mainBundle] bundlePath];
			break;
		case PathTypeResource:
			return [[NSBundle mainBundle] resourcePath];
			break;
		case PathTypeTemp:
			return NSTemporaryDirectory();
			break;
		default:
			return nil;
	}
	NSArray* directories = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
	if(directories != nil && [directories count] > 0)
		return [directories objectAtIndex:0];
	return nil;
}

+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type
{
	return [[self pathForPathType:type] stringByAppendingPathComponent:filename];
}

+ (BOOL)fileExistsAtPath:(NSString*)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
	return [manager fileExistsAtPath:path];
}

+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath
{
	NSError* error;
    NSFileManager *manager = [NSFileManager defaultManager];
	BOOL result = [manager copyItemAtPath:srcPath toPath:dstPath error:&error];
    if (!result) {
        NSLog(@"Copy error:%@", [error localizedDescription]);
    }
    return result;
}

+ (BOOL)deleteFileAtPath:(NSString*)path
{
	NSError* error;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL result = [manager removeItemAtPath:path error:&error];
    if (!result) {
        NSLog(@"Delete error:%@", [error localizedDescription]);
    }
	return result;
}

+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes
{
	NSError* error;
    NSFileManager *manager = [NSFileManager defaultManager];
	BOOL result = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
    if (!result) {
        NSLog(@"Create dir error:%@", [error localizedDescription]);
    }
    return result;
}

+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr
{
    NSFileManager *manager = [NSFileManager defaultManager];
	return [manager createFileAtPath:path contents:data attributes:attr];
}

+ (NSData*)dataFromPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
	return [manager contentsAtPath:path];
}

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path
{
	NSError* error;
    NSFileManager *manager = [NSFileManager defaultManager];
	return [manager contentsOfDirectoryAtPath:path error:&error];
}

//referenced: http://stackoverflow.com/questions/2188469/calculate-the-size-of-a-folder
+ (unsigned long long int)sizeOfFolderPath:(NSString *)path
{
    unsigned long long int totalSize = 0;
    
    NSFileManager *manager = [NSFileManager defaultManager];
	NSEnumerator* enumerator = [[manager subpathsOfDirectoryAtPath:path error:nil] objectEnumerator];	
    NSString* fileName;
    while(fileName = [enumerator nextObject])
	{
		totalSize += [[manager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil] fileSize];
    }
	
    return totalSize;	
}

+ (NSString *)pathForDownloadSongs
{
    NSString *cachesPath = [self pathForPathType:PathTypeCaches];
    NSString *songsPath = [cachesPath stringByAppendingPathComponent:@"downloadedSongs"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isPathExists = [manager fileExistsAtPath:songsPath isDirectory:&isDir];
    if(!(isPathExists && isDir))
    {
        [self createDirectoryAtPath:songsPath withAttributes:nil];
    }
    
    return songsPath;
}

+ (NSString *)filePathForDownloadSongsPList
{
    NSString *filePath = [[FileUtil pathForDownloadSongs] stringByAppendingPathComponent:@"downloadSongs.plist"];
    if(![self fileExistsAtPath:filePath])
    {
        [self createFileAtPath:filePath withData:nil andAttributes:nil];
    }

    return filePath;
}

+(NSString *)md5OfString:(NSString *)str
{
	const char *cStr = [str UTF8String]; 
    unsigned char result[32]; 
    CC_MD5( cStr, strlen(cStr), result ); 
    NSString *retStr = [NSString stringWithFormat: 
						@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						result[0], result[1], result[2], result[3], 
						result[4], result[5], result[6], result[7], 
						result[8], result[9], result[10], result[11], 
						result[12], result[13], result[14], result[15]];
	return retStr;		
}

@end
