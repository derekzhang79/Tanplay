//
//  TPSongDownloader.h
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"
#import "FileUtil.h"

@interface TPSongDownloader : MKNetworkEngine

- (MKNetworkOperation*)downloadFileFrom:(NSString*) remoteURL toFile:(NSString*) fileName;

@end
