/* Copyright 2012 IGN Entertainment, Inc. */

#import "DodgeThis.h"
#import "InstapaperActivityItem.h"
#import "PocketActivityItem.h"
#import "TwitterService.h"
#import "FacebookService.h"
#import "EmailService.h"
#import "MessageService.h"
#import "InstapaperService.h"
#import "PocketService.h"
#import "ReadabilityService.h"
#import "ReadabilityActivityItem.h"

static DodgeThis *_manager;
NSString *const AppDidBecomeActiveNotificationName = @"appDidBecomeActive";
NSString *const AppWillTerminateNotificationName = @"appWillTerminate";

@interface DodgeThis () <UIActionSheetDelegate>
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) UIViewController *viewControllerToShowServiceOn;
@property (nonatomic) DTContentType contentType;
@end

@implementation DodgeThis

+ (DodgeThis *)sharedManager
{
    if (!_manager) {
        _manager = [[DodgeThis alloc] init];
    }
    return _manager;
}

// Check if a social framework class is available
// If available, then device is ios6+
+ (BOOL)isSocialAvailable
{
    return NSClassFromString(@"SLComposeViewController") != nil;
}

// Save the view controller to later use to show service on
- (void)saveViewController:(UIViewController *)viewController
{
    self.viewControllerToShowServiceOn = viewController;
}

// Save dictionary with given parameters
// Need this so UIActionSheet delegate can have access to the parameters
- (NSDictionary *)saveDictionaryWithUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image
{
    self.params = [[NSDictionary alloc] initWithObjectsAndKeys:
     url ? url : @"", @"url",
     title ? title : @"", @"title",
     image, @"image",
     nil];
    
    return self.params;
}

#pragma mark Removing / Deallocating
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appWillTerminate" object:nil];
}

#pragma mark Sharing
// Perform the type of sharing service with passed in parameters
+ (void)shareURL:(NSURL *) url title:(NSString *)title image:(UIImage *)image withService:(DTServiceType)service  onViewController:(UIViewController *)viewController
{
    // Save the view to later use it to show/dismiss services
    [[DodgeThis sharedManager] saveViewController:viewController];
    // Save the params to share
    NSDictionary *params = [[DodgeThis sharedManager] saveDictionaryWithUrl:url title:title image:image];
    switch (service) {
        case DTServiceTypeFacebook:
            [FacebookService shareWithParams:params onViewController:viewController];
            break;
        case DTServiceTypeTwitter:
            [TwitterService shareWithParams:params onViewController:viewController];
            break;
        case DTServiceTypeMail:
            [EmailService shareWithParams:params onViewController:viewController];
            break;
        case DTServiceTypeMessage:
            [MessageService shareWithParams:params onViewController:viewController];
            break;
        case DTServiceTypeInstapaper:
            [InstapaperService shareWithParams:params onViewController:viewController];
            break;
        case DTServiceTypePocket:
            if ([[DodgeThis sharedManager] pocketAPIKey]) {
                [PocketService shareWithParams:params onViewController:viewController];
            }
            break;
        case DTServiceTypeReadability:
            if ([[DodgeThis sharedManager] readabilityKey] && [[DodgeThis sharedManager] readabilitySecret]) {
                [ReadabilityService shareWithParams:params onViewController:viewController];
            }
            break;
        default:
            break;
    }
}

#pragma mark ActionSheet / ActivityView
+ (void)showShareOptionsToShareUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image onViewController:(UIViewController *)viewController
{
    [[DodgeThis sharedManager] setContentType:DTContentTypeAll];
    [[DodgeThis sharedManager] showShareOptionsToShareUrl:url title:title image:image onViewController:viewController];
}

+ (void)showShareOptionsToShareUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image onViewController:(UIViewController *)viewController forTypeOfContent:(DTContentType)contentType
{
    [[DodgeThis sharedManager] setContentType:contentType];
    [[DodgeThis sharedManager] showShareOptionsToShareUrl:url title:title image:image onViewController:viewController];
}

- (void)showShareOptionsToShareUrl:(NSURL *)url title:(NSString *)title image:(UIImage *)image onViewController:(UIViewController *)viewController
{
    // Save the view to later use it to show/dismiss services
    [self saveViewController:viewController];
    // Save the params to share
    [self saveDictionaryWithUrl:url title:title image:image];
    // Show ios6+ activity view if available, if not then use action sheet
    if ([DodgeThis isSocialAvailable]) {
        [self showActivityView];
    } else {
        [self showActionSheet];
    }
}

