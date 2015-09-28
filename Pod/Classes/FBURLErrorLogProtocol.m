//
//  FBURLErrorLogProtocol.m
//  FBNetworkErrorLogger
//
//  Created by Kirils Sivokozs on 28/09/2015.
//  Copyright © 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBURLErrorLogProtocol.h"

NSString * const kFabulaErrorDomain = @"kFabulaErrorDomain";
static NSString * const kFabulaProtocolHandledKey = @"kFabulaProtocolHandledKey";

@interface FBURLErrorLogProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

static FBURLErrorLogBlock errorLogBlock;

@implementation FBURLErrorLogProtocol

+ (void)start
{
    [FBURLErrorLogProtocol startWithLoggingBlock:nil];
}

+ (void)stop
{
    [NSURLProtocol unregisterClass:self];
}

+ (void)startWithLoggingBlock:(__autoreleasing FBURLErrorLogBlock)block
{
    errorLogBlock = block;
    [NSURLProtocol registerClass:self];
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *protocol = request.URL.scheme;

    if (![@[@"http", @"https"] containsObject:protocol]) {
        return NO;
    }

    if ([NSURLProtocol propertyForKey:kFabulaProtocolHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kFabulaProtocolHandledKey inRequest:newRequest];
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    if (res.statusCode >= 400) {
        if (errorLogBlock) {
            errorLogBlock([NSError errorWithDomain:kFabulaErrorDomain
                                              code:res.statusCode
                                          userInfo:nil],
                          res.URL);
        }
    }
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%s", __FUNCTION__);
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    if (errorLogBlock) {
        errorLogBlock(error, connection.originalRequest.URL);
    }
    [self.client URLProtocol:self didFailWithError:error];
}

@end

