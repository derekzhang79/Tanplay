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

@synthesize xcode, songID, songName, songURL;

@end


@implementation TPBaiduChannel

@synthesize channelID, channelName, songIDList, songInfoList;

@end

@implementation TPBaiduPublicProvider

@synthesize channelListViewController;
@synthesize channels;
@synthesize audioPlayer;
@synthesize playerViewController;
@synthesize playingChannel;
@synthesize playingTrack;

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
    [self channelByID:channelID].songIDList = array;    
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

- (void)requestSongInfoBySongID:(NSString *)songID
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSDictionary *dict = [completedOperation responseJSON];
        TPBaiduSongInfo *song = [[TPBaiduSongInfo alloc] init];
        song.xcode = [[dict objectForKey:@"data"] objectForKey:@"xcode"];
        NSArray *songs = [[dict objectForKey:@"data"] objectForKey:@"songList"];
        song.songName = [[songs objectAtIndex:0] objectForKey:@"songName"];
        song.songID = songID;
        song.songURL =  [[songs objectAtIndex:0] objectForKey:@"songLink"];        
        [self.playingChannel.songInfoList addObject:song];
        
        NSString *strURL = [NSString stringWithFormat:@"%@?xcode=%@", song.songURL, song.xcode];
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:strURL]];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    };
    
    NSString *url = [NSString stringWithFormat:SONGINFO_URL, songID];
    MKNetworkOperation *op = [_networkEngine operationWithURLString:url];
    [op onCompletion:completionCallback onError:errorCallback];
    [_networkEngine enqueueOperation:op]; 
}

- (void)playChannel:(TPBaiduChannel *)channel
{
    [self requestSongListByChannelID:channel.channelID];
    self.playingChannel = channel;
    //[self.channelListViewController presentModalViewController:self.playerViewController animated:YES];
    //[self.playerViewController reloadData]; 
    //[self.playerViewController playTrack:0 atPosition:0 volume:0];
}

- (void)setChannelListViewController:(TPChannelListViewController *)_channelListViewController
{
    channelListViewController = _channelListViewController;
    [self requestChannelList];
}

#pragma mark Delegate Methods ( Used to control the music player )

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    return self.playingChannel.channelName;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [item valueForProperty:MPMediaItemPropertyArtist];
    return nil;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [item valueForProperty:MPMediaItemPropertyTitle];
    return nil;
}

-(CGFloat)musicPlayer:(TPMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    return 0;
}

-(NSUInteger)numberOfTracksInPlayer:(TPMusicPlayerViewController *)player
{
    return self.playingChannel.songIDList.count;
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
//    if ( artwork ){
//        UIImage* foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
//        receivingBlock(foo, nil);
//    } else {
//        receivingBlock(nil,nil);
//    }
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
