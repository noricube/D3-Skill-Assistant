//
//  AppDelegate.m
//  d3key
//
//  Created by sunghyuk-imac on 2016. 2. 12..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import "MainWindowController.h"
#import "D3KeyConfig.h"
#import "D3KeyConfigService.h"
#import "MSWeakTimer.h"
#import <ApplicationServices/ApplicationServices.h>
#include "const.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) D3KeyConfig *keyConfig;
@property (nonatomic, strong) NSMutableArray *timers;
@property (strong, nonatomic) dispatch_queue_t timersQueue;

@end

@implementation AppDelegate
{
    NSEvent *_gEvent;
}

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    //self.statusBar.title = @"D3A";
    
    // you can also set an image
    self.statusBar.image = [NSImage imageNamed:@"d3a_statusbar.png"];
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification {
    self.timers = [[NSMutableArray alloc] initWithCapacity:6];
    self.timersQueue = dispatch_queue_create("sunghyuk.d3key.timerQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // load config
    self.keyConfig = [[D3KeyConfigService sharedService] loadConfig:@"1"];
    
    // notification observer
    [self addNotificationObserver];
    
    if (self.windowController == nil) {
        self.windowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    }
    [self.windowController showWindow:self];
    
    // 손쉬운 사용 설정 안되어 있을 경우 Dialog open
    NSDictionary *options = @{(id)CFBridgingRelease(kAXTrustedCheckOptionPrompt): @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef) CFBridgingRetain(options));
    if (accessibilityEnabled) {
        [self registerEventMonitor];
    }    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self removeEventMonitor];
}

#pragma mark IBAction

- (IBAction)statusPreferences:(id)sender {
    if (![self.windowController.window isVisible]) {
        [self.windowController showWindow:self];
    }
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

#pragma mark Timer

- (void) startTimer {
    NSLog(@"start timers");

    for (int i = 1; i < 7; i++) {
        NSUInteger delay = [[self.keyConfig valueForKey:[NSString stringWithFormat:@"skillDelay%d", i]] unsignedIntegerValue];
        NSUInteger keyCode = [[self.keyConfig valueForKey:[NSString stringWithFormat:@"skillKey%d", i]] unsignedIntegerValue];
        if (delay > 0) {
            if (delay < 100) {
                delay = 100;
            }
            NSTimeInterval interval = delay*1.0 / 1000;
            NSDictionary *userInfo = @{@"keyCode":[NSNumber numberWithUnsignedInteger:keyCode]};
            NSLog(@"timer - keyCode: %@, interval: %f", [NSNumber numberWithUnsignedInteger:keyCode], interval);
            MSWeakTimer *timer = [MSWeakTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerFireMethod:) userInfo:userInfo repeats:YES dispatchQueue:self.timersQueue];
            [self.timers addObject:timer];
        }
    }
}

- (void) stopTimer {
    NSLog(@"stop timer");
    for (NSTimer *t in self.timers) {
        [t invalidate];
    }
    [self.timers removeAllObjects];
}

- (BOOL) isTimerRunning {
    return [self.timers count];
}

- (void)timerFireMethod:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    NSUInteger keyCode = [[userInfo objectForKey:@"keyCode"] unsignedIntegerValue];
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:kDiablo3AppId] count]) {
        pid_t pid = [(NSRunningApplication*)[[NSRunningApplication runningApplicationsWithBundleIdentifier:kDiablo3AppId] objectAtIndex:0] processIdentifier];
        
        CGEventRef qKeyUp;
        CGEventRef qKeyDown;
        ProcessSerialNumber psn;
        
        // get TextEdit.app PSN
        OSStatus err = GetProcessForPID(pid, &psn);
        if (err == noErr)
        {
            // see HIToolbox/Events.h for key codes
            qKeyDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, true);
            qKeyUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, false);
            
            CGEventPostToPSN(&psn, qKeyDown);
            CGEventPostToPSN(&psn, qKeyUp);
            
            CFRelease(qKeyDown);
            CFRelease(qKeyUp);
        } else {
            NSLog(@"error? %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
        }
    }
}

#pragma mark notification observer

- (void) addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserverForName:kD3KeyStartStopNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * note) {
        NSString *action = [note.userInfo objectForKey:@"action"];
        if ([action isEqualToString:@"start"]) {
            // start operation
            NSLog(@"receive start note");
            [self startTimer];
        } else if ([action isEqualToString:@"stop"]) {
            // stop operation
            NSLog(@"receive stop note, stop timer");
            [self stopTimer];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kD3KeyConfigChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * note) {
        self.keyConfig = [[D3KeyConfigService sharedService] loadConfig:[note.userInfo objectForKey:@"configId"]];
        NSLog(@"config changed: %@", [note.userInfo objectForKey:@"configId"]);
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:kD3KeyActivatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * note) {
        NSLog(@"activate event monitor");
        [self registerEventMonitor];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kD3KeyDeactivatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * note) {
        NSLog(@"deactivate event monitor");
        [self removeEventMonitor];
    }];
}

#pragma mark event monitor 

- (void) registerEventMonitor {
    if (_gEvent) {
        NSLog(@"global key event monitor already registered");
        return;
    }
    NSLog(@"register global key event monitor");
    _gEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
        
        if (![[NSRunningApplication runningApplicationsWithBundleIdentifier:kDiablo3AppId] count]) {
            NSLog(@"Diablo3 is not running");
            return;
        }
        
        NSUInteger keyCode = event.keyCode;
        if (![self isTimerRunning] && [self.keyConfig isStartKey:keyCode]) {
            // send start noti
            [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyStartStopNotification object:nil userInfo:@{@"action": @"start"}];
            return;
        }
        if ([self isTimerRunning] && [self.keyConfig isStopKey:keyCode]) {
            // send end noti
            [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyStartStopNotification object:nil userInfo:@{@"action": @"stop"}];
            return;
        }
    }];
}

- (void) removeEventMonitor {
    if (_gEvent) {
        NSLog(@"remove global key event monitor");
        [NSEvent removeMonitor:_gEvent];
        _gEvent = nil;
    }
}

@end
