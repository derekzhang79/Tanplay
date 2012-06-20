//
//  TPiPodProvider.h
//  Tanplay
//
//  Created by ding jie on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TPMusicPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TPiPodProvider : NSObject<TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{

}

- (void)playTrack:(NSInteger)track fromView:(UIViewController *)from;
- (void)showPlayerView:(UIViewController *)from;

+ (TPiPodProvider *)sharediPodProvider;

@property (nonatomic, retain) AVPlayer* audioPlayer;
@property (nonatomic, retain) TPMusicPlayerViewController *playerViewController;
@property (nonatomic, retain) NSArray* mediaItems; // An array holding items in the playback queue
@property (nonatomic) NSInteger currentTrack;

@end
