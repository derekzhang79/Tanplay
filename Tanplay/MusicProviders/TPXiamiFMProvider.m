//
//  TPXiamiFMProvider.m
//  Tanplay
//
//  Created by ding jie on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPXiamiFMProvider.h"
#import "SBJson.h"
#import "TPDownloadSongsProvider.h"

#define CHNANNELLIST_URL @"http://api.xiami.com/app/android/radio-category"
#define SONGLIST_URL @"http://api.xiami.com/app/android/radio?id=%@"

MKNKErrorBlock XiamiErrorCallback = ^(NSError *error)
{
    
};

@implementation TPXiamiSongInfo
@synthesize picture, albumtitle, artist, url, title, sid;
@end

@implementation TPXiamiChannel
@synthesize channelID, channelName, songInfoList;
@end

@implementation TPXiamiCategory
@synthesize categoryName, channelList;
@end

@implementation TPXiamiFMProvider

@synthesize channelListViewController;
@synthesize audioPlayer;
@synthesize playerViewController;
@synthesize playingChannel;
@synthesize playingAVPlayerItem;
@synthesize categories;
@synthesize playingSongInfo;

-(id)init {
    self = [super init];
    if ( self ){
        _networkEngine = [[MKNetworkEngine alloc] initWithHostName:nil];
        
        self.audioPlayer = [AVPlayer sharedAVPlayer];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        self.playerViewController = [TPMusicPlayerViewController sharedMusicPlayerViewController];
    }  
    return self;
}

+ (TPXiamiFMProvider *)sharedProvider
{
    static TPXiamiFMProvider *provider = nil;
    
    @synchronized(self)
    {
        if(provider == nil)
        {
            provider = [[TPXiamiFMProvider alloc] init];
        }
    }
    
    return provider;
}

- (void)setChannelData:(NSArray *)_categories
{
    NSMutableArray *_cats = [[NSMutableArray alloc] init];
    for (int i = 0; i < _categories.count; i++) 
    {
        TPXiamiCategory *category = [[TPXiamiCategory alloc] init];
        NSMutableArray *_channels = [[NSMutableArray alloc] init];
        NSDictionary *dict = [_categories objectAtIndex:i];
        category.categoryName = [dict objectForKey:@"category_name"];
        NSArray *array = [dict objectForKey:@"radios"];
        for(int j = 0; j < array.count; j++)
        {
            TPXiamiChannel *channel = [[TPXiamiChannel alloc] init];
            channel.channelID = [[array objectAtIndex:j] objectForKey:@"radio_id"];
            channel.channelName = [[array objectAtIndex:j] objectForKey:@"radio_name"];
            [_channels addObject:channel];
        }
        category.channelList = _channels;
        [_cats addObject:category];
    }
    self.categories = _cats;
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
        NSDictionary *dict = [str JSONValue];
        if(dict == nil)
            return;
        [self setChannelData:[dict objectForKey:@"categorys"]];
        [self.channelListViewController.tableView reloadData];
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:CHNANNELLIST_URL];
    [op onCompletion:completionCallback onError:XiamiErrorCallback];
    [_networkEngine enqueueOperation:op];
}

- (void)setChannelListViewController:(TPChannelListViewController *)_channelListViewController
{
    channelListViewController = _channelListViewController;
    [self requestChannelList];
}

- (TPXiamiChannel *)channelByID:(NSString *)channelID
{
    for(TPXiamiCategory *category in self.categories)
    {
        for(TPXiamiChannel *channel in category.channelList)
        {
            if([channel.channelID isEqualToString:channelID])
            {
                return channel;
            }
        }
    }
    return nil;
}

- (void)setSongListData:(NSArray *)songs byChannelID:(NSString *)channelID
{
    TPXiamiChannel *channel = [self channelByID:channelID];
    if(channel == nil)
        return;
    
    NSMutableArray *songInfoList = [[NSMutableArray alloc] initWithCapacity:songs.count];
    for(int i = 0; i < songs.count; i++)
    {
        NSDictionary *dict = [songs objectAtIndex:i];
        TPXiamiSongInfo *song = [[TPXiamiSongInfo alloc] init];
        song.picture = [dict objectForKey:@"album_logo"];
        song.albumtitle = [dict objectForKey:@"title"];
        song.artist = [dict objectForKey:@"artist_name"];
        song.url = [dict objectForKey:@"location"];
        song.url = [song.url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        song.title = [dict objectForKey:@"name"];
        song.sid = [dict objectForKey:@"song_id"];
        
        [songInfoList addObject:song];
    }    
    channel.songInfoList = songInfoList;
}

- (void)requestSongListByChannelID:(NSString *)channelID
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        
        NSArray *songs = [[str.JSONValue objectForKey:@"radio"] objectForKey:@"songs"];
        if(songs == nil)
            return;
        [self setSongListData:songs byChannelID:channelID];
        [self.channelListViewController presentModalViewController:self.playerViewController animated:YES];
        [self.playerViewController reloadData]; 
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:[NSString stringWithFormat:SONGLIST_URL, channelID]];
    [op onCompletion:completionCallback onError:XiamiErrorCallback];
    [_networkEngine enqueueOperation:op];    
}

- (void)playChannel:(NSIndexPath *)indexPath
{
    if(indexPath.section >= self.categories.count)
        return;
    TPXiamiCategory *cat = [self.categories objectAtIndex:indexPath.section];
    if(indexPath.row >= cat.channelList.count)
        return;
    
    self.playerViewController.dataSource = self;
    self.playerViewController.delegate = self;
    self.playerViewController.isChannelMode = YES;
    TPXiamiChannel *channel = [cat.channelList objectAtIndex:indexPath.row];
    [self requestSongListByChannelID:channel.channelID];
    self.playingChannel = channel;   
}

- (void)playSongBySongInfo:(TPXiamiSongInfo *)song
{
    NSString *strURL = song.url;
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:strURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    self.playingAVPlayerItem = playerItem;
    self.playingSongInfo = song;
    [self.playerViewController updateUIForCurrentTrack];
}

#pragma mark Delegate Methods ( Used to control the music player )

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPXiamiSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).albumtitle;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPXiamiSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).artist;
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    assert(trackNumber < self.playingChannel.songInfoList.count);
    return ((TPXiamiSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber]).title;
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
    TPXiamiSongInfo *song = (TPXiamiSongInfo *)[self.playingChannel.songInfoList objectAtIndex:trackNumber];
    
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
    
    TPXiamiSongInfo *song = [self.playingChannel.songInfoList objectAtIndex:track];
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
    return [[TPDownloadSongsProvider sharedProvider] addDownloadTask:self.playingSongInfo.url
                                                                name:self.playingSongInfo.title
                                                              artist:self.playingSongInfo.artist
                                                               album:self.playingSongInfo.albumtitle];
}

@end
