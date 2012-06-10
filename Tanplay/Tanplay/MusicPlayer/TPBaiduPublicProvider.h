//
//  TPBaiduPublicProvider.h
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPMusicPlayerViewController.h"
#import "TPChannelListViewController.h"
#import "MKNetworkKit.h"

@interface TPBaiduPublicProvider : NSObject //<TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    MKNetworkEngine *_networkEngine;
}

@property (nonatomic, assign) TPChannelListViewController *channelListViewController;

+ (TPBaiduPublicProvider *)sharedProvider;
- (void)requestChannelList;

@end
