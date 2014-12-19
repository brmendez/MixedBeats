//
//  ViewController.m
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/5/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSString *token;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *beatsArray;
@property (strong, nonatomic) UIAlertController *alert;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.searchBar.delegate = self;

}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear: animated];
  
  if /*([[[NSUserDefaults standardUserDefaults] valueForKey:@"authToken"] isKindOfClass:[NSString class]])*/ (NO){
    self.token = [[NSUserDefaults standardUserDefaults] valueForKey:@"authToken"];
    NSLog(@"%@", self.token);
  }else{
    
    self.alert = [UIAlertController alertControllerWithTitle:nil message:@"MixedBeats will present a web browser to BeatsMusic user athenication" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       [[NetworkController sharedInstance]requestOAuthAccess];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      
    }];
    
    [self.alert addAction:okAction];
    [self.alert addAction:cancelAction];
    [self presentViewController:self.alert animated:YES completion:nil];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return self.beatsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
  Beat *beat = self.beatsArray[indexPath.row];
  cell.textLabel.text = beat.name;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistViewController *playlistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PLAYLIST_VC"];
    [self addChildViewController:playlistVC];
    [playlistVC didMoveToParentViewController:self];
    Beat *beat = self.beatsArray[indexPath.row];
    playlistVC.playlistArray = [[NSMutableArray alloc]init];
    [playlistVC.playlistArray addObject:beat];
    NSLog(@"test test: %@", playlistVC.playlistArray.count);
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NSString *searchTerm = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  
  [[NetworkController sharedInstance] searchTerm:searchTerm completionHandler:^(NSError *error, NSMutableArray *beats) {
    self.beatsArray = beats;
    [self.tableView reloadData];
  }];
  
}

@end
