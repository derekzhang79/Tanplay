//
//  TPDownloadSongViewController.m
//  Tanplay
//
//  Created by 胡 蓉 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPDownloadSongViewController.h"

@implementation TPDownloadSongViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"正在播放" style:UIBarButtonItemStylePlain target:self action:@selector(showPlayer)];
        self.title = @"下载歌曲";
        [[TPDownloadSongsProvider sharedProvider] setDelegate:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showPlayer
{
    [[TPDownloadSongsProvider sharedProvider] showPlayerView:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [TPDownloadSongsProvider sharedProvider].songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 28, 200, 10)];
        [cell addSubview:progressView];
    }
    
    if(indexPath.section == 0)
    {
        NSDictionary *songDict = [[TPDownloadSongsProvider sharedProvider].songs objectAtIndex:indexPath.row];
        cell.textLabel.text = [songDict objectForKey:@"name"];
        NSString *detail = [songDict objectForKey:@"album"];
        detail = [detail stringByAppendingString:@"-"];
        detail = [detail stringByAppendingString:[songDict objectForKey:@"artist"]];
        cell.detailTextLabel.text = detail;
        for(UIView *view in cell.subviews)
        {
            if([view isKindOfClass:[UIProgressView class]])
            {
                UIProgressView *progressView = ((UIProgressView*)view);
                if([[songDict objectForKey:@"finish"] intValue] == 1)
                {
                    progressView.hidden = YES;
                    cell.detailTextLabel.hidden = NO;
                }
                else
                {
                    progressView.hidden = NO;
                    cell.detailTextLabel.hidden = YES;
                    NSString *url = [songDict objectForKey:@"url"];
                    if([url isEqualToString:[TPDownloadSongsProvider sharedProvider].downloadingURL])
                    {
                        progressView.progress = [TPDownloadSongsProvider sharedProvider].downloadProgress;
                        NSLog(@"%f", progressView.progress);
                    }
                }
            }
        }
    }
    
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     // Return NO if you do not want the specified item to be editable.
     return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         [[TPDownloadSongsProvider sharedProvider] removeSongByIndex:indexPath.row];
         [self.tableView reloadData];
     }   
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }   
 }


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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[TPDownloadSongsProvider sharedProvider].songs objectAtIndex:indexPath.row];
    if([[dict objectForKey:@"finish"] intValue] == 1)
    {
        [[TPDownloadSongsProvider sharedProvider] playTrack:indexPath.row fromView:self];
    }
    else
    {
        [[TPDownloadSongsProvider sharedProvider] startNextDownloadTask:indexPath.row];
    }
}




#pragma download delegate
- (void)downloadProgress:(double)progress
{
    [self.tableView reloadData];
}

- (void)downloadCompleted:(MKNetworkOperation *)completedRequest
{
    
}

- (void)downloadError:(NSError *)error
{
    
}


@end
