//
//  DHUserDefaultsTests.m
//  DHUserDefaultsTests
//
//  Created by Dan Hassin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DHUserDefaults.h"

#import <SenTestingKit/SenTestingKit.h>

@interface DHUserDefaultsTests : SenTestCase
@end

@implementation DHUserDefaultsTests

- (void) test_valid_methods
{
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setSomething:)], @"Class shouldn't respond to any selector");
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setSomething:)], @"Class shouldn't respond to any selector");

	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setSomething:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].something = @"hi", @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setSomething:@"hi"], @"Should work with setX:");

	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(something)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].something, @"Should work with .");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] something], @"Should work with x");
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

@end
