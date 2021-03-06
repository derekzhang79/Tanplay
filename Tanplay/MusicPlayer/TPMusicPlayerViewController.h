//
//  TPMusicPlayerViewController.h
//  Tanplay
//
//  Created by on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TPMusicPlayerDelegate.h"
#import "TPMusicPlayerDataSource.h"
#import "OBSlider.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayer(singleton)
+ (AVPlayer *)sharedAVPlayer;
@end

/**
 * The Music Player component. This is a drop-in view controller and provides the UI for a music player.
 * It does not actually play music, just visualize music that is played somewhere else. The data to display
 * is provided using the datasource property, events can be intercepted using the delegate-property.
 */
@interface TPMusicPlayerViewController : UIViewController<OBSliderDelegate>


/// --------------------------------
/// @name Managing the Delegate and the Data Source
/// --------------------------------

/// The TPMusicPlayerDelegate object that acts as the delegate of the receiving music player.
@property (nonatomic,assign) id<TPMusicPlayerDelegate> delegate;

/// The TPMusicPlayerDataSource object that acts as the data source of the receiving music player.
@property (nonatomic,assign) id<TPMusicPlayerDataSource> dataSource;

/**
 * Reloads data from the data source and updates the player. If the player is currently playing, the playback is stopped.
 */
-(void)reloadData;


/// --------------------------------
/// @name Controlling Playback and Sound
/// --------------------------------

/// The index of the currently set track
@property (nonatomic) NSUInteger currentTrack; 

/// YES, if the player is in play-state
@property (nonatomic,readonly) BOOL playing; 

/// The Current Playback position in seconds
@property (nonatomic,readonly) CGFloat currentPlaybackPosition; 

/// The current repeat mode of the player.
@property (nonatomic) MPMusicRepeatMode repeatMode; 

/// YES, if the player is shuffling
@property (nonatomic) BOOL shuffling; 

/// The Volume of the player. Valid values range from 0.0f to 1.0f
@property (nonatomic) CGFloat volume;

@property (nonatomic) BOOL isChannelMode;

/**
 * Plays a given track using the supplied options.
 *
 * @param track the track that's to be played
 * @param position the position in the track at which the playback should begin
 * @param volume the Volume of the playback 
 */
-(void)playTrack:(NSUInteger)track atPosition:(CGFloat)position volume:(CGFloat)volume;


/**
 * Starts playback. If the player is already playing, this method does nothing except wasting some cycles.
 */
-(void)play;

/**
 * Starts playing the specified track. If the track is already playing, this method does nothing.
 */
//-(void)playTrack:(NSUInteger)track;

/**
 * Pauses the player. If the player is already paused, this method does nothing except generating some heat.
 */
-(void)pause;

/**
 * Skips to the next track. 
 *
 * If there is no next track, this method does nothing, if there is, it skips one track forward and informs the delegate.
 * In case [TPMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
-(void)next;

/**
 * Skips to the previous track. 
 *
 * If there is no previous track, i.e. the current track number is 0, this method does nothing, if there is, it skips one track backward and informs the delegate.
 * In case the [TPMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
-(void)previous;

- (void)updateUIForCurrentTrack;
+ (TPMusicPlayerViewController *)sharedMusicPlayerViewController;

/// --------------------------------
/// @name Controlling User Interaction
/// --------------------------------

/// If set to yes, the Previous-Track Button will be disabled if the first track of the set is played or set.
@property (nonatomic) BOOL shouldHidePreviousTrackButtonAtBoundary; 

/// If set to yes, the Next-Track Button will be disabled if the last track of the set is played or set.
@property (nonatomic) BOOL shouldHideNextTrackButtonAtBoundary; 


/// --------------------------------
/// @name Misc
/// --------------------------------

/// The preferred size for cover art in pixels
@property (nonatomic, readonly) CGSize preferredSizeForCoverArt; 


-(IBAction)nextAction:(id)sender;
-(IBAction)playAction:(id)sender;
-(IBAction)sliderValueChanged:(id)slider;
-(IBAction)coverArtTapped:(id)sender;

@end
