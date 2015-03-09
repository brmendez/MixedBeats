//
//  NetworkController.m
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/5/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "NetworkController.h"
#import <AVFoundation/AVFoundation.h> 

@interface NetworkController ()
@property (strong, nonatomic) NSString* client_secret;
@end

@implementation NetworkController

NSString* clientID = @"3nbxp96juh7spx6j9srkknhs";
NSString* clientSecret = @"uSbQFBHZtJEvBxjg2dc2fhRs";
NSString* oAuthURL = @"https://partner.api.beatsmusic.com/v1/oauth2/authorize";
NSString* response_type = @"token";
NSString* redirectURL = @"somefancyname://test";



+ (NetworkController*)sharedInstance
{
  static NetworkController *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[NetworkController alloc] init];
  });
  return _sharedInstance;
}

-(void)requestOAuthAccess {
  NSString *loginURL = [NSString stringWithFormat: @"%@?response_type=%@&redirect_uri=%@&client_id=%@", oAuthURL, response_type, redirectURL, clientID];
  NSURL* url = [NSURL URLWithString:loginURL];
  
  [[UIApplication sharedApplication]openURL:url];
}

-(void)handleOAuthURL: (NSURL*) callbackURL {
  NSString* query = callbackURL.query;
  NSString *components = query;
  NSArray* comp1Array= [components componentsSeparatedByString:@"access_token="];
  NSString* comp1 = [comp1Array lastObject];
  NSArray* comp2Array= [comp1 componentsSeparatedByString:@"&"];
  self.token = [comp2Array firstObject];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:([NetworkController sharedInstance].token) forKey:@"authToken"];
  [defaults synchronize];

  NSLog(@"ACCESS TOKEN: %@", self.token);
}

- (void)federatedSearchTerm:(NSString *)name completionHandler: (void(^)(NSError *error, NSDictionary *beats))completionHandler {
  NSString *urlWithSearchTerm = [[NSString alloc] init];
  urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search/federated?q=%@&limit=20&offset=0&client_id=3nbxp96juh7spx6j9srkknhs", name];
    
  NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (error) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
            NSLog(@"success! code: %lu", httpURLResponse.statusCode);
            NSDictionary *beats = [Beat parseJSONIntoBeats:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, beats);
          }];
        }
      }
    }
    
  }];
  
  [dataTask resume];
}

- (void)moreSearchTerm:(NSString *)name type:(NSString *)type completionHandler: (void(^)(NSError *error, NSDictionary *beats))completionHandler {
    NSString *urlWithSearchTerm = [[NSString alloc] init];
    urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search?q=%@&type=%@&limit=20&offset=0&client_id=3nbxp96juh7spx6j9srkknhs", name, type];
    
    
    NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error.localizedDescription);
      } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;

        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
          NSLog(@"success! code: %lu", httpURLResponse.statusCode);
          NSDictionary *beats = [Beat parseJSONIntoBeats:data];
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, beats);
          }];
        }
      }
    }];
    
    [dataTask resume];
}

- (void)getMyUserID: (void(^)(NSError *error, NSString *userID))completionHandler {
    NSString *urlWithSearchTerm = [[NSString alloc] init];
    urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/me?access_token=%@", self.token];
  
  
  NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (error) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
          NSLog(@"success! code: %lu", httpURLResponse.statusCode);
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"The JSON: %@", json);
            NSString *components = json;
            NSArray* comp1Array= [components componentsSeparatedByString:@"user_context\":\""];
            NSString* comp1 = [comp1Array lastObject];
            NSArray* comp2Array = [comp1 componentsSeparatedByString:@"\",\"extended"];
            self.user_ID = [comp2Array firstObject];
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, self.user_ID);
          }];

        }
      }
    }
    
  }];
  
  [dataTask resume];
}

- (void)getMyPlaylists:(NSString *)userID completionHandler: (void(^)(NSError *error, NSMutableArray *playlists))completionHandler {
  
  NSString *urlWithSearchTerm = [[NSString alloc] init];
  urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/users/%@/playlists?limit=20&offset=0&access_token=%@", self.user_ID, self.token];
  
  NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (error) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
          NSLog(@"success! code: %lu", (long)httpURLResponse.statusCode);
			
			
          NSMutableArray *playlists = [Playlist parseJsonToPlaylist:data];
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, playlists);
          }];
        }
      }
    }
    
  }];
  
  [dataTask resume];
}

- (void) getMyPlaylistTracksWithID:(NSString *)playlistID completionHandler: (void(^)(NSError *error, NSMutableArray *playlists))completionHandler {
	
	NSString *urlWithSearchTerm = [[NSString alloc] init];
	urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/playlists/%@/tracks?limit=20&offset=0&access_token=%@", playlistID, self.token];
	
	NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		} else {
			
			if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
				NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
				if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
					NSLog(@"success! code: %lu", httpURLResponse.statusCode);
					
					
					NSMutableArray *playlists = [Playlist parseJSONToTracklist:data];
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, playlists);
					}];
					
				}
			}
		}
		
	}];
	
	[dataTask resume];
}

@end