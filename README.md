DodgeThis
=========

A sharing controller that allows anyone to implement sharing into their projects easily. iOS 5 will use action sheets and iOS 6 will use the new activity view controller. Readability, Pocket, and Instapaper are added also for read-later services to share with articles.

#Installation Instruction:

##In AppDelegate.m:

###Import DodgeThis.h

###In application:didFinishLaunchingWithOptions add:
    [DodgeThis startSessionWithURLSchemeSuffix:];
Make sure that the url scheme that you enter is all **lower-case**. Set to nil or empty string if not planning on using the same Facebook App ID on multiple apps.

###In applicationDidBecomeActive add:
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDidBecomeActiveNotificationName object:nil];

###In applicationWillTerminate add:
    [[NSNotificationCenter defaultCenter] postNotificationName:AppWillTerminateNotificationName object:nil];

###Add in method application:openURL:sourceApplication:annotation
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation { return [DodgeThis handleFacebookOpenUrl:url]; }

###In app's .plist file add:
    Key:FacebookAppID 
    Value:Your Facebook app ID

    Key:URL types --> Item 0 --> URL Schemes --> Item 0 
    Value:"fb"+value of your Facebook app ID+url scheme (make sure url scheme is lower-case)

#Using DodgeThis:

###To share with a specific service:
    [DodgeThis shareURL:title:image:withService:onViewController:];

###To show a share option:
    [DodgeThis showShareOptionsToShareUrl:title:image:onViewController:];