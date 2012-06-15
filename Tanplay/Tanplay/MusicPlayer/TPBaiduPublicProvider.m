//
//  TPBaiduPublicProvider.m
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPBaiduPublicProvider.h"
#import "NSObject+SBJson.h"

#define CHNANNELLIST_URL @"http://ting.baidu.com/data/fm/channelList?size=300&start=0&type=public"
#define SONGLIST_URL @"http://ting.baidu.com/data/fm/channel?id=%@&size=200&start=0"
#define SONGINFO_URL @"http://ting.baidu.com/data/music/songlink?songIds=%@&type=mp3"

MKNKErrorBlock errorCallback = ^(NSError *error)
{
    
};

@implementation TPBaiduSongInfo

@synthesize xcode, songID, songName, songURL, artistName, albumName, time, picURL;

@end


@implementation TPBaiduChannel

@synthesize channelID, channelName, songIDList;
@synthesize songInfoList;

@end

@implementation TPBaiduPublicProvider

@synthesize channelListViewController;
@synthesize channels;
@synthesize audioPlayer;
@synthesize playerViewController;
@synthesize playingChannel;
@synthesize playingAVPlayerItem;

-(id)init {
    self = [super init];
    if ( self ){
        _networkEngine = [[MKNetworkEngine alloc] initWithHostName:nil];
        self.channels = [[NSMutableArray alloc] init];
        
        self.audioPlayer = [[AVPlayer alloc] init];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        self.playerViewController = [[TPMusicPlayerViewController alloc] initWithNibName:@"TPMusicPlayerViewController" bundle:nil];
        self.playerViewController.dataSource = self;
        self.playerViewController.delegate = self;
    }  
    return self;
}

- (void)dealloc
{

}

+ (TPBaiduPublicProvider *)sharedProvider
{
    static TPBaiduPublicProvider *provider = nil;
    
    @synchronized(self)
    {
        if(provider == nil)
        {
            provider = [[TPBaiduPublicProvider alloc] init];
        }
    }
    
    return provider;
}

- (void)setChannelData:(NSArray *)data
{
    [self.channels removeAllObjects];
    for (int i = 0; i < data.count; i++) {
        TPBaiduChannel *channel = [[TPBaiduChannel alloc] init];
        channel.channelID = [[data objectAtIndex:i] objectForKey:@"channelId"];
        channel.channelName = [[data objectAtIndex:i] objectForKey:@"channelName"];
        [self.channels addObject:channel];
    }
}

- (void)requestChannelList
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        str = [str stringByReplacingOccurrencesOfString:@"\"count\": ," withString:@""];
        NSDictionary *dict = [str JSONValue];
        if(dict == nil)
            return;
        [self setChannelData:[[[dict objectForKey:@"data"] objectAtIndex:0] objectForKey:@"channels"]];
        [self.channelListViewController.tableView reloadData];
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:CHNANNELLIST_URL];
    [op onCompletion:completionCallback onError:errorCallback];
    [_networkEngine enqueueOperation:op];
}

- (TPBaiduChannel *)channelByID:(NSString *)channelID
{
    for(TPBaiduChannel *channel in self.channels)
    {
        if([channel.channelID isEqualToString:channelID])
        {
            return channel;
        }
    }
    
    return nil;
}

- (void)setSongListData:(NSString *)xml byChannelID:(NSString *)channelID
{
    if(xml == nil)
        return;
    
    NSRange start = [xml rangeOfString:@"<songinfo><song_id>"];
    NSRange end = [xml rangeOfString:@"</root>"];
    
    NSRange range = NSMakeRange(start.location, end.location - start.location);
    NSString *str = [xml substringWithRange:range];
    str = [str stringByReplacingOccurrencesOfString:@"<songinfo><song_id>" withString:@""];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@"</song_id></songinfo>\r\n"]];
    [array removeLastObject];
    
    TPBaiduChannel *channel = [self channelByID:channelID];
    if(!channel)
        return;
    channel.songIDList = array;    
    
    // initialize song infomation list

    NSMutableArray *songInfoList = [[NSMutableArray alloc] initWithCapacity:array.count];
    for(int i = 0; i < array.count; i++)
    {
        TPBaiduSongInfo *song = [[TPBaiduSongInfo alloc] init];
        song.songID = [array objectAtIndex:i];
        [songInfoList addObject:song];
    }    
    [self channelByID:channelID].songInfoList = songInfoList;
}

