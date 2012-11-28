//
//  TPDownloadSongsProvider.h
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPDownloader.h"
#import "TPMusicPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class TPSongDownloader;
@class TPDownloadSongViewController;

@protocol DownloadManagerDelegate <NSObject>
- (void)downloadProgress:(double)progress;
- (void)downloadCompleted:(MKNetworkOperation *)completedRequest;
- (void)downloadError:(NSError *)error;
@end

@interface TPDownloadSongsProvider : NSObject <TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    NSString *_plistFile;
}

@property(nonatomic, assign) id<DownloadManagerDelegate> delegate;
@property(nonatomic, strong) TPSongDownloader *songDownloader;
@property(nonatomic, retain) NSMutableArray *songs;
@property(nonatomic, retain) MKNetworkOperation *downloadOperation;
@property(nonatomic, retain) NSString *downloadingURL;
@property(nonatomic, assign) float downloadProgress;
@property(nonatomic, assign) BOOL isDownloading;

+ (TPDownloadSongsProvider *)sharedProvider;
- (BOOL)addDownloadTask:(NSString *)url name:(NSString *)name artist:(NSString *)artist album:(NSString *)album;
- (void)loadSongsFromPList;

@property (nonatomic, strong) AVPlayer* audioPlayer;
@property (nonatomic, strong) TPMusicPlayerViewController *playerViewController;
@property (nonatomic, assign) TPDownloadSongViewController *downloadSongViewController;
@property (nonatomic, strong) AVPlayerItem *playingAVPlayerItem;

- (void)playTrack:(NSInteger)track fromView:(UIViewController *)from;
- (void)showPlayerView:(UIViewController *)from;
- (void)removeSongByIndex:(NSInteger)index;
- (void)startNextDownloadTask:(NSInteger)index;
@end
