//
//  TPIpodExampleProvider.m
//  Tanplay
//
//  Created by ding jie on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPiPodExampleProvider.h"


@implementation TPiPodExampleProvider

@synthesize musicPlayer;
@synthesize controller;
@synthesize mediaItems;

-(id)init {
    self = [super init];
    if ( self ){
        
        self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        
        // Using an unspecific query we extract all files from the library for playback.
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];

        self.mediaItems = [everything items];
        
        [self.musicPlayer setQueueWithQuery:everything];
        
        [self.controller reloadData];
        [self.controller play];
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [MPVolumeView new];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 12);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    
    return self;
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
    [self.musicPlayer setNowPlayingItem:[self.mediaItems objectAtIndex:track]];
}

-(void)musicPlayerDidStartPlaying:(TPMusicPlayerViewController *)player {
    [self.musicPlayer play];
}

-(void)musicPlayerDidStopPlaying:(TPMusicPlayerViewController *)player {
    [self.musicPlayer pause];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    [self.musicPlayer setVolume:volume];
}

-(void)musicPlayer:(TPMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    [self.musicPlayer setCurrentPlaybackTime:position];
}

-(void)musicPlayerActionRequested:(TPMusicPlayerViewController *)musicPlayer {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
}

-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)musicPlayer {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's back button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
}


@end
