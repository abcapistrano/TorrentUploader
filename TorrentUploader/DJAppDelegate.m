//
//  DJAppDelegate.m
//  TorrentUploader
//
//  Created by Earl on 4/5/13.
//  Copyright (c) 2013 Demon Jelly. All rights reserved.
//

#import "DJAppDelegate.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "NSURL+FileManagement.h"
#import <YAMLFramework/YAMLFramework.h>
@implementation DJAppDelegate
{
    NSOperationQueue *queue;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    NSURL *url = [aNotification.userInfo[NSApplicationLaunchUserNotificationKey] valueForKeyPath:@"userInfo.urlString.URL"];
    NSLog(@"launch: %@", url);
    if (url) {
        [url revealInFinder];
        [NSApp terminate:self];
    } else {
        [self startUpload];
    }
    
    

}

- (void) startUpload {


    queue = [[NSOperationQueue alloc] init];


    NSString *torrentPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"torrentPath"];
    if ([torrentPath length] == 0) {
        [NSApp terminate:self];
        return;
    }

        
    NSURL *torrentURL = [NSURL fileURLWithPath:torrentPath];
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://api.put.io/v2/"]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSDictionary *constants = [YACYAMLKeyedUnarchiver unarchiveObjectWithFile:@"/Users/earltagra/Library/Application Support/com.demonjelly.ThingsCleaner/Constants.yaml"];
    parameters[@"oauth_token"] = constants[@"putioOauthToken"];



    NSMutableURLRequest *myRequest = [client multipartFormRequestWithMethod:@"POST" path:@"files/upload" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:torrentURL] name:@"file" fileName:[torrentURL lastPathComponent] mimeType:@"application/x-bittorrent"];

    }];


    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];

    NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
    nc.delegate = self;
    __block NSUserNotification *note = [NSUserNotification new];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {


        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString *status = [response valueForKeyPath:@"transfer.status"];
        if ([status isEqualToString:@"IN_QUEUE"]) {

            note.title = @"Torrent uploaded";
            note.informativeText = [NSString stringWithFormat:@"%@ was uploaded to put.io.", torrentURL.lastPathComponent.stringByDeletingPathExtension ];
            [torrentURL trashFile];


        } else {

            note.title = @"Upload error";
            note.informativeText = [NSString stringWithFormat:@"Error uploading %@.", torrentURL.lastPathComponent.stringByDeletingPathExtension ];
            note.userInfo = @{@"urlString":torrentURL.absoluteString};
            NSLog(@"FAIL: %@", response);


        }
        [nc deliverNotification:note];
        [NSApp  terminate:self];



    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        note.title = @"Upload error";
        note.informativeText = [NSString stringWithFormat:@"Error uploading %@.", torrentURL.lastPathComponent.stringByDeletingPathExtension ];
        note.userInfo = @{@"urlString":torrentURL.absoluteString};

        [nc deliverNotification:note];

        NSLog(@"Fail: %@", [error localizedDescription]);
         [NSApp  terminate:self];
        
        
    }];
    
    [queue addOperation:operation];

    
}
- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {

    
}

@end
