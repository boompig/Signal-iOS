//
//  NotificationSettingsOptionsViewController.m
//  Signal
//
//  Created by Frederic Jacobs on 24/04/15.
//  Copyright (c) 2015 Open Whisper Systems. All rights reserved.
//

#import "Environment.h"
#import "NotificationSettingsRingtonesViewController.h"
#import "PreferencesUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

@interface NotificationSettingsRingtonesViewController ()
@property NSArray *options;
@end

@implementation NotificationSettingsRingtonesViewController

- (void)viewDidLoad {
    self.options = @[
        @(SoundNameDefault), @(SoundNameBlop), @(SoundNameEvilLaugh),
        @(SoundNameBananaSlap), @(SoundNameChaChingRegister), @(SoundNameGumBubblePop),
        @(SoundNameTick), @(SoundNameClinkingTeaspoon), @(SoundNamePlayingPool),
        @(SoundNameHolePunch)
    ];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"NotificationSettingsOption";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    PropertyListPreferences *prefs = [Environment preferences];
    NSUInteger soundNameEnum = [[self.options objectAtIndex:(NSUInteger)indexPath.row] unsignedIntegerValue];
    NSString* label = [prefs nameForNotificationSound:soundNameEnum];
    [[cell textLabel] setText:label];
    
    NSUInteger selectedSoundName = [prefs notificationSound];
    if (selectedSoundName == soundNameEnum) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger soundNameEnum = [[self.options objectAtIndex: (NSUInteger)indexPath.row] unsignedIntegerValue];
    PropertyListPreferences *prefs = Environment.preferences;
    
    [prefs setNotificationSound:soundNameEnum];
    
    NSString* soundName = [prefs notificationSoundName];
    NSString* soundExt = [prefs notificationSoundExtension];
    NSURL* url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:soundName ofType:soundExt]];
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) url, &soundID);
    AudioServicesPlayAlertSound(soundID);
    
    // reload placement of checkmark
    [self.tableView reloadData];

//    [self.navigationController popViewControllerAnimated:YES];
}

@end
