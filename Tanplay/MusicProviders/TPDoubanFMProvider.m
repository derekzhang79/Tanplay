//
//  TPDoubanFMProvider.m
//  Tanplay
//
//  Created by 胡 蓉 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPDoubanFMProvider.h"
#import "TPDownloadSongsProvider.h"
#import "SBJson.h"

#define CHNANNELLIST_URL @"http://www.douban.com/j/app/radio/channels"
#define SONGLIST_URL @"http://douban.fm/j/mine/playlist?type=n&h=&channel=%@&r=915fbad1d5"

MKNKErrorBlock doubanErrorCallback = ^(NSError *error)
{
    
};

@implementation TPDoubanSongInfo

@synthesize picture, albumtitle, artist, url, title, length, sid;

@end


@implementation TPDoubanChannel

@synthesize channelID, channelName, songInfoList;

@end

@implementation TPDoubanFMProvider

@synthesize channels;
@synthesize channelListViewController;
@synthesize audioPlayer;
@synthesize playerViewController;
@synthesize playingChannel;
@synthesize playingAVPlayerItem;
@synthesize playginSongInfo;

-(id)init {
    self = [super init];
    if ( self ){
        _networkEngine = [[MKNetworkEngine alloc] initWithHostName:nil];
        self.channels = [[NSMutableArray alloc] init];
        
        self.audioPlayer = [AVPlayer sharedAVPlayer];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        self.playerViewController = [TPMusicPlayerViewController sharedMusicPlayerViewController];
    }  
    return self;
}

+ (TPDoubanFMProvider *)sharedProvider
{
    static TPDoubanFMProvider *provider = nil;
    
    @synchronized(self)
    {
        if(provider == nil)
        {
            provider = [[TPDoubanFMProvider alloc] init];
        }
    }
    
    return provider;
}

- (void)setChannelData:(NSArray *)data
{
    [self.channels removeAllObjects];
    for (int i = 0; i < data.count; i++) {
        TPDoubanChannel *channel = [[TPDoubanChannel alloc] init];
        channel.channelID = [[[data objectAtIndex:i] objectForKey:@"channel_id"] stringValue];
        channel.channelName = [[data objectAtIndex:i] objectForKey:@"name"];
        [self.channels addObject:channel];
    }
}

- (void)showPlayerView:(UIViewController *)from
{
    [from presentViewController:self.playerViewController animated:YES completion:nil]; 
}

- (void)requestChannelList
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        [completedOperation JSONRepresentation];
        NSDictionary *dict = [str JSONValue];
        if(dict == nil)
            return;
        [self setChannelData:[dict objectForKey:@"channels"]];
        [self.channelListViewController.tableView reloadData];
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:CHNANNELLIST_URL];
    [op onCompletion:completionCallback onError:doubanErrorCallback];
    [_networkEngine enqueueOperation:op];
}

- (void)setChannelListViewController:(TPChannelListViewController *)_channelListViewController
{
    channelListViewController = _channelListViewController;
    [self requestChannelList];
}

- (TPDoubanChannel *)channelByID:(NSString *)channelID
{
    for(TPDoubanChannel *channel in self.channels)
    {
        if([channel.channelID isEqualToString:channelID])
        {
            return channel;
        }
    }    
    return nil;
}

- (void)setSongListData:(NSArray *)songs byChannelID:(NSString *)channelID
{
    TPDoubanChannel *channel = [self channelByID:channelID];
    if(channel == nil)
        return;
    
    NSMutableArray *songInfoList = [[NSMutableArray alloc] initWithCapacity:songs.count];
    for(int i = 0; i < songs.count; i++)
    {
        NSDictionary *dict = [songs objectAtIndex:i];
        TPDoubanSongInfo *song = [[TPDoubanSongInfo alloc] init];
        song.picture = [dict objectForKey:@"picture"];
        song.albumtitle = [dict objectForKey:@"albumtitle"];
        song.artist = [dict objectForKey:@"artist"];
        song.url = [dict objectForKey:@"url"];
        song.title = [dict objectForKey:@"title"];
        song.length = [[dict objectForKey:@"length"] stringValue];
        song.sid = [dict objectForKey:@"sid"];
        
        [songInfoList addObject:song];
    }    
    channel.songInfoList = songInfoList;
}

