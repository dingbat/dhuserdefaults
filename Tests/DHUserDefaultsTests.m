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

@interface DHUserDefaults (myapp)
@property (nonatomic, strong) NSString *objectConfig;
@property (nonatomic) NSInteger intConfig;
@property (nonatomic) float floatConfig;
@property double doubleConfig;
@property (nonatomic) BOOL boolConfig;
@end

@implementation DHUserDefaults (myapp)
@dynamic objectConfig, intConfig, floatConfig, doubleConfig, boolConfig;
@end

@interface DHUserDefaultsTests : SenTestCase
@end

@implementation DHUserDefaultsTests

- (void) test_valid_methods
{
	STAssertThrows([[DHUserDefaults standardUserDefaults] performSelector:@selector(fjoahf)], @"Shouldn't work with garbage");
	
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setConfig1:)], @"Class shouldn't respond to any selector");
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setConfig2:)], @"Class shouldn't respond to any selector");
	STAssertThrows([[DHUserDefaults standardUserDefaults] performSelector:@selector(one:two:)], @"Should break if two arg selector is passed in");
}

- (void) test_object_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setObjectConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].objectConfig = @"hi", @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setObjectConfig:@"hi"], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(objectConfig)], @"Should respond to any selector");
	STAssertEqualObjects([DHUserDefaults standardUserDefaults].objectConfig, @"hi", @"Should work with .");
	STAssertEqualObjects([[DHUserDefaults standardUserDefaults] objectConfig], @"hi", @"Should work with x");
	
	[[DHUserDefaults standardUserDefaults] synchronize];
	
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"hi", @".= should've saved to defaults");
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], [[DHUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"Should reference the same userdefaults");
}

- (void) test_int_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setIntConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].intConfig = 4, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setIntConfig:5], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(intConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults standardUserDefaults].intConfig, 5, @"Should work with .");
	STAssertEquals([[DHUserDefaults standardUserDefaults] intConfig], 5, @"Should work with x");

	STAssertEquals([[NSUserDefaults standardUserDefaults] integerForKey:@"intConfig"], 5, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults standardUserDefaults].intConfig, [[NSUserDefaults standardUserDefaults] integerForKey:@"intConfig"], @"Should reference the same userdefaults");
}

- (void) test_float_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setFloatConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].floatConfig = 5.0f, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setFloatConfig:5.0f], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(floatConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults standardUserDefaults].floatConfig, 5.0f, @"Should work with .");
	STAssertEquals([[DHUserDefaults standardUserDefaults] floatConfig], 5.0f, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] floatForKey:@"floatConfig"], 5.0f, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults standardUserDefaults].floatConfig, [[NSUserDefaults standardUserDefaults] floatForKey:@"floatConfig"], @"Should reference the same userdefaults");
}

- (void) test_double_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setDoubleConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].doubleConfig = (double)5.0, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setDoubleConfig:(double)5.0], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(doubleConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults standardUserDefaults].doubleConfig, (double)5.0, @"Should work with .");
	STAssertEquals([[DHUserDefaults standardUserDefaults] doubleConfig], (double)5.0, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] doubleForKey:@"doubleConfig"], (double)5.0, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults standardUserDefaults].doubleConfig, [[NSUserDefaults standardUserDefaults] doubleForKey:@"doubleConfig"], @"Should reference the same userdefaults");
}

- (void) test_bool_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(setBoolConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults standardUserDefaults].boolConfig = YES, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults standardUserDefaults] setBoolConfig:NO], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults standardUserDefaults] respondsToSelector:@selector(boolConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults standardUserDefaults].boolConfig, NO, @"Should work with .");
	STAssertEquals([[DHUserDefaults standardUserDefaults] boolConfig], NO, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] boolForKey:@"boolConfig"], NO, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults standardUserDefaults].boolConfig, [[NSUserDefaults standardUserDefaults] boolForKey:@"boolConfig"], @"Should reference the same userdefaults");
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
