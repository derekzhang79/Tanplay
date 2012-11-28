//
//  TPDownloadSongsProvider.m
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPDownloadSongsProvider.h"
#import "TPDownloader.h"
#import "FileUtil.h"

@implementation TPDownloadSongsProvider

@synthesize songs;
@synthesize songDownloader;
@synthesize downloadOperation;
@synthesize delegate;
@synthesize downloadingURL;
@synthesize downloadProgress;
@synthesize isDownloading;

@synthesize audioPlayer, playerViewController, downloadSongViewController, playingAVPlayerItem;

+ (TPDownloadSongsProvider *)sharedProvider
{
    static TPDownloadSongsProvider *manager = nil;
    
    @synchronized(self)
    {
        if(manager == nil)
        {
            manager = [[TPDownloadSongsProvider alloc] init];
        }
    }
    
    return manager;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _plistFile = [FileUtil filePathForDownloadSongsPList];
        [self loadSongsFromPList];
        self.audioPlayer = [AVPlayer sharedAVPlayer];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        self.playerViewController = [TPMusicPlayerViewController sharedMusicPlayerViewController];
    }
    return self;
}

- (void)loadSongsFromPList
{
    self.songs = [NSMutableArray arrayWithContentsOfFile:_plistFile];
}

- (void)saveSongsToPList
{
    NSLog(@"save %@", _plistFile);
    [self.songs writeToFile:_plistFile atomically:YES];
}

- (NSMutableDictionary *)songDictWithSongname:(NSString *)name artist:(NSString *)artist url:(NSString *)url fileName:(NSString *)fileName album:(NSString *)album
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          name, @"name", 
                          url, @"url", 
                          fileName, @"file",
                          artist, @"artist", 
                          album, @"album",
                          [NSNumber numberWithInteger:0], @"finish",
                          nil];
    return dict;
}

- (BOOL)setdownloadFinished:(NSString *)url
{
    for(NSMutableDictionary *dict in self.songs)
    {
        NSString *_url = [dict objectForKey:@"url"];
        if([_url isEqualToString:url])
        {
            [dict setObject:[NSNumber numberWithInteger:1] forKey:@"finish"];
            return YES;
        }
    }   
    return NO;
}

- (void)startDownloadTaskByIndex:(NSInteger) index
{
    
}

- (void)startNextDownloadTask:(NSInteger)index
{
    if(self.isDownloading)
        return;
    
    NSMutableDictionary *nextTask = nil;
    
    if(index >= 0)
    {
        assert(index < self.songs.count);
        nextTask = [self.songs objectAtIndex:index];
    }
    
    if(nextTask == nil) //index == -1
    {
        //for(NSMutableDictionary *dict in self.songs)
        for(int i = self.songs.count - 1; i >= 0; i--)
        {
            NSMutableDictionary *dict = [self.songs objectAtIndex:i];
            int finished = [[dict objectForKey:@"finish"] intValue];
            if(finished < 1)
            {
                nextTask = dict;
            }
        }
    }
    
    if(nextTask == nil) //no download task in list
    {
        self.isDownloading = NO;
        return;
    }
    
    if (!self.songDownloader)
        self.songDownloader = [[TPSongDownloader alloc] initWithHostName:nil customHeaderFields:nil];
    
    NSString *url = [nextTask objectForKey:@"url"];
    NSString *fileName = [nextTask objectForKey:@"file"];
    self.downloadOperation = [self.songDownloader downloadFileFrom:url toFile:[[FileUtil pathForDownloadSongs] stringByAppendingPathComponent:fileName]];    
    self.isDownloading = YES;
    self.downloadingURL = downloadOperation.url;
    
    MKNKProgressBlock downloadProgressCallback = ^(double progress)
    {
        DLog(@"%.2f", progress*100.0); 
        self.downloadProgress = progress;
        [self.delegate downloadProgress:progress];
    };
    
    MKNKResponseBlock downloadCompletionCallback = ^(MKNetworkOperation *completedRequest)
    {
        DLog(@"%@", completedRequest);   
        [self setdownloadFinished:[completedRequest url]];
        [self saveSongsToPList];
        self.isDownloading = NO;
        [self startNextDownloadTask:-1];
        [self.delegate downloadCompleted:completedRequest];
    };
    
    MKNKErrorBlock downloadErrorCallback = ^(NSError *error)
    {
        DLog(@"%@", error);
        [self.delegate downloadError:error]; 
        self.isDownloading = NO;
        [self startNextDownloadTask:-1];
    };
    
    [self.downloadOperation onDownloadProgressChanged:downloadProgressCallback];    
    [self.downloadOperation onCompletion:downloadCompletionCallback onError:downloadErrorCallback];       
}

- (BOOL)addDownloadTask:(NSString *)url name:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
    if(self.songs == nil)
    {
        self.songs = [NSMutableArray array];
    }
    
    for(NSMutableDictionary *dict in self.songs)
    {
        NSString *_url = [dict objectForKey:@"url"];
        if([_url isEqualToString:url])
        {
            return NO;
        }
    }
    
    NSString *fileName = [[FileUtil md5OfString:url] stringByAppendingString:@".mp3"];
    [self.songs addObject:[self songDictWithSongname:name artist:artist url:url fileName:fileName album:album]];
    
    [self startNextDownloadTask:-1];
    [self saveSongsToPList];
    return YES;
}

- (void)playTrack:(NSInteger)track fromView:(UIViewController *)from
{
    self.playerViewController.dataSource = self;
    self.playerViewController.delegate = self;
    self.playerViewController.isChannelMode = NO;
    [self showPlayerView:from];
    //[self.playerViewController reloadData]; 
    [self.playerViewController playTrack:track atPosition:0 volume:0]; 
}

- (void)showPlayerView:(UIViewController *)from
{
    [from presentViewController:self.playerViewController animated:YES completion:nil]; 
}

- (void)removeSongByIndex:(NSInteger)index
{
    if(index < 0 || index >= self.songs.count)
        return;
    
    NSDictionary *dict = [self.songs objectAtIndex:index];
    NSString *filePath = [dict objectForKey:@"file"];
    filePath = [[FileUtil pathForDownloadSongs] stringByAppendingPathComponent:filePath];
    [FileUtil deleteFileAtPath:filePath];
    [self.songs removeObjectAtIndex:index];
    [self saveSongsToPList];
}

#pragma music player delegate

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    NSMutableDictionary* dict = [self.songs objectAtIndex:trackNumber];
    return [dict objectForKey:@"album"];
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    NSMutableDictionary* dict = [self.songs objectAtIndex:trackNumber];
    return [dict objectForKey:@"artist"];
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    NSMutableDictionary* dict = [self.songs objectAtIndex:trackNumber];
    return [dict objectForKey:@"name"];
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
    return self.songs.count;
}

//-(void)musicPlayer:(TPMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
//    if ( artwork ){
//        UIImage* foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
//        receivingBlock(foo, nil);
//    } else {
//        receivingBlock(nil,nil);
//    }
//}

#pragma mark Delegate Methods ( Used to control the music player )

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    NSMutableDictionary* dict = [self.songs objectAtIndex:track];
    
    if([[dict objectForKey:@"finish"] intValue] < 1)
        [self.playerViewController nextAction:nil];
    
    NSString *filePath = [dict objectForKey:@"file"];
    filePath = [[[FileUtil pathForDownloadSongs] stringByAppendingString:@"/"] stringByAppendingString:filePath];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    self.playingAVPlayerItem = playerItem;
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
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];    
}

-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)musicPlayer 
{    
    [musicPlayer dismissViewControllerAnimated:YES completion:nil];
}



@end
