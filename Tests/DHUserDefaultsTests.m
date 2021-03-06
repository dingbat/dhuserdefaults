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
@property NSString *objectConfig;
@property NSInteger intConfig;
@property float floatConfig;
@property double doubleConfig;
@property BOOL boolConfig;
@property NSMutableArray *array;
@property DHUserDefaultsDictionary *dictionary;
@property (getter = isCustomGetter) BOOL customGetter;
@property (setter = theCustomSetter:) NSMutableDictionary *customSetter;
@property NSComparisonResult enumConfig;
@end

@implementation DHUserDefaults (myapp)
@dynamic objectConfig, intConfig, floatConfig, doubleConfig, boolConfig, enumConfig, customGetter, customSetter, array, dictionary;
@end

@interface DHUserDefaultsDictionary (myapp)
@property NSString *objectConfig;
@property NSInteger intConfig;
@property float floatConfig;
@property double doubleConfig;
@property BOOL boolConfig;
@property NSMutableArray *array;
@property DHUserDefaultsDictionary *dictionary;
@property (getter = isCustomGetter) BOOL customGetter;
@property (setter = theCustomSetter:) NSMutableDictionary *customSetter;
@property NSComparisonResult enumConfig;
@end

@implementation DHUserDefaultsDictionary (myapp)
@dynamic objectConfig, intConfig, floatConfig, doubleConfig, boolConfig, enumConfig, customGetter, customSetter, array, dictionary;
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

- (void) test_removing_keys
{
	STAssertNoThrow([DHUserDefaults defaults].objectConfig = @"hi", @"Should remove key");
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"hi", @".= should've saved to defaults");

	STAssertNoThrow([DHUserDefaults defaults].objectConfig = nil, @"Should remove key");
	STAssertNil([DHUserDefaults defaults].objectConfig, @"Key should be removed");
	STAssertNil([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"Key should be removed");
}

- (void) test_custom_getters_setters
{
	STAssertNoThrow([DHUserDefaults defaults].isCustomGetter, @"Should be able to call custom getter");
	STAssertNoThrow([DHUserDefaults defaults].customGetter = YES, @"Should be able to set custom getter");
	STAssertEquals([DHUserDefaults defaults].isCustomGetter, YES, @"Should have saved to custom getter");

	STAssertNoThrow([DHUserDefaults defaults].customSetter, @"Should be able to get custom setter");
	STAssertNoThrow([[DHUserDefaults defaults] theCustomSetter:[NSDictionary dictionary]], @"Should be able to set custom setter");
	STAssertEqualObjects([DHUserDefaults defaults].customSetter, [NSDictionary dictionary], @"Should have saved to custom setter");
}

- (void) test_kvo
{
	/** Arrays **/
	
	[DHUserDefaults defaults].array = [NSMutableArray array];
	STAssertNotNil([DHUserDefaults defaults].array,@"should've added it");
	STAssertNotNil([[NSUserDefaults standardUserDefaults] objectForKey:@"array"],@"should've added it");
	
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"array"] count], 0, @"should start w/0");	

	[[DHUserDefaults defaults].array addObject:@"hi"];
	
	STAssertEquals((int)[DHUserDefaults defaults].array.count, 1, @"should have the inserted object");	
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"array"] count], 1, @"should have 1");	

	[[DHUserDefaults defaults].array addObject:@"hi2"];
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"array"] count], 2, @"should have 2");	

	
	/** Dictionaries **/
	
	[DHUserDefaults defaults].dictionary = [DHUserDefaultsDictionary dictionary];
	STAssertNotNil([DHUserDefaults defaults].dictionary,@"should've added it");
	STAssertNotNil([[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"],@"should've added it");
	
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] count], 0, @"should start w/0");
	
	[DHUserDefaults defaults].dictionary.objectConfig = @"hello";
	
	STAssertEquals((int)[DHUserDefaults defaults].dictionary.count, 1, @"should have the inserted object");	
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] count], 1, @"should have 1");
	STAssertEqualObjects([[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] objectForKey:@"objectConfig"], @"hello", @"should've saved 'hello'");
	
	STAssertNoThrow([[DHUserDefaults defaults].dictionary setObject:@"test" forKey:@"undefkey"], nil);
	STAssertEqualObjects([[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] objectForKey:@"undefkey"], @"test", @"should've saved 'test'");

	[DHUserDefaults defaults].dictionary.intConfig = 25;

	STAssertEquals((int)[DHUserDefaults defaults].dictionary.count, 3, @"should have the inserted object");
	STAssertEquals((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] count], 3, @"should have 2");
	STAssertEqualObjects([[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] objectForKey:@"intConfig"], [NSNumber numberWithInt:25], @"should've saved the 25");
}

- (void) test_nested_dictionaries
{
	[DHUserDefaults defaults].dictionary = [DHUserDefaultsDictionary dictionary];
	[DHUserDefaults defaults].dictionary.dictionary = [DHUserDefaultsDictionary dictionary];
	[DHUserDefaults defaults].dictionary.dictionary.intConfig = 10;

	STAssertEquals((int)[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] objectForKey:@"dictionary"] objectForKey:@"intConfig"] intValue], 10, @"should have the inserted object");
	
	
	[DHUserDefaults defaults].dictionary.dictionary.array = [NSMutableArray array];
	[[DHUserDefaults defaults].dictionary.dictionary.array addObject:@"hi!"];
	
	STAssertEqualObjects([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionary"] objectForKey:@"dictionary"] objectForKey:@"array"] lastObject], @"hi!", @"should have the inserted object");
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
	
	STAssertNoThrow([[DHUserDefaults defaults] hash], @"Should allow regular NSObject methods");
	
	STAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"objectConfig"], @"hi", @".= should've saved to defaults");
	
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.objectConfig = @"hi",nil);
	STAssertEqualObjects(dict.objectConfig, @"hi", nil);
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
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.intConfig = 5,nil);
	STAssertEquals(dict.intConfig, 5, nil);
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
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.floatConfig = 5.0f,nil);
	STAssertEquals(dict.floatConfig, 5.0f, nil);
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
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.doubleConfig = (double)5.0,nil);
	STAssertEquals(dict.doubleConfig, (double)5.0, nil);

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
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.boolConfig = YES,nil);
	STAssertEquals(dict.boolConfig, YES, nil);
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
	
	DHUserDefaultsDictionary *dict = [[DHUserDefaultsDictionary alloc] init];
	STAssertNoThrow(dict.enumConfig = NSOrderedAscending,nil);
	STAssertEquals(dict.enumConfig, NSOrderedAscending, nil);
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
