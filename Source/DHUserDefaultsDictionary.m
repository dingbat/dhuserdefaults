//
//  DHUserDefaultsDictionary.m
//  DHUserDefaults
//
//  Created by Dan Hassin on 6/28/12.
//
//

#import "DHUserDefaultsDictionary.h"
#import "DHUserDefaults.h"

@implementation DHUserDefaultsDictionary
@synthesize observer, observerContext;

- (DHUserDefaultsDictionary *) init
{
	self = [self initWithDictionary:[NSDictionary dictionary]];
	return self;
}

+ (DHUserDefaultsDictionary *) dictionary
{
	return [[[DHUserDefaultsDictionary alloc] initWithDictionary:[NSDictionary dictionary]] autorelease];
}

- (DHUserDefaultsDictionary *) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	self.internalObject = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	return self;
}

+ (DHUserDefaultsDictionary *) dictionaryWithDictionary:(NSDictionary *)dict
{
	return [[[DHUserDefaultsDictionary alloc] initWithDictionary:dict] autorelease];
}

- (BOOL) isEqual:(id)object
{
	//cool because it'll work even if object is DHUDD
	return [object isEqual:self.internalObject];
}

//this is if THIS dictionary has any dictionaries attached to it
- (void) pseudoDictionaryWasModified:(DHUserDefaultsDictionary *)dict
{
	[self setObject:dict forKey:dict.observerContext];
}

//this is if this dictionary has any arrays attached to it
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[observer pseudoDictionaryWasModified:self];
}


- (id) objectForKey:(id)aKey
{
	id obj = [self.internalObject objectForKey:aKey];
	if ([obj isKindOfClass:[NSDictionary class]])
	{
		obj = [DHUserDefaultsDictionary dictionaryWithDictionary:obj];
		[obj setObserver:self];
		[obj setObserverContext:aKey];
	}
	if ([obj isKindOfClass:[NSArray class]])
	{
		obj = [self.internalObject mutableArrayValueForKey:aKey];
		[self.internalObject addObserver:self forKeyPath:aKey options:0 context:nil];
	}
	
	return obj;
}

- (void) setObject:(id)obj forKey:(id)aKey
{
	if ([obj isKindOfClass:[DHUserDefaultsDictionary class]])
	{
		[obj setObserver:self];
		[obj setObserverContext:aKey];
		obj = [obj internalObject];
	}
	
	[self.internalObject setObject:obj forKey:aKey];
	
	[self.observer pseudoDictionaryWasModified:self];
}

- (void) setInternalValue:(NSString *)propName fromInvocation:(NSInvocation *)invocation
{
	NSString *propType = [[self class] typeForProperty:propName];
	unichar type = [propType characterAtIndex:0];
	
	id object;
	
	if (type == '@')
	{
		[invocation getArgument:&object atIndex:2];
	}
	else if (type == 'i')
	{
		int param;
		[invocation getArgument:&param atIndex:2];
		object = [NSNumber numberWithInt:param];
	}
	else if (type == 'l')
	{
		long param;
		[invocation getArgument:&param atIndex:2];
		object = [NSNumber numberWithLong:param];
	}
	else if (type == 'c')
	{
		BOOL param;
		[invocation getArgument:&param atIndex:2];
		object = [NSNumber numberWithBool:param];
	}
	else if (type == 'f')
	{
		float param;
		[invocation getArgument:&param atIndex:2];
		object = [NSNumber numberWithFloat:param];
	}
	else if (type == 'd')
	{
		double param;
		[invocation getArgument:&param atIndex:2];
		object = [NSNumber numberWithDouble:param];
	}
	
	[self setObject:object forKey:propName];
}

- (void) returnInternalValue:(NSString *)propName forInvocation:(NSInvocation *)invocation
{
	NSString *propType = [[self class] typeForProperty:propName];
	unichar type = [propType characterAtIndex:0];
	
	id obj = [self objectForKey:propName];
	
	if (type == '@')
	{
		[invocation setReturnValue:&obj];
	}
	else if (type == 'i')
	{
		int num = [obj intValue];
		[invocation setReturnValue:&num];
	}
	else if (type == 'l')
	{
		long num = [obj longValue];
		[invocation setReturnValue:&num];
	}
	else if (type == 'c')
	{
		BOOL num = [obj boolValue];
		[invocation setReturnValue:&num];
	}
	else if (type == 'f')
	{
		float num = [obj floatValue];
		[invocation setReturnValue:&num];
	}
	else if (type == 'd')
	{
		double num = [obj doubleValue];
		[invocation setReturnValue:&num];
	}
}


@end