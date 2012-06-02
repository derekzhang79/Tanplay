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

@interface TPiPodProvider : NSObject<TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    
}

@property (nonatomic,strong) MPMusicPlayerController* musicPlayer; // An instance of an ipod music player
@property (nonatomic,strong) TPMusicPlayerViewController* controller; // the TPMusicPlayerViewController
@property (nonatomic,strong) NSArray* mediaItems; // An array holding items in the playback queue

@end
