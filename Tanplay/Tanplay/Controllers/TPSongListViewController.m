//
//  TPSongListViewController.m
//  Tanplay
//
//  Created by ding jie on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPSongListViewController.h"
#import "TPMusicPlayerViewController.h"

@interface TPSongListViewController ()
- (void)playSongWithTrack:(NSInteger)indexPath;
@end

@implementation TPSongListViewController
@synthesize iPodProvider;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.iPodProvider = [[[TPiPodProvider alloc] init] autorelease];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"正在播放" style:UIBarButtonItemStylePlain target:self action:@selector(showPlayer)];
    }
    return self;
}

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    self.iPodProvider = nil;
    [super dealloc];
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
    return self.iPodProvider.mediaItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(indexPath.section == 0)
    {
        cell.textLabel.text = [self.iPodProvider musicPlayer:nil titleForTrack:indexPath.row];
        NSString *detail = [self.iPodProvider musicPlayer:nil albumForTrack:indexPath.row];
        detail = [detail stringByAppendingString:@"-"];
        detail = [detail stringByAppendingString: [self.iPodProvider musicPlayer:nil artistForTrack:indexPath.row]];
        cell.detailTextLabel.text = detail;
    }
    
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
    if(self.iPodProvider.controller == nil)
    {
        [self playSongWithTrack:0];
    }
    else 
    {
        [self presentViewController:self.iPodProvider.controller animated:YES completion:nil];
    }
}

- (void)playSongWithTrack:(NSInteger) track
{
    if(self.iPodProvider.controller == nil)
    {
        TPMusicPlayerViewController *playerViewController = [[[TPMusicPlayerViewController alloc] initWithNibName:@"TPMusicPlayerViewController" bundle:nil] autorelease];
        self.iPodProvider.controller = playerViewController;
        playerViewController.dataSource = self.iPodProvider;
        playerViewController.delegate = self.iPodProvider;
    }
    
    [self presentViewController:self.iPodProvider.controller animated:YES completion:nil];
    
    [self.iPodProvider.controller reloadData]; 
    [self.iPodProvider.controller playTrack:track atPosition:0 volume:0];  
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self playSongWithTrack:indexPath.row];
}


@end
