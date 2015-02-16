//
//  PlaylistViewController.m
//  MixedUp
//
//  Created by Brian Mendez on 12/16/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "PlaylistViewController.h"


@interface PlaylistViewController ()

- (IBAction)myPlaylistsButton:(id)sender;

@end

@implementation PlaylistViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.playlistArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
	NSDictionary *list = self.playlistArray[indexPath.row];
	cell.textLabel.text = list[@"name"];
	
	return cell;
}


- (IBAction)myPlaylistsButton:(id)sender {
	
  [[NetworkController sharedInstance] getMyPlaylists:([[NetworkController sharedInstance]user_ID]) completionHandler:^(NSError *error, NSMutableArray *playlists) {
      self.playlistArray = playlists;
      [self.tableView reloadData];
  }];
	
	
}


@end
