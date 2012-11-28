//
//  TPDownloadSongViewController.h
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDownloadSongsProvider.h"

@interface TPDownloadSongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DownloadManagerDelegate>
{
    
}

@property(nonatomic, assign) IBOutlet UITableView *tableView;

@end
