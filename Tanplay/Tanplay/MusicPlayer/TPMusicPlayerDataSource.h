//
//  TPMusicPlayerViewController.h
//  Tanplay
//
//  Created by on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Block Type used to receive images from the TPMusicPlayerDataSource
 */
typedef void(^TPMusicPlayerReceivingBlock)(UIImage* image, NSError** error);


@class TPMusicPlayerViewController;

/**
 * The DataSource for the TPMusicPlayerViewController provides all data necessary to display
 * a player UI filled with the appropriate information. 
 */
@protocol TPMusicPlayerDataSource <NSObject>

/**
 * Returns the title of the given track and player as a NSString. You can return nil for no title.
 * @param player the TPMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the title of the track. If you return nil, this track will have no title.
 */
-(NSString*)musicPlayer:(TPMusicPlayerViewController*)player titleForTrack:(NSUInteger)trackNumber;

/**
 * Returns the artist for the given track in the given TPMusicPlayerViewController.
 * @param player the TPMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the artist name of the track. If you return nil, this track will have no artist name.
 */
-(NSString*)musicPlayer:(TPMusicPlayerViewController*)player artistForTrack:(NSUInteger)trackNumber;

/**
* Returns the album for the given track in the given TPMusicPlayerViewController.
 * @param player the TPMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the album name of the track. If you return nil, this track will have no album name.
*/
-(NSString*)musicPlayer:(TPMusicPlayerViewController*)player albumForTrack:(NSUInteger)trackNumber;

/**
 * Returns the length for the given track in the given TPMusicPlayerViewController. Your implementation must provide a 
 * value larger than 0.
 * @param player the TPMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return length in seconds
 */
-(CGFloat)musicPlayer:(TPMusicPlayerViewController*)player lengthForTrack:(NSUInteger)trackNumber;

@optional

/**
 * Returns the number of tracks for the given player. If you do not implement this method
 * or return anything smaller than 2, one track is assumed and the skip-buttons are disabled.
 * @param player the TPMusicPlayerViewController that is making this request.
 * @return number of available tracks
 */
-(NSUInteger)numberOfTracksInPlayer:(TPMusicPlayerViewController*)player;

/**
 * Returns the artwork for a given track.
 *
 * The artwork is returned using a receiving block ( TPMusicPlayerReceivingBlock ) that takes an UIImage and an optional error. If you supply nil as an image, a placeholder will be shown.
 * @param player the TPMusicPlayerViewController that needs artwork.
 * @param trackNumber the index of the track for which the artwork is requested.
 * @param receivingBlock a block of type TPMusicPlayerReceivingBlock that needs to be called when the image is prepared by the receiver.
 * @see [TPMusicPlayerViewController preferredSizeForCoverArt]
 */
-(void)musicPlayer:(TPMusicPlayerViewController*)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(TPMusicPlayerReceivingBlock)receivingBlock;

@end
