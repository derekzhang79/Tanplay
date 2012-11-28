//
//  TPChannelListViewController.h
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _CHANNELPROVIDER
{
    CP_BAIDU = 0,
    CP_DOUBAN = 1,
    CP_XIAMI = 2
}CHANNELPROVIDER;

@interface TPChannelListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) CHANNELPROVIDER channelProvider;

@end
