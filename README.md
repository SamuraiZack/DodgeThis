ShareThis
=========

A sharing controller that allows anyone to implement sharing into their projects easily. iOS 6 will use the new activity view controller while iOS 5 will use action sheets. Readability, Pocket, and Instapaper are added also for read-later services to share with articles.

#Installation Instruction:

##In AppDelegate.m:

###Import ShareThis.h

###In application:didFinishLaunchingWithOptions add:
    [ShareThis startSessionWithFacebookURLSchemeSuffix:pocketAPI:readabilityKey:readabilitySecret:];
Make sure that the url scheme that you enter is all **lower-case**. Set to nil or empty string if not planning on using the same Facebook App ID on multiple apps. Pocket and Readability parameters are also optional. If given a nil, those sharing options will not be available.

###In applicationDidBecomeActive add:
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDidBecomeActiveNotificationName object:nil];

###In applicationWillTerminate add:
    [[NSNotificationCenter defaultCenter] postNotificationName:AppWillTerminateNotificationName object:nil];

###Add in method application:openURL:sourceApplication:annotation
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation { return [ShareThis handleFacebookOpenUrl:url]; }

###In app's .plist file add:
    Key:FacebookAppID 
    Value:Your Facebook app ID

    Key:URL types --> Item 0 --> URL Schemes --> Item 0 
    Value:"fb"+value of your Facebook app ID+url scheme (make sure url scheme is lower-case)

#Using ShareThis:

###To share with a specific service:
    [ShareThis shareURL:title:image:withService:onViewController:];
Remember that to use Pocket and Readability, you must pass in the api key when starting ShareThis session in application:didFinishLaunchingWithOptions.

###To show a share option:
    [ShareThis showShareOptionsToShareUrl:title:image:onViewController:];

###To show a share option for a type of content:
    [ShareThis showShareOptionsToShareUrl:title:image:onViewController:forTypeOfContent:];
STContentTypeArticle will include the read later services while STContentTypeVideo will not.