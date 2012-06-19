//
//  TPDoubanFMProvider.m
//  Tanplay
//
//  Created by 胡 蓉 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPDoubanFMProvider.h"
#import "SBJson.h"

#define CHNANNELLIST_URL @"http://www.douban.com/j/app/radio/channels"
MKNKErrorBlock doubanErrorCallback = ^(NSError *error)
{
    
};

@implementation TPDoubanChannel

@synthesize channelID, channelName;

@end

@implementation TPDoubanFMProvider

@synthesize channels;
@synthesize channelListViewController;

-(id)init {
    self = [super init];
    if ( self ){
        _networkEngine = [[MKNetworkEngine alloc] initWithHostName:nil];
        self.channels = [[NSMutableArray alloc] init];
    }  
    return self;
}

+ (TPDoubanFMProvider *)sharedProvider
{
    static TPDoubanFMProvider *provider = nil;
    
    @synchronized(self)
    {
        if(provider == nil)
        {
            provider = [[TPDoubanFMProvider alloc] init];
        }
    }
    
    return provider;
}

- (void)setChannelData:(NSArray *)data
{
    [self.channels removeAllObjects];
    for (int i = 0; i < data.count; i++) {
        TPDoubanChannel *channel = [[TPDoubanChannel alloc] init];
        channel.channelID = [[[data objectAtIndex:i] objectForKey:@"channel_id"] stringValue];
        channel.channelName = [[data objectAtIndex:i] objectForKey:@"name"];
        [self.channels addObject:channel];
    }
}

- (void)reloadData
{
    
}

- (void)requestChannelList
{
    MKNKResponseBlock completionCallback = ^(MKNetworkOperation *completedOperation)
    {
        NSString *str = [completedOperation responseString];
        NSDictionary *dict = [str JSONValue];
        if(dict == nil)
            return;
        [self setChannelData:[dict objectForKey:@"channels"]];
        [self.channelListViewController.tableView reloadData];
    };
    
    MKNetworkOperation *op = [_networkEngine operationWithURLString:CHNANNELLIST_URL];
    [op onCompletion:completionCallback onError:doubanErrorCallback];
    [_networkEngine enqueueOperation:op];
}

- (void)setChannelListViewController:(TPChannelListViewController *)_channelListViewController
{
    channelListViewController = _channelListViewController;
    [self requestChannelList];
}

@end
