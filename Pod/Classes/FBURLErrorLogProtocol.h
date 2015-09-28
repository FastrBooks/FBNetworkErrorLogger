//
//  FBURLErrorLogProtocol.h
//  FBNetworkErrorLogger
//
//  Created by Kirils Sivokozs on 28/09/2015.
//  Copyright © 2015 Kirils Sivokozs. All rights reserved.
//

typedef void (^FBURLErrorLogBlock)(NSError *error, NSURL *url);

@interface FBURLErrorLogProtocol : NSURLProtocol

+ (void)start;
+ (void)stop;
+ (void)startWithLoggingBlock:(FBURLErrorLogBlock)block;

@end
