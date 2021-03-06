//
//  TPMusicPlayerDelegate.h
//  Tanplay
//
//  Created by on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class TPMusicPlayerViewController;


/**
 * The Delegate of the TPMusicPlayerViewController must adopt the TPMusicPlayerDelegate protocol to track changes
 * in the state of the music player.
 */
@protocol TPMusicPlayerDelegate <NSObject>

@optional

/**
 * Called by the player after the player started playing a song.
 * @param player the TPMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStartPlaying:(TPMusicPlayerViewController*)player;

/**
 * Called after a user presses the "play"-button but before the player actually starts playing.
 * @param player the TPMusicPlayerViewController sending the message
 * @return  If the value returned is NO, the player won't start playing. YES, tells the player to starts. Default is YES.
 */
-(BOOL)musicPlayerShouldStartPlaying:(TPMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing. This method is called both when the current song ends 
 * and if the user stops the playback. 
 * @param player the TPMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStopPlaying:(TPMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing the last track.
 * @param player the TPMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStopPlayingLastTrack:(TPMusicPlayerViewController*)player;


/**
 * Called before the player stops playing but after the user initiated the stop action.
 * @param player the TPMusicPlayerViewController sending the message
 * @return By returning NO here, the delegate may prevent the player from stopping the playback. Default YES.
 */
-(BOOL)musicPlayerShouldStopPlaying:(TPMusicPlayerViewController*)player;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 * @param player the TPMusicPlayerViewController sending the message
 * @param position new position in seconds
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player didSeekToPosition:(CGFloat)position;

/**
 * Called before the player actually skips to the next song, but after the user initiated that action.
 *
 * If an implementation returns NO, the track will not be changed, if it returns YES the track will be changed. If you do not implement this method, YES is assumed. 
 * @param player the TPMusicPlayerViewController sending the message
 * @param track a NSUInteger containing the number of the new track
 * @return YES if the track can be changed, NO if not. Default YES.
 */
-(BOOL)musicPlayer:(TPMusicPlayerViewController*)player shouldChangeTrack:(NSUInteger)track;

/**
 * Called after the music player changed to a new track
 *
 * You can implement this method if you need to react to the player changing tracks.
 * @param player the TPMusicPlayerViewController changing the track
 * @param track a NSUInteger containing the number of the new track
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player didChangeTrack:(NSUInteger)track;

/**
 * Called when the player's volume changed
 *
 * Note that this not actually change the volume of anything, but is rather a result of a change in the internal state of the TPMusicPlayerViewController. If you want to change the volume of a playback module, you can implement this method.
 * @param player The TPMusicPlayerViewController changing the volume
 * @param volume A float holding the volume on a range from 0.0f to 1.0f
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player didChangeVolume:(CGFloat)volume;

/**
 * Called when the player changes it's shuffle state.
 *
 * YES indicates the player is shuffling now, i.e. randomly selecting a next track from the valid range of tracks, NO
 * means there is no shuffling.
 * @param player The TPMusicPlayerViewController that changes the shuffle state
 * @param shuffling YES if shuffling, NO if not
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player didChangeShuffleState:(BOOL)shuffling;

/**
 * Called when the player changes it's repeat mode.
 *
 * The repeat modes are taken from MediaPlayer framework and indicate whether the player is in No Repeat, Repeat Once or Repeat All mode.
 * @param player The TPMusicPlayerViewController that changes the repeat mode.
 * @param repeatMode a MPMusicRepeatMode indicating the currently active mode.
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player didChangeRepeatMode:(MPMusicRepeatMode)repeatMode;

/**
 * Called when the action button in the music view controller is pressed.
 *
 * You can interact based on this event to present additional interaction options for a user or change behaviour.
 * @param musicPlayer the TPMusicPlayerViewController that received the action
 *
 * @warning The action button will only be visible if the delegate implements this method.
 */
-(void)musicPlayerActionRequested:(TPMusicPlayerViewController*)musicPlayer;

/**
 * Called when the back button in the music view controller is pressed.
 *
 * The delegate performs the proper action when the back button has been pushed
 * @param musicPlayer the TPMusicPlayerViewController that received the action
 *
 * @warning The back button will only be visible if the delegate implements this method.
 */
// TODO: is this really needed? How about some logic in the view controller to check if it can go back?
-(void)musicPlayerBackRequested:(TPMusicPlayerViewController*)musicPlayer;

- (BOOL)musicPlayerDownloadRequested:(TPMusicPlayerViewController*)musicPlaer;

@end