- (void)requestSongListByChannelID:(NSString *)channelID
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        [self setSongListData:str byChannelID:channelID];
        [self.channelListViewController presentModalViewController:self.playerViewController animated:YES];
        [self.playerViewController reloadData]; 
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:[NSString stringWithFormat:SONGLIST_URL, channelID]];
    [op onCompletion:completionCallback onError:errorCallback];
    [_networkEngine enqueueOperation:op];    
}

- (TPBaiduSongInfo *)getSongInfoBySongID:(NSString *)songID
{
    TPBaiduChannel *channel = self.playingChannel;
    for(int i = 0; i < channel.songInfoList.count; i++)
    {
        TPBaiduSongInfo *songInfo = [channel.songInfoList objectAtIndex:i];
        if([songInfo.songID isEqualToString:songID])
        {
            return songInfo;
        }
    }
    NSLog(@"can not find the song in playing channel");
    return nil;
}

- (void)playSongBySongInfo:(TPBaiduSongInfo *)song
{
    NSString *strURL = [NSString stringWithFormat:@"%@?xcode=%@", song.songURL, song.xcode];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:strURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    self.playingAVPlayerItem = playerItem;
    [self.playerViewController updateUIForCurrentTrack];
}

- (void)requestSongInfoBySongID:(NSString *)songID
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSDictionary *dict = [completedOperation responseJSON];
        
        TPBaiduSongInfo *song = [self getSongInfoBySongID:songID];
        if(!song)
        {
            return;
        }
        
        song.xcode = [[dict objectForKey:@"data"] objectForKey:@"xcode"];
        NSArray *songs = [[dict objectForKey:@"data"] objectForKey:@"songList"];
        song.songName = [[songs objectAtIndex:0] objectForKey:@"songName"];
        song.songURL =  [[songs objectAtIndex:0] objectForKey:@"songLink"]; 
        song.albumName = [[songs objectAtIndex:0] objectForKey:@"albumName"];
        song.artistName = [[songs objectAtIndex:0] objectForKey:@"artistName"]; 
        NSString *picURL = [[songs objectAtIndex:0] objectForKey:@"songPicRadio"]; 
        picURL = [@"http:" stringByAppendingString:picURL];
        song.picURL = picURL;
        song.time = [[[songs objectAtIndex:0] objectForKey:@"time"] intValue]; 
        
        [self playSongBySongInfo:song];
    };
    
    TPBaiduSongInfo *song = [self getSongInfoBySongID:songID];
    if(!song)
    {
        return;
    }
    
    if(song.songURL == nil || song.xcode == nil)
    {
        NSString *url = [NSString stringWithFormat:SONGINFO_URL, songID];
        MKNetworkOperation *op = [_networkEngine operationWithURLString:url];
        [op onCompletion:completionCallback onError:errorCallback];
        [_networkEngine enqueueOperation:op]; 
    }
    else
    {
        [self playSongBySongInfo:song];       
    }
}

- (void)playChannel:(TPBaiduChannel *)channel
{
    [self requestSongListByChannelID:channel.channelID];
    self.playingChannel = channel;
}

- (void)setChannelListViewController:(TPChannelListViewController *)_channelListViewController
{
    channelListViewController = _channelListViewController;
    [self requestChannelList];
}

- (void)showPlayerView:(UIViewController *)from
{
    [from presentViewController:self.playerViewController animated:YES completion:nil]; 
}

#pragma mark Delegate Methods ( Used to control the music player )

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPBaiduSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).albumName;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPBaiduSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).artistName;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPBaiduSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).songName;
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
    return self.playingChannel.songIDList.count;
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock {
    
    assert(trackNumber < self.playingChannel.songInfoList.count);
    TPBaiduSongInfo *song = (TPBaiduSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber];
    
    if(song == nil)
    {
        receivingBlock(nil, nil);
        return;
    }
    
    MKNKImageBlock imageCallback = ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) 
    {
        if (isInCache) 
        {
            receivingBlock(fetchedImage, nil);
        } 
        else 
        {
            receivingBlock(fetchedImage, nil);
        }
    };
    
    [_networkEngine imageAtURL:[NSURL URLWithString:song.picURL] onCompletion:imageCallback];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    
    NSString *songID = [self.playingChannel.songIDList objectAtIndex:track];
    if(songID == nil)
        return;
    
    [self requestSongInfoBySongID:songID];
    
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

@end