// Show activity view which will handle all services itself with the given parameters
- (void)showActivityView
{
    NSArray *activityItems = [[NSArray alloc] initWithObjects:[self.params objectForKey:@"title"], [self.params objectForKey:@"url"], [self.params objectForKey:@"image"], nil];
    InstapaperActivityItem *instapaperActivity = [[InstapaperActivityItem alloc] init];
    PocketActivityItem *pocketActivity = [[PocketActivityItem alloc] init];
    ReadabilityActivityItem *readabilityActivity = [[ReadabilityActivityItem alloc] init];
    
//    NSArray *applicationActivities;
    NSMutableArray *applicationActivities;
    switch (self.contentType) {
        case DTContentTypeAll:
        case DTContentTypeArticle:
            applicationActivities = [NSMutableArray arrayWithObject:instapaperActivity];
            
            if (self.pocketAPIKey) {
                [applicationActivities addObject:pocketActivity];
            }
            
            if (self.readabilityKey && self.readabilitySecret) {
                [applicationActivities addObject:readabilityActivity];
            }
            break;
        case DTContentTypeVideo:
            applicationActivities = nil;
            break;
        default:
            break;
    }
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    [self.viewControllerToShowServiceOn presentViewController:activityVC animated:YES completion:nil];
}

// Show action sheet
- (void)showActionSheet
{
    NSMutableArray *buttonTitles = [[NSMutableArray alloc] initWithObjects:@"Facebook", @"Twitter", @"Email", @"Message", nil];
    switch (self.contentType) {
        case DTContentTypeAll:
        case DTContentTypeArticle:
            [buttonTitles addObject:@"Add to Instapaper"];
            if (self.pocketAPIKey) {
                [buttonTitles addObject:@"Add to Pocket"];
            }
            
            if (self.readabilityKey && self.readabilitySecret) {
                [buttonTitles addObject:@"Add to Readability"];
            }
            break;
        case DTContentTypeVideo:
            break;
        default:
            break;
    }
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sharing Options"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil,
                                                            nil];
    
    for (int i = 0; i < [buttonTitles count]; i++) {
        [self.actionSheet addButtonWithTitle:[buttonTitles objectAtIndex:i]];
    }
    
    [self.actionSheet addButtonWithTitle:@"Close"];
    self.actionSheet.cancelButtonIndex = buttonTitles.count;
    
    [self.actionSheet showInView:self.viewControllerToShowServiceOn.view];
}

// Call one of the services
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DTServiceType service = (DTServiceType) buttonIndex;
    switch (service) {
        case DTServiceTypeFacebook:
            [FacebookService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            break;
        case DTServiceTypeTwitter:
            [TwitterService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            break;
        case DTServiceTypeMail:
            [EmailService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            break;
        case DTServiceTypeMessage:
            [MessageService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            break;
        case DTServiceTypeInstapaper:
            if (self.contentType == DTContentTypeArticle || self.contentType == DTContentTypeAll) {
                [InstapaperService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            }
            break;
        case DTServiceTypePocket:
            if ((self.contentType == DTContentTypeArticle || self.contentType == DTContentTypeAll) && self.pocketAPIKey) {
                [PocketService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            }
            break;
        case DTServiceTypeReadability:
            if ((self.contentType == DTContentTypeArticle || self.contentType == DTContentTypeAll) && self.readabilityKey && self.readabilitySecret) {
                [ReadabilityService shareWithParams:self.params onViewController:self.viewControllerToShowServiceOn];
            }
            break;
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.actionSheet = nil;
}

+ (void)startSessionWithFacebookURLSchemeSuffix:(NSString *)suffix
                                      pocketAPI:(NSString *)pocketAPI
                                 readabilityKey:(NSString *)readabilityKey
                              readabilitySecret:(NSString *)readabilitySecret
{
    [FacebookService startSessionWithURLSchemeSuffix:suffix];
    [DodgeThis sharedManager].pocketAPIKey = pocketAPI;
    [DodgeThis sharedManager].readabilityKey = readabilityKey;
    [DodgeThis sharedManager].readabilitySecret = readabilitySecret;
}

// Called from AppDelegate's application open url method
+ (BOOL)handleFacebookOpenUrl:(NSURL *) url
{
    // attempt to extract a token from the url
    return [FacebookService handleFacebookOpenUrl:url];
}

@end
