//
//  TPiPodProvider.m
//  Tanplay
//
//  Created by ding jie on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPiPodProvider.h"

@implementation TPiPodProvider

@synthesize playerViewController;
@synthesize mediaItems;
@synthesize audioPlayer;
@synthesize currentTrack;

-(id)init {
    self = [super init];
    if ( self ){
        
        self.audioPlayer = [[AVPlayer alloc] init];
        self.audioPlayer.allowsAirPlayVideo = YES;
        
        // Using an unspecific query we extract all files from the library for playback.
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];

        self.mediaItems = [everything items];
        
        /*
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [[MPVolumeView alloc] init];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 120);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
         */
        
        self.playerViewController = [[TPMusicPlayerViewController alloc] initWithNibName:@"TPMusicPlayerViewController" bundle:nil];
        self.playerViewController.dataSource = self;
        self.playerViewController.delegate = self;
        
    }
    
    return self;
}

- (void)dealloc
{

}

+ (TPiPodProvider *)sharediPodProvider
{
    static TPiPodProvider *provider = nil;
    
    @synchronized(self)
    {
        if(provider == nil)
        {
            provider = [[TPiPodProvider alloc] init];
        }
    }
    
    return provider;
}

- (void)doShowPlayerAnimation
{
   //[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.playerViewController animated:YES completion:nil];    
    self.playerViewController.view.frame = CGRectMake(0, 20, 320, 460);
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[UIApplication sharedApplication].keyWindow.rootViewController.view cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.playerViewController.view];
    [UIView commitAnimations];    
}

- (void)doDismissPlayerAnimation
{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[UIApplication sharedApplication].keyWindow.rootViewController.view cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    [playerViewController.view removeFromSuperview];
    [UIView commitAnimations]; 
}

- (void)playTrack:(NSInteger)track
{
    [self doShowPlayerAnimation];
    [self.playerViewController reloadData]; 
    [self.playerViewController playTrack:track atPosition:0 volume:0]; 
}

- (void)showPlayerView:(UIViewController *)from
{
    [self doShowPlayerAnimation];
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
    MPMediaItem *item = [self.mediaItems objectAtIndex:track];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    currentTrack = track;
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

-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)musicPlayer {
    
    //[musicPlayer dismissViewControllerAnimated:YES completion:nil];   
    [self doDismissPlayerAnimation];
}


@end
