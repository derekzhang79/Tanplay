//
//  TPiPodProvider.m
//  Tanplay
//
//  Created by ding jie on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPiPodProvider.h"


@implementation TPiPodProvider

@synthesize iPodPlayer;
@synthesize controller;
@synthesize mediaItems;
@synthesize audioPlayer;
@synthesize currentTrack;

-(id)init {
    self = [super init];
    if ( self ){
        
        self.audioPlayer = [[[AVPlayer alloc] init] autorelease];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        self.iPodPlayer = [MPMusicPlayerController applicationMusicPlayer];
        
        // Using an unspecific query we extract all files from the library for playback.
        MPMediaQuery *everything = [[[MPMediaQuery alloc] init] autorelease];

        self.mediaItems = [everything items];
        
//        [self.iPodPlayer setQueueWithQuery:everything];
        
        [self.controller reloadData];
        [self.controller play];
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [[MPVolumeView alloc] init];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 120);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    
    return self;
}

- (void)dealloc
{
    self.audioPlayer = nil;
    self.iPodPlayer = nil;
    self.controller = nil;
    self.mediaItems = nil;
    [super dealloc];
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

-(CGFloat)musicPlayer:(TPMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    
}

-(NSUInteger)numberOfTracksInPlayer:(TPMusicPlayerViewController *)player
{
    return self.mediaItems.count;
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    if ( artwork ){
        UIImage* foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
        receivingBlock(foo, nil);
    } else {
        receivingBlock(nil,nil);
    }
}

#pragma mark Delegate Methods ( Used to control the music player )

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    //[self.iPodPlayer setNowPlayingItem:[self.mediaItems objectAtIndex:track]];
    MPMediaItem *item = [self.mediaItems objectAtIndex:track];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    currentTrack = track;
}

-(void)musicPlayerDidStartPlaying:(TPMusicPlayerViewController *)player {
    //[self.iPodPlayer play];
    [self.audioPlayer play];
}

-(void)musicPlayerDidStopPlaying:(TPMusicPlayerViewController *)player {
    //[self.iPodPlayer pause];
    [self.audioPlayer pause];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    [self.iPodPlayer setVolume:volume];
    //self.audioPlayer.volume = volume;
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    //[self.iPodPlayer setCurrentPlaybackTime:position];
    CMTime time = CMTimeMake(position, 1);
    [self.audioPlayer seekToTime:time];
}

-(void)musicPlayerActionRequested:(TPMusicPlayerViewController *)musicPlayer {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];    
}

-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)mp {
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's back button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//    [alertView show];
    [mp.navigationController popViewControllerAnimated:YES];
    
}


@end
