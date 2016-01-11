//
//  NotificationsManager.m
//  Signal
//
//  Created by Frederic Jacobs on 22/12/15.
//  Copyright © 2015 Open Whisper Systems. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <TextSecureKit/TSCall.h>
#import <TextSecureKit/TSContactThread.h>
#import <TextSecureKit/TSErrorMessage.h>
#import <TextSecureKit/TSIncomingMessage.h>
#import <TextSecureKit/TextSecureKitEnv.h>
#import "Environment.h"
#import "NotificationsManager.h"
#import "PreferencesUtil.h"
#import "PushManager.h"

@interface NotificationsManager ()

@property SystemSoundID newMessageSound;

@end

@implementation NotificationsManager

- (instancetype)init {
    self = [super init];


    if (self) {
        [self registerNotificationSound];
    }

    return self;
}

- (void)registerNotificationSound {
    PropertyListPreferences *prefs = Environment.preferences;
    NSString* name = [prefs notificationSoundName];
    NSString* ext = [prefs notificationSoundExtension];
    NSURL *newMessageSound =
    [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)newMessageSound, &_newMessageSound);
}

- (void)notifyUserForCall:(TSCall *)call inThread:(TSThread *)thread {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Remove previous notification of call and show missed notification.
        UILocalNotification *notif = [[PushManager sharedManager] closeVOIPBackgroundTask];
        TSContactThread *cThread   = (TSContactThread *)thread;

        if (call.callType == RPRecentCallTypeMissed) {
            if (notif) {
                [[UIApplication sharedApplication] cancelLocalNotification:notif];
            }

            PropertyListPreferences *prefs = Environment.preferences;
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.soundName            = [prefs notificationSoundFile];
            if ([[Environment preferences] notificationPreviewType] == NotificationNoNameNoPreview) {
                notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"MISSED_CALL", nil)];
            } else {
                notification.userInfo = @{Signal_Call_UserInfo_Key : cThread.contactIdentifier};
                notification.category = Signal_CallBack_Category;
                notification.alertBody =
                    [NSString stringWithFormat:NSLocalizedString(@"MSGVIEW_MISSED_CALL", nil), [thread name]];
            }

            [[PushManager sharedManager] presentNotification:notification];
        }
    }
}

- (void)notifyUserForErrorMessage:(TSErrorMessage *)message inThread:(TSThread *)thread {
    NSString *messageDescription = message.description;
    [self registerNotificationSound];

    if (([UIApplication sharedApplication].applicationState != UIApplicationStateActive) && messageDescription) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.userInfo             = @{Signal_Thread_UserInfo_Key : thread.uniqueId};
        PropertyListPreferences *prefs = Environment.preferences;
        notification.soundName            = [prefs notificationSoundFile];

        NSString *alertBodyString = @"";

        NSString *authorName = [thread name];
        switch ([[Environment preferences] notificationPreviewType]) {
            case NotificationNamePreview:
            case NotificationNameNoPreview:
                alertBodyString = [NSString stringWithFormat:@"%@: %@", authorName, messageDescription];
                break;
            case NotificationNoNameNoPreview:
                alertBodyString = messageDescription;
                break;
        }
        notification.alertBody = alertBodyString;

        [[PushManager sharedManager] presentNotification:notification];
    } else {
        if ([Environment.preferences soundInForeground]) {
            AudioServicesPlayAlertSound(_newMessageSound);
        }
    }
}

- (void)notifyUserForIncomingMessage:(TSIncomingMessage *)message from:(NSString *)name inThread:(TSThread *)thread {
    NSString *messageDescription = message.description;
    
    PropertyListPreferences *prefs = Environment.preferences;
    [self registerNotificationSound];

    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive && messageDescription) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName            = [prefs notificationSoundFile];

        switch ([[Environment preferences] notificationPreviewType]) {
            case NotificationNamePreview:
                notification.category = Signal_Full_New_Message_Category;
                notification.userInfo =
                    @{Signal_Thread_UserInfo_Key : thread.uniqueId, Signal_Message_UserInfo_Key : message.uniqueId};

                if ([thread isGroupThread]) {
                    NSString *sender =
                        [[TextSecureKitEnv sharedEnv].contactsManager nameStringForPhoneIdentifier:message.authorId];
                    if (!sender) {
                        sender = message.authorId;
                    }

                    NSString *threadName = [NSString stringWithFormat:@"\"%@\"", name];
                    notification.alertBody =
                        [NSString stringWithFormat:NSLocalizedString(@"APN_MESSAGE_IN_GROUP_DETAILED", nil),
                                                   sender,
                                                   threadName,
                                                   messageDescription];
                } else {
                    notification.alertBody = [NSString stringWithFormat:@"%@: %@", name, messageDescription];
                }
                break;
            case NotificationNameNoPreview: {
                notification.userInfo = @{Signal_Thread_UserInfo_Key : thread.uniqueId};
                if ([thread isGroupThread]) {
                    notification.alertBody =
                        [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"APN_MESSAGE_IN_GROUP", nil), name];
                } else {
                    notification.alertBody =
                        [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"APN_MESSAGE_FROM", nil), name];
                }
                break;
            }
            case NotificationNoNameNoPreview:
                notification.alertBody = NSLocalizedString(@"APN_Message", nil);
                break;
            default:
                notification.alertBody = NSLocalizedString(@"APN_Message", nil);
                break;
        }

        [[PushManager sharedManager] presentNotification:notification];
    } else {
        if ([Environment.preferences soundInForeground]) {
            AudioServicesPlayAlertSound(_newMessageSound);
        }
    }
}

@end
