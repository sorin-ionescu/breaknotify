// The MIT License
//
// Copyright (c) 2013 Sorin Ionescu.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SIBreakNotifier.h"
#import "SIScriptableSilencing.h"
#import "SIITunesSilencer.h"
#import "SIQuickTimePlayerSilencer.h"
#import "SIMPlayerXSilencer.h"
#import "SIVLCSilencer.h"
#import "icon.png.h"

@implementation SIBreakNotifier

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    defaults = [[NSUserDefaults standardUserDefaults] retain];
    [defaults addSuiteNamed:@"org.sorin-ionescu.breaknotify"];
    [defaults registerDefaults:@{
        @"Notifications" : @[
            @{
                @"Name" : @"Mini",
                @"Enabled" : @(YES),
                @"Sticky" : @(NO),
                @"Interval" : @300.0,
                @"Title" : @"Mini Break",
                @"Description" : @"Take a small break!",
                @"Sound" : @"Submarine"
            },
            @{
                @"Name" : @"Full",
                @"Enabled" : @(YES),
                @"Sticky" : @(YES),
                @"Interval" : @600.0,
                @"Title" : @"Full Break",
                @"Description" : @"Take a break!",
                @"Sound" : @"Ping"
            },
        ],
        @"Exclusions" : @[
            @"iTunes"
            @"MPlayerX",
            @"QuickTime Player",
            @"VLC",
        ]
    }];

    scriptableSilencers = [@{
        @"iTunes" : (Class <SIScriptableSilencing>) [SIITunesSilencer class],
        @"MPlayerX" : (Class <SIScriptableSilencing>) [SIMPlayerXSilencer class],
        @"QuickTime Player" : (Class <SIScriptableSilencing>) [SIQuickTimePlayerSilencer class],
        @"VLC" : (Class <SIScriptableSilencing>) [SIVLCSilencer class]
    } retain];

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^(id notification, NSDictionary *bindings) {
        return [[notification objectForKey:@"Enabled"] boolValue];
    }];

    notifications = [[[defaults arrayForKey:@"Notifications"] filteredArrayUsingPredicate:predicate] retain];

    return self;
}

- (void)dealloc {
    [defaults release];
    [scriptableSilencers release];
    [notifications release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(id)sender {
    if ([self applicationIsRunning]) {
        [NSApp terminate:self];
    }

    [GrowlApplicationBridge setGrowlDelegate:self];

    [self scheduleNextNotification];
}

- (BOOL)applicationIsRunning {
    NSString *processName = [[NSProcessInfo processInfo] processName];
    NSPredicate *duplicatesPredicate = [NSPredicate predicateWithFormat:@"localizedName==%@", processName];
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSArray *runningApplications = [sharedWorkspace runningApplications];
    NSArray *duplicateApplications = [runningApplications filteredArrayUsingPredicate:duplicatesPredicate];

    if ([duplicateApplications count] > 1) {
        return YES;
    }

    return NO;
}

- (NSDictionary *)registrationDictionaryForGrowl {
    NSMutableArray *names = [NSMutableArray array];
    NSString* name = nil;

    for (id notification in notifications) {
        name = [notification objectForKey:@"Name"];
        if (name) {
            [names addObject:name];
        }
    }

    return @{
        GROWL_TICKET_VERSION        : @1,
        GROWL_APP_ID                : @"breaknotify",
        GROWL_NOTIFICATIONS_ALL     : names,
        GROWL_NOTIFICATIONS_DEFAULT : names
    };
}

- (NSData *)applicationIconDataForGrowl {
    return [NSData dataWithBytesNoCopy:icon_png length:icon_png_len freeWhenDone:NO];
}

- (void)growlNotificationTimedOut:(id)clickContext {
    if (clickContext && [clickContext isEqualToString:@"scheduleNextNotification"]) {
        [self scheduleNextNotification];
    }
}

- (void)growlNotificationWasClicked:(id)clickContext {
    if (clickContext && [clickContext isEqualToString:@"scheduleNextNotification"]) {
        [self scheduleNextNotification];
    }
}

- (BOOL)notificationIsSilenced {
    NSArray *silencers = [defaults arrayForKey:@"Silencers"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localizedName IN %@", silencers];
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSArray *runningApplications = [sharedWorkspace runningApplications];
    NSArray *runningSilencers = [runningApplications filteredArrayUsingPredicate:predicate];

    BOOL silenceNotification = NO;
    NSString *runningSilencerName = nil;
    Class <SIScriptableSilencing> scriptableSilencer = nil;

    for (id runningSilencer in runningSilencers) {
        silenceNotification = YES;
        runningSilencerName = [runningSilencer localizedName];
        scriptableSilencer = [scriptableSilencers objectForKey:runningSilencerName];

        if (scriptableSilencer && [scriptableSilencer applicationSilencesNotification]) {
            break;
        } else {
            silenceNotification = NO;
        }
    }

    return silenceNotification;
}

- (NSDictionary*)nextNotification {
    if ([notifications count] < 1) {
        return nil;
    }

    if (notificationIndex >= [notifications count]) {
        notificationIndex = 0;
    }

    NSDictionary *notification = [notifications objectAtIndex:notificationIndex];

    notificationIndex += 1;

    return notification;
}

- (void)scheduleNextNotification {
    NSDictionary *notification = [self nextNotification];
    if (!notification) {
        [NSApp terminate:self];
    }

    id intervalObject = [notification objectForKey:@"Interval"];
    if (!intervalObject) {
        [NSApp terminate:self];
    }

    double interval = [intervalObject doubleValue];
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(notifyOfBreak:)
                                   userInfo:notification
                                    repeats:NO];
}

- (void)notifyOfBreak:(NSTimer *)timer {
    NSDictionary *notification = [timer userInfo];
    if (!notification || [self notificationIsSilenced]) {
        [self scheduleNextNotification];
        return;
    }

    NSString *name = [notification objectForKey:@"Name"];
    NSString *title = [notification objectForKey:@"Title"];
    NSString *description = [notification objectForKey:@"Description"];
    NSString *soundName = [notification objectForKey:@"Sound"];
    BOOL sticky = [[notification objectForKey:@"Sticky"] boolValue];

    if (soundName) {
        NSSound *sound = [NSSound soundNamed:soundName];
        if (sound) {
            [sound play];
        }
    }

    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:name
                                   iconData:[self applicationIconDataForGrowl]
                                   priority:0
                                   isSticky:sticky
                               clickContext:@"scheduleNextNotification"
                                 identifier:name];
}

@end
