/*
 
 DHUserDefaultsTests.m
 
 Copyright (c) 2012 Dan Hassin.
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import "DHUserDefaults.h"
#import <SenTestingKit/SenTestingKit.h>

@interface DHUserDefaults (myapp)
@property (nonatomic, strong) NSString *objectConfig;
@property (nonatomic) NSInteger intConfig;
@property (nonatomic) float floatConfig;
@property (nonatomic) double doubleConfig;
@property (nonatomic) BOOL boolConfig;
@property (nonatomic) NSComparisonResult enumConfig;
@end

@implementation DHUserDefaults (myapp)
@dynamic objectConfig, intConfig, floatConfig, doubleConfig, boolConfig, enumConfig;
@end

@interface DHUserDefaultsTests : SenTestCase
@end

@implementation DHUserDefaultsTests

- (void) test_valid_methods
{
	STAssertThrows([[DHUserDefaults defaults] performSelector:@selector(fjoahf)], @"Shouldn't work with garbage");
	
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setConfig1:)], @"Class shouldn't respond to any selector");
	STAssertFalse([DHUserDefaults respondsToSelector:@selector(setConfig2:)], @"Class shouldn't respond to any selector");
	STAssertThrows([[DHUserDefaults defaults] performSelector:@selector(one:two:)], @"Should break if two arg selector is passed in");
}

- (void) test_object_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setObjectConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].objectConfig = @"hi", @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setObjectConfig:@"hi"], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(objectConfig)], @"Should respond to any selector");
	STAssertEqualObjects([DHUserDefaults defaults].objectConfig, @"hi", @"Should work with .");
	STAssertEqualObjects([[DHUserDefaults defaults] objectConfig], @"hi", @"Should work with x");
	
	[[DHUserDefaults defaults] synchronize];
	
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"hi", @".= should've saved to defaults");
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], [[DHUserDefaults defaults] objectForKey:@"objectConfig"], @"Should reference the same userdefaults");
}

- (void) test_int_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setIntConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].intConfig = 4, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setIntConfig:5], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(intConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults defaults].intConfig, 5, @"Should work with .");
	STAssertEquals([[DHUserDefaults defaults] intConfig], 5, @"Should work with x");

	STAssertEquals([[NSUserDefaults standardUserDefaults] integerForKey:@"intConfig"], 5, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults defaults].intConfig, [[NSUserDefaults standardUserDefaults] integerForKey:@"intConfig"], @"Should reference the same userdefaults");
}

- (void) test_float_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setFloatConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].floatConfig = 5.0f, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setFloatConfig:5.0f], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(floatConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults defaults].floatConfig, 5.0f, @"Should work with .");
	STAssertEquals([[DHUserDefaults defaults] floatConfig], 5.0f, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] floatForKey:@"floatConfig"], 5.0f, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults defaults].floatConfig, [[NSUserDefaults standardUserDefaults] floatForKey:@"floatConfig"], @"Should reference the same userdefaults");
}

- (void) test_double_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setDoubleConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].doubleConfig = (double)5.0, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setDoubleConfig:(double)5.0], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(doubleConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults defaults].doubleConfig, (double)5.0, @"Should work with .");
	STAssertEquals([[DHUserDefaults defaults] doubleConfig], (double)5.0, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] doubleForKey:@"doubleConfig"], (double)5.0, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults defaults].doubleConfig, [[NSUserDefaults standardUserDefaults] doubleForKey:@"doubleConfig"], @"Should reference the same userdefaults");
}

- (void) test_bool_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setBoolConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].boolConfig = YES, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setBoolConfig:NO], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(boolConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults defaults].boolConfig, NO, @"Should work with .");
	STAssertEquals([[DHUserDefaults defaults] boolConfig], NO, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] boolForKey:@"boolConfig"], NO, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults defaults].boolConfig, [[NSUserDefaults standardUserDefaults] boolForKey:@"boolConfig"], @"Should reference the same userdefaults");
}

- (void) test_enum_methods
{
	//Sets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(setEnumConfig:)], @"Should respond to any selector");
	STAssertNoThrow([DHUserDefaults defaults].enumConfig = NSOrderedAscending, @"Should work with .=");
	STAssertNoThrow([[DHUserDefaults defaults] setEnumConfig:NSOrderedAscending], @"Should work with setX:");
	
	//Gets
	STAssertTrue([[DHUserDefaults defaults] respondsToSelector:@selector(enumConfig)], @"Should respond to any selector");
	STAssertEquals([DHUserDefaults defaults].enumConfig, NSOrderedAscending, @"Should work with .");
	STAssertEquals([[DHUserDefaults defaults] enumConfig], NSOrderedAscending, @"Should work with x");
	
	STAssertEquals([[NSUserDefaults standardUserDefaults] integerForKey:@"enumConfig"], NSOrderedAscending, @".= should've saved to defaults");
	STAssertEquals([DHUserDefaults defaults].enumConfig, [[NSUserDefaults standardUserDefaults] integerForKey:@"enumConfig"], @"Should reference the same userdefaults");
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
