//
//  TPBaiduPublicProvider.m
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPBaiduPublicProvider.h"

@implementation TPBaiduPublicProvider

@synthesize channelListViewController;

-(id)init {
    self = [super init];
    if ( self ){
        
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

//-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
//}
//
//-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [item valueForProperty:MPMediaItemPropertyArtist];
//}
//
//-(NSString*)musicPlayer:(TPMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [item valueForProperty:MPMediaItemPropertyTitle];
//}
//
//-(CGFloat)musicPlayer:(TPMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
//    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
//    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
//    
//}
//
//-(NSUInteger)numberOfTracksInPlayer:(TPMusicPlayerViewController *)player
//{
//    return self.mediaItems.count;
//}
//
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
//
//#pragma mark Delegate Methods ( Used to control the music player )
//
//-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
//    MPMediaItem *item = [self.mediaItems objectAtIndex:track];
//    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
//    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
//    currentTrack = track;
//}
//
//-(void)musicPlayerDidStartPlaying:(TPMusicPlayerViewController *)player {
//    [self.audioPlayer play];
//}
//
//-(void)musicPlayerDidStopPlaying:(TPMusicPlayerViewController *)player {
//    [self.audioPlayer pause];
//}
//
//-(void)musicPlayer:(TPMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
//    [[MPMusicPlayerController iPodMusicPlayer] setVolume:volume];
//}
//
//-(void)musicPlayer:(TPMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
//    CMTime time = CMTimeMake(position, 1);
//    [self.audioPlayer seekToTime:time];
//}
//
//-(void)musicPlayerActionRequested:(TPMusicPlayerViewController *)musicPlayer {
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//    [alertView show];    
//}
//
//-(void)musicPlayerBackRequested:(TPMusicPlayerViewController *)musicPlayer {
//    
//    //[musicPlayer dismissViewControllerAnimated:YES completion:nil];   
//    [self doDismissPlayerAnimation];
//}

@end
