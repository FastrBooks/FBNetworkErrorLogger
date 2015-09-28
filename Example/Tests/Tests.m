//
//  FBNetworkErrorLoggerTests.m
//  FBNetworkErrorLoggerTests
//
//  Created by Kirils Sivokozs on 09/28/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import "FBStubHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <FBNetworkErrorLogger/FBURLErrorLogProtocol.h>

SPEC_BEGIN(FBURLErrorLogProtocolTests)

describe(@"URLProtocol", ^{

  context(@"should", ^{

      __block NSURL *stubUrl;
      __block NSString *path;

      beforeAll(^{
          stubUrl = [NSURL URLWithString:@"https://fabula.im/xxx/yyy/zzz"];
          path = @"/xxx/yyy/zzz";
      });

      it(@"function correctly if error received", ^{
          [FBStubHelper stubHTTPCallWithPath:path statusCode:401 method:@"GET"];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:stubUrl];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil
                                                           error:&error];
          [[error shouldNot] beNil];
      });

      it(@"function correctly if no error received", ^{
          [FBStubHelper stubHTTPCallWithPath:path statusCode:200 method:@"GET"];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:stubUrl];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil
                                                           error:&error];
          [[error should] beNil];
      });

      it(@"return a callback if logging enabled", ^{
          __block BOOL called = NO;
          [FBURLErrorLogProtocol startWithLoggingBlock:^(NSError *error, NSURL *url) {
              [[error shouldNot] beNil];
              [[url.absoluteString should] equal:stubUrl.absoluteString];
              called = YES;
          }];
          [FBStubHelper stubHTTPCallWithPath:path statusCode:401 method:@"GET"];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:stubUrl];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                returningResponse:nil
                                            error:&error];
          [[error shouldNot] beNil];
          [[expectFutureValue(@(called)) shouldEventuallyBeforeTimingOutAfter(5.0)] beYes];
      });

      it(@"be stoppable", ^{
          __block BOOL called = NO;
          [FBURLErrorLogProtocol startWithLoggingBlock:^(NSError *error, NSURL *url) {
              [[url.absoluteString should] equal:stubUrl.absoluteString];
              [[error shouldNot] beNil];
              called = YES;
          }];
          [FBURLErrorLogProtocol stop];
          [FBStubHelper stubHTTPCallWithPath:path statusCode:401 method:@"GET"];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:stubUrl];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                returningResponse:nil
                                            error:&error];
          [[error shouldNot] beNil];
          [[expectFutureValue(@(called)) shouldAfterWaitOf(2.0)] beNo];
      });

      it(@"return a callback only if http/https", ^{
          __block BOOL called = NO;
          NSURL *ftpUrl = [NSURL URLWithString:@"ftp://not.fabula.im/xxx/yyy/zzz"];
          [FBURLErrorLogProtocol startWithLoggingBlock:^(NSError *error, NSURL *url) {
              [[url.absoluteString should] equal:ftpUrl.absoluteString];
              called = YES;
          }];
          [OHHTTPStubs removeAllStubs];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:ftpUrl];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                returningResponse:nil
                                            error:&error];
          [[error shouldNot] beNil];
          [[expectFutureValue(@(called)) shouldAfterWaitOf(2.0)] beNo];
          [FBURLErrorLogProtocol stop];
      });

      it(@"return a callback for invalid ssl", ^{
          __block BOOL called = NO;
          NSURL *invalidSSL = [NSURL URLWithString:@"https://invalid.https.fabula.im"];
          [FBURLErrorLogProtocol startWithLoggingBlock:^(NSError *error, NSURL *url) {
              [[url.absoluteString should] equal:invalidSSL.absoluteString];
              called = YES;
          }];
          [OHHTTPStubs removeAllStubs];
          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:invalidSSL];
          NSError *error;
          [NSURLConnection sendSynchronousRequest:request
                                returningResponse:nil
                                            error:&error];
          [[error shouldNot] beNil];
          [[expectFutureValue(@(called)) shouldEventuallyBeforeTimingOutAfter(5.0)] beYes];
          [FBURLErrorLogProtocol stop];
      });
  });

});

SPEC_END

