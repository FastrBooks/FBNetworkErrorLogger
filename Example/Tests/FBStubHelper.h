//
//  FBStubHelper.h
//  FBNetworkErrorLogger
//
//  Created by Kirils Sivokozs on 28/09/2015.
//  Copyright © 2015 Kirils Sivokozs. All rights reserved.
//

@interface FBStubHelper : NSObject

+ (void)stubHTTPCallWithPath:(NSString *)path
                  statusCode:(int)statusCode
                      method:(NSString *)method;

@end
