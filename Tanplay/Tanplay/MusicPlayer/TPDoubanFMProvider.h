//
//  TPDoubanFMProvider.h
//  Tanplay
//
//  Created by 胡 蓉 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPChannelListViewController.h"
#import "TPMusicPlayerViewController.h"
#import "MKNetworkKit.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TPDoubanSongInfo : NSObject

@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *albumtitle;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *length;
@property (nonatomic, strong) NSString *sid;

@end

@interface TPDoubanChannel : NSObject
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSMutableArray *songInfoList;
@end

@interface TPDoubanFMProvider : NSObject <TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    MKNetworkEngine *_networkEngine;
}
@property (nonatomic, strong) AVPlayer* audioPlayer;
@property (nonatomic, strong) TPMusicPlayerViewController *playerViewController;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, assign) TPChannelListViewController *channelListViewController;
@property (nonatomic, assign) TPDoubanChannel *playingChannel;
@property (nonatomic, strong) AVPlayerItem *playingAVPlayerItem;

+ (TPDoubanFMProvider *)sharedProvider;
- (void)playChannel:(NSInteger)channelIndex;
- (void)showPlayerView:(UIViewController *)from;

@end
