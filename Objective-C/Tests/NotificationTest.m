//
//  NotificationTest.m
//  CouchbaseLite
//
//  Created by Jim Borden on 2017/01/21.
//  Copyright © 2017 Couchbase. All rights reserved.
//

#import "CBLTestCase.h"
#import "CBLInternal.h"

@interface NotificationTest : CBLTestCase

@end

@implementation NotificationTest
{
    NSUInteger _dbCallbackCalls;
    NSUInteger _docCallbackCalls;
    NSMutableArray* _changes;
    XCTestExpectation* _callbackExpectation;
}

- (void)setUp {
    [super setUp];
    _changes = [NSMutableArray new];
}

- (void)handleDBNotification:(NSNotification *)notification {
    AssertEqualObjects([notification object], self.db);
    _dbCallbackCalls++;
    NSArray* changes = [notification userInfo][kCBLDatabaseChangesUserInfoKey];
    [_changes addObjectsFromArray:changes];
}

- (void)testDatabaseNotification {
    [self expectationForNotification: kCBLDatabaseChangeNotification
                              object: self.db
                             handler: ^BOOL(NSNotification *n)
     {
         NSArray *docIDs = n.userInfo[kCBLDatabaseChangesUserInfoKey];
         AssertEqual(docIDs.count, 10);
         return YES;
     }];
    
    __block NSError* error;
    bool ok = [self.db inBatch: &error do: ^BOOL {
        for (unsigned i = 0; i < 10; i++) {
            CBLDocument* doc = self.db[[NSString stringWithFormat: @"doc-%u", i]];
            doc[@"type"] = @"demo";
            Assert([doc save: &error], @"Error saving: %@", error);
        }
        return YES;
    }];
    XCTAssert(ok);
    
    [self waitForExpectationsWithTimeout: 5 handler: NULL];
}

@end
