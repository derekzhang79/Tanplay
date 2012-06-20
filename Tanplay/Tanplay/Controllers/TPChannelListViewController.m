//
//  TPChannelListViewController.m
//  Tanplay
//
//  Created by ding jie on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPChannelListViewController.h"
#import "TPBaiduPublicProvider.h"
#import "TPDoubanFMProvider.h"

@interface TPChannelListViewController ()

@end

@implementation TPChannelListViewController

@synthesize tableView;
@synthesize channelProvider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"正在播放" style:UIBarButtonItemStylePlain target:self action:@selector(showPlayer)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(self.channelProvider == CP_BAIDU)
    {     
        [TPBaiduPublicProvider sharedProvider].channelListViewController = self;
        self.title = @"百度公共电台";
    }
    else if(self.channelProvider == CP_DOUBAN)
    {
        [TPDoubanFMProvider sharedProvider].channelListViewController = self;
        self.title = @"豆瓣FM";  
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *channels = nil;
    if(self.channelProvider == CP_BAIDU)
    {
        channels = [TPBaiduPublicProvider sharedProvider].channels;
    }
    else if(self.channelProvider == CP_DOUBAN)
    {
        channels = [TPDoubanFMProvider sharedProvider].channels;
    }
    return channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.channelProvider == CP_BAIDU)
    {
        cell.textLabel.text = ((TPBaiduChannel*)[[TPBaiduPublicProvider sharedProvider].channels objectAtIndex:indexPath.row]).channelName;
    }
    else if(self.channelProvider == CP_DOUBAN)
    {
        NSString *text = ((TPDoubanChannel*)[[TPDoubanFMProvider sharedProvider].channels objectAtIndex:indexPath.row]).channelName;
        cell.textLabel.text = text;       
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"cell_song"];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)showPlayer
{
    if(self.channelProvider == CP_BAIDU)
    {
        [[TPBaiduPublicProvider sharedProvider] showPlayerView:self];
    }
    else if(self.channelProvider == CP_DOUBAN)
    {
        [[TPDoubanFMProvider sharedProvider] showPlayerView:self];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.channelProvider == CP_BAIDU)
    {
        [[TPBaiduPublicProvider sharedProvider] playChannel:indexPath.row];
    }
    else if(self.channelProvider == CP_DOUBAN)
    {
        [[TPDoubanFMProvider sharedProvider] playChannel:indexPath.row];
    }

}

@end
