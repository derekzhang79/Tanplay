//
//  TPBaiduPublicProvider.h
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPMusicPlayerViewController.h"
#import "TPChannelListViewController.h"

@interface TPBaiduPublicProvider : NSObject //<TPMusicPlayerDelegate, TPMusicPlayerDataSource>
{
    
}

@property (nonatomic, assign) TPChannelListViewController *channelListViewController;

@end
