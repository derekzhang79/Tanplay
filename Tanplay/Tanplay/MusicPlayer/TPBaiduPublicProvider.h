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
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TPBaiduSongInfo : NSObject

@property (nonatomic, strong) NSString *xcode;
@property (nonatomic, strong) NSString *songID;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *songURL;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *picURL;
@property (nonatomic) NSInteger time;

@end

@interface TPBaiduChannel : NSObject

@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSArray *songIDList;
@property (nonatomic, strong) NSMutableArray *songInfoList;

@end

@interface TPBaiduPublicProvider : NSObject <TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    MKNetworkEngine *_networkEngine;
}

@property (nonatomic, strong) AVPlayer* audioPlayer;
@property (nonatomic, strong) TPMusicPlayerViewController *playerViewController;
@property (nonatomic, assign) TPChannelListViewController *channelListViewController;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, assign) TPBaiduChannel *playingChannel;
@property (nonatomic, strong) AVPlayerItem *playingAVPlayerItem;
@property (nonatomic, strong) TPBaiduSongInfo *playingSong;

+ (TPBaiduPublicProvider *)sharedProvider;
- (void)requestChannelList;
- (void)playChannel:(TPBaiduChannel *)channel;

@end
