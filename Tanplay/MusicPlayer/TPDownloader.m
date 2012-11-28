//
//  TPSongDownloader.m
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPDownloader.h"

@implementation TPSongDownloader

- (MKNetworkOperation*)downloadFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath {
    
    MKNetworkOperation *op = [self operationWithURLString:remoteURL 
                                                   params:nil
                                               httpMethod:@"GET"];
    DLog(@"%@", filePath);
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath
                                                            append:YES]];
    
    [self enqueueOperation:op];
    return op;
}

@end