- (void)requestSongListByChannelID:(NSString *)channelID
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        NSArray *songs = [str.JSONValue objectForKey:@"song"];
        if(songs == nil)
            return;
        [self setSongListData:songs byChannelID:channelID];
        [self.channelListViewController presentModalViewController:self.playerViewController animated:YES];
        [self.playerViewController reloadData]; 
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:[NSString stringWithFormat:SONGLIST_URL, channelID]];
    [op onCompletion:completionCallback onError:doubanErrorCallback];
    [_networkEngine enqueueOperation:op];    
}

- (void)playChannel:(NSInteger)channelIndex
{
    if(channelIndex < 0 || channelIndex >= self.channels.count)
        return;
    self.playerViewController.dataSource = self;
    self.playerViewController.delegate = self;
    self.playerViewController.isChannelMode = YES;
    TPDoubanChannel *channel = [self.channels objectAtIndex:channelIndex];
    [self requestSongListByChannelID:channel.channelID];
    self.playingChannel = channel;   
}

- (void)playSongBySongInfo:(TPDoubanSongInfo *)song
{
    NSString *strURL = song.url;
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:strURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    self.playingAVPlayerItem = playerItem;
    self.playginSongInfo = song;
    [self.playerViewController updateUIForCurrentTrack];
}

#pragma mark Delegate Methods ( Used to control the music player )

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPDoubanSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).albumtitle;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPDoubanSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).artist;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPDoubanSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).title;
}

-(CGFloat)musicPlayer:(TPMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    if(!playingAVPlayerItem)
    {
        return 10000;
    }
    else
    {
        CGFloat f = playingAVPlayerItem.duration.value / playingAVPlayerItem.duration.timescale;
        return f;
    }
}

-(NSUInteger)numberOfTracksInPlayer:(TPMusicPlayerViewController *)player
{
    return self.playingChannel.songInfoList.count;
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock {
    
    assert(trackNumber < self.playingChannel.songInfoList.count);
    TPDoubanSongInfo *song = (TPDoubanSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber];
    
    if(song == nil)
    {
        receivingBlock(nil, nil);
        return;
    }
    
    MKNKImageBlock imageCallback = ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) 
    {
        receivingBlock(fetchedImage, nil);
    };
    
    [_networkEngine imageAtURL:[NSURL URLWithString:song.picture] onCompletion:imageCallback];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    
    TPDoubanSongInfo *song = [self.playingChannel.songInfoList objectAtIndex:track];
    if(song == nil)
        return;
    
    [self playSongBySongInfo:song];
    
}

-(void)musicPlayerDidStartPlaying:(TPMusicPlayerViewController *)player {
    [self.audioPlayer play];
}

-(void)musicPlayerDidStopPlaying:(TPMusicPlayerViewController *)player {
    [self.audioPlayer pause];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    [[MPMusicPlayerController iPodMusicPlayer] setVolume:volume];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    CMTime time = CMTimeMake(position, 1);
    [self.audioPlayer seekToTime:time];
}

-(void)musicPlayerActionRequested:(TPMusicPlayerViewController *)musicPlayer {
    
}

-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)musicPlayer {
    
    [musicPlayer dismissViewControllerAnimated:YES completion:nil];   
}

- (BOOL)musicPlayerDownloadRequested:(TPMusicPlayerViewController *)musicPlaer
{
    return [[TPDownloadSongsProvider sharedProvider] addDownloadTask:self.playginSongInfo.url
                                                                name:self.playginSongInfo.title
                                                              artist:self.playginSongInfo.artist
                                                               album:self.playginSongInfo.albumtitle];
}

@end
