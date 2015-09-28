//
//  FBStubHelper.m
//  FBNetworkErrorLogger
//
//  Created by Kirils Sivokozs on 28/09/2015.
//  Copyright © 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBStubHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>

@implementation FBStubHelper

+ (void)stubHTTPCallWithPath:(NSString *)path
                  statusCode:(int)statusCode
                      method:(NSString *)method
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        return [components.host isEqualToString:@"fabula.im"] &&
        [components.path isEqualToString:path];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary* obj = @{};
        return [OHHTTPStubsResponse responseWithJSONObject:obj
                                                statusCode:statusCode
                                                   headers:@{@"Date" : @"Wed, 15 Nov 1995 06:25:24 GMT",
                                                             @"Content-Type" : @"application/json"}];
    }];
}

@end
