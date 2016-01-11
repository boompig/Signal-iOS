//
//  NotificationPreviewViewController.m
//  Signal
//
//  Created by Frederic Jacobs on 09/12/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "NotificationSettingsViewController.h"

#import "Environment.h"
#import "NotificationSettingsOptionsViewController.h"
#import "NotificationSettingsRingtonesViewController.h"
#import "PreferencesUtil.h"

@interface NotificationSettingsViewController ()

@property NSArray *notificationsSections;

@end

@implementation NotificationSettingsViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"SETTINGS_NOTIFICATIONS", nil)];

    self.notificationsSections = @[
        NSLocalizedString(@"NOTIFICATIONS_SECTION_BACKGROUND", nil),
        NSLocalizedString(@"NOTIFICATIONS_SECTION_INAPP", nil)
    ];
}

typedef enum {
    kOptionBackgroundShow = 0,
    kOptionSound = 1
} kBackgroundRow;

typedef enum {
    kSectionBackground = 0,
    kSectionInApp = 1
} kSection;

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.notificationsSections objectAtIndex:(NSUInteger)section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.notificationsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case kSectionBackground: {
            return 2;
        }
        case kSectionInApp: {
            return 1;
        }
        default: {
            // should never reach here
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SignalTableViewCellIdentifier";
    UITableViewCell *cell    = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    PropertyListPreferences *prefs = Environment.preferences;
    switch(indexPath.section) {
        case kSectionBackground: {
            switch(indexPath.row) {
                case kOptionBackgroundShow: {
                    NotificationType notifType = [prefs notificationPreviewType];
                    NSString *detailString     = [prefs nameForNotificationPreviewType:notifType];
                    
                    [[cell textLabel] setText:NSLocalizedString(@"NOTIFICATIONS_SHOW", nil)];
                    [[cell detailTextLabel] setText:detailString];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                }
                case kOptionSound: {
                    SoundName soundNameEnum = [prefs notificationSound];
                    NSString *detailString = [prefs nameForNotificationSound:soundNameEnum];
                    
                    [[cell textLabel] setText:NSLocalizedString(@"NOTIFICATIONS_SOUND_SELECTION", nil)];
                    [[cell detailTextLabel] setText:detailString];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                }
            }
            break;
        }
        case kSectionInApp: {
            BOOL soundEnabled = [prefs soundInForeground];
            
            [[cell textLabel] setText:NSLocalizedString(@"NOTIFICATIONS_SOUND", nil)];
            [[cell detailTextLabel] setText:nil];
            UISwitch *switchv = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchv.on        = soundEnabled;
            [switchv addTarget:self
                        action:@selector(didToggleSoundNotificationsSwitch:)
              forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = switchv;
            break;
        }
    }
    return cell;
}

- (void)didToggleSoundNotificationsSwitch:(UISwitch *)sender {
    [Environment.preferences setSoundInForeground:sender.on];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.row) {
        case kOptionBackgroundShow: {
            NotificationSettingsOptionsViewController *vc =
            [[NotificationSettingsOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case kOptionSound: {
            NotificationSettingsRingtonesViewController *vc =
            [[NotificationSettingsRingtonesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType    = UITableViewCellAccessoryNone;
}

@end
