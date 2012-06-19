//
//  TPDoubanFMProvider.h
//  Tanplay
//
//  Created by 胡 蓉 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPChannelListViewController.h"
#import "MKNetworkKit.h"

@interface TPDoubanChannel : NSObject

@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSString *channelName;
//@property (nonatomic, strong) NSArray *songIDList;
//@property (nonatomic, strong) NSMutableArray *songInfoList;

@end

@interface TPDoubanFMProvider : NSObject
{
    MKNetworkEngine *_networkEngine;
}

@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, assign) TPChannelListViewController *channelListViewController;

+ (TPDoubanFMProvider *)sharedProvider;

@end
