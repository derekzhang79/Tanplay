//
//  TPXiamiFMProvider.h
//  Tanplay
//
//  Created by ding jie on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "TPChannelListViewController.h"
#import "TPMusicPlayerViewController.h"
#import "MKNetworkKit.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TPXiamiSongInfo : NSObject

@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *albumtitle;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sid;

@end

@interface TPXiamiChannel : NSObject
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSArray *songInfoList;
@end

@interface TPXiamiCategory : NSObject
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSArray *channelList;
@end

@interface TPXiamiFMProvider : NSObject <TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    MKNetworkEngine *_networkEngine;
}
@property (nonatomic, strong) AVPlayer* audioPlayer;
@property (nonatomic, strong) TPMusicPlayerViewController *playerViewController;
@property (nonatomic, assign) TPChannelListViewController *channelListViewController;
@property (nonatomic, assign) TPXiamiChannel *playingChannel;
@property (nonatomic, strong) AVPlayerItem *playingAVPlayerItem;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) TPXiamiSongInfo *playingSongInfo;

+ (TPXiamiFMProvider *)sharedProvider;
- (void)playChannel:(NSIndexPath *)indexPath;
- (void)showPlayerView:(UIViewController *)from;

@end
