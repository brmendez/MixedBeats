//
//  Playlist.h
//  MixedUp
//
//  Created by kori kolodziejczak on 2/13/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Playlist : NSObject

@property (strong, nonatomic) NSString* playlistName;
@property (strong, nonatomic) NSMutableArray* songArray;

+(NSMutableArray *)parseJsonToPlaylist:(NSData *)data;

@end
