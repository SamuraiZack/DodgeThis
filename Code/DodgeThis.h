/* Copyright 2012 IGN Entertainment, Inc. */

#import <Foundation/Foundation.h>

typedef enum {
    DTServiceTypeFacebook,
    DTServiceTypeTwitter,
    DTServiceTypeMail,
    DTServiceTypeMessage,
    DTServiceTypeInstapaper,
    DTServiceTypePocket,
    DTServiceTypeReadability
} DTServiceType;

// The type of content to show sharing options for
// For example, video contents will not show read later services
typedef enum {
    DTContentTypeAll,
    DTContentTypeArticle,
    DTContentTypeVideo
} DTContentType;

extern NSString *const AppDidBecomeActiveNotificationName;
extern NSString *const AppWillTerminateNotificationName;

@protocol DTService <NSObject>

@required
+ (void)shareWithParams:(NSDictionary *)params onViewController:(UIViewController *)viewController;

@end

@interface DodgeThis : NSObject
+ (void)shareURL:(NSURL *)url title:(NSString *)title image:(UIImage *)image withService:(DTServiceType)service onViewController:(UIViewController *)viewController;
+ (void)showShareOptionsToShareUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image onViewController:(UIViewController *)viewController;
+ (void)showShareOptionsToShareUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image onViewController:(UIViewController *)viewController forTypeOfContent:(DTContentType)contentType;
+ (void)startSessionWithURLSchemeSuffix:(NSString *)suffix;
+ (BOOL)handleFacebookOpenUrl:(NSURL *)url;
+ (BOOL)isSocialAvailable;
@end
