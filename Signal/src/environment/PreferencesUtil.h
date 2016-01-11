#import <Foundation/Foundation.h>
#import "PropertyListPreferences.h"
#import "Zid.h"

typedef NS_ENUM(NSUInteger, NotificationType) {
    NotificationNoNameNoPreview,
    NotificationNameNoPreview,
    NotificationNamePreview,
};

typedef NS_ENUM(NSUInteger, SoundName) {
    SoundNameDefault = 0,
    SoundNameBlop = 1,
    SoundNameEvilLaugh = 2,
    SoundNameGumBubblePop = 3,
    SoundNameTick = 4,
    SoundNameChaChingRegister = 5,
    SoundNameBananaSlap = 6,
    SoundNameClinkingTeaspoon = 7,
    SoundNameHolePunch = 8,
    SoundNamePlayingPool = 9
};

typedef NS_ENUM(NSUInteger, TSImageQuality) {
    TSImageQualityUncropped = 1,
    TSImageQualityHigh      = 2,
    TSImageQualityMedium    = 3,
    TSImageQualityLow       = 4
};

@class PhoneNumber;

@interface PropertyListPreferences (PropertyUtil)

- (NSTimeInterval)getCachedOrDefaultDesiredBufferDepth;
- (void)setCachedDesiredBufferDepth:(double)value;

- (BOOL)getHasSentAMessage;
- (void)setHasSentAMessage:(BOOL)enabled;

- (BOOL)getHasArchivedAMessage;
- (void)setHasArchivedAMessage:(BOOL)enabled;

- (BOOL)loggingIsEnabled;
- (void)setLoggingEnabled:(BOOL)flag;

- (BOOL)screenSecurityIsEnabled;
- (void)setScreenSecurity:(BOOL)flag;

- (NotificationType)notificationPreviewType;
- (void)setNotificationPreviewType:(NotificationType)type;
- (NSString *)nameForNotificationPreviewType:(NotificationType)notificationType;

- (BOOL)soundInForeground;
- (void)setSoundInForeground:(BOOL)enabled;

- (NSString*) notificationSoundName;
- (NSString*) notificationSoundFile;
- (NSString*) notificationSoundExtension;
- (SoundName) notificationSound;
- (void) setNotificationSound:(SoundName)soundNameEnum;
- (NSString*) nameForNotificationSound:(SoundName)soundNameEnum;

- (BOOL)hasRegisteredVOIPPush;
- (void)setHasRegisteredVOIPPush:(BOOL)enabled;

- (TSImageQuality)imageUploadQuality;
- (void)setImageUploadQuality:(TSImageQuality)quality;

- (NSString *)lastRanVersion;
- (NSString *)setAndGetCurrentVersion;


@end
