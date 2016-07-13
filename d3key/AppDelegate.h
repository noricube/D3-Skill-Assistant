//
//  AppDelegate.h
//  d3key
//
//  Created by sunghyuk-imac on 2016. 2. 12..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) MainWindowController *windowController;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) IBOutlet NSMenuItem *aboutMenuItem;
@property (strong, nonatomic) NSStatusItem *statusBar;

- (IBAction)statusPreferences:(id)sender;

@end

