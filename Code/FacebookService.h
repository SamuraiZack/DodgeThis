/* Copyright 2012 IGN Entertainment, Inc. */

#import <Foundation/Foundation.h>
#import "DodgeThis.h"

@interface FacebookService : NSObject <DTService>
+ (BOOL)handleFacebookOpenUrl:(NSURL *)url;
+ (void)startSessionWithURLSchemeSuffix:(NSString *)suffix;
+ (void)closeSession;
@end
