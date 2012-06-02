//
//  OBSlider.h
//
//  Created by Ole Begemann on 02.01.11.
//  Copyright 2011 Ole Begemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBSlider;

/**
 * Protocol to listen for the sliders changes.
 */
@protocol OBSliderDelegate <NSObject>

-(void)sliderDidBeginScrubbing:(OBSlider*)slider;
-(void)sliderDidEndScrubbing:(OBSlider*)slider;
-(void)slider:(OBSlider*)slider didChangeScrubbingSpeed:(CGFloat)speed;

@end

@interface OBSlider : UISlider
{
    float scrubbingSpeed;
    NSArray *scrubbingSpeeds;
    NSArray *scrubbingSpeedChangePositions;
    
    CGPoint beganTrackingLocation;
	
    float realPositionValue;
}

@property (atomic, assign, readonly) float scrubbingSpeed;
@property (atomic, retain) NSArray *scrubbingSpeeds;
@property (atomic, retain) NSArray *scrubbingSpeedChangePositions;
@property (atomic, assign) IBOutlet id<OBSliderDelegate> delegate;

@end
