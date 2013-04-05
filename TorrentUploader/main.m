//
//  main.m
//  TorrentUploader
//
//  Created by Earl on 4/5/13.
//  Copyright (c) 2013 Demon Jelly. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DJAppDelegate.h"

int main(int argc, char *argv[])
{


    NSApplication * application = [NSApplication sharedApplication];
    DJAppDelegate *delegate = [[DJAppDelegate alloc] init];
    [application setDelegate:delegate];
    [application run];

    return EXIT_SUCCESS;
}
