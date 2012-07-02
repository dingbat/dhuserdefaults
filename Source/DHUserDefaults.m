/*
 
 DHUserDefaults.m
 
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

@implementation DHUserDefaults

static DHUserDefaults *shared = nil;

- (id) initWithDefaults:(NSUserDefaults *)proxyDefaults;
{
	self = [super init];
	if (self)
	{
		self.internalObject = proxyDefaults;
	}
	return self;
}

+ (id) standardUserDefaults
{
	return [self defaults];
}

+ (id) defaults
{
	if (!shared)
	{
		shared = [[DHUserDefaults alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
	}
	return shared;
}

- (NSString *) selectorElementForType:(unichar)type
{
	NSString *selectorElement = (type == '@' ? @"object" : 
								 type == 'i' ? @"integer" :
								 type == 'l' ? @"integer" :
								 type == 'c' ? @"bool" :
								 type == 'f' ? @"float" : 
								 type == 'd' ? @"double" : nil);
	return selectorElement;
}

- (void) setInternalValue:(NSString *)propName fromInvocation:(NSInvocation *)invocation
{
	NSString *propType = [[self class] typeForProperty:propName];
	unichar type = [propType characterAtIndex:0];
	
	NSString *defaultsSelectorName = [NSString stringWithFormat:@"set%@:forKey:",[[self selectorElementForType:type] capitalizedString]];
	
	SEL selector = NSSelectorFromString(defaultsSelectorName);
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.internalObject methodSignatureForSelector:selector]];
	inv.selector = selector;
	inv.target = self.internalObject;
	
	[inv setArgument:&propName atIndex:3];
		
	if (type == 'i')
	{
		int param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
		
		[cache setObject:[NSNumber numberWithInt:param] forKey:propName];
	}
	else if (type == 'l')
	{
		long param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
		
		[cache setObject:[NSNumber numberWithLong:param] forKey:propName];
	}
	else if (type == 'c')
	{
		BOOL param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
		
		[cache setObject:[NSNumber numberWithBool:param] forKey:propName];
	}
	else if (type == 'f')
	{
		float param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
		
		[cache setObject:[NSNumber numberWithFloat:param] forKey:propName];
	}
	else if (type == 'd')
	{
		double param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
		
		[cache setObject:[NSNumber numberWithDouble:param] forKey:propName];
	}
	else
	{
		id param;
		[invocation getArgument:&param atIndex:2];
		
		if (!param)
			[cache setObject:[NSNull null] forKey:propName];
		else
			[cache setObject:param forKey:propName];

		if ([param isKindOfClass:[DHUserDefaultsDictionary class]])
		{
			[param setObserver:self];
			[param setObserverContext:propName];
			
			param = [param internalObject];
		}

		[inv setArgument:&param atIndex:2];
	}
	
	[inv invoke];
}

- (void) pseudoDictionaryWasModified:(DHUserDefaultsDictionary *)dict
{
	[self.internalObject setObject:dict.internalObject forKey:dict.observerContext];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"setting %@ to %@",[object objectForKey:keyPath],keyPath);
	[self.internalObject setObject:[object objectForKey:keyPath] forKey:keyPath];
}

- (SEL) defaultsSelectorForType:(unichar)type
{
	return NSSelectorFromString([NSString stringWithFormat:@"%@ForKey:",[self selectorElementForType:type]]);
}

- (void) loadCache
{
	cache = [[NSMutableDictionary alloc] init];

	NSArray *properties = [self.class propertiesByGettersOrSetters:0].allValues;
	for (NSString *propName in properties)
	{
		NSString *propType = [[self class] typeForProperty:propName];
		unichar type = [propType characterAtIndex:0];
		
		SEL sel = [self defaultsSelectorForType:type];

		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.internalObject methodSignatureForSelector:sel]];

		[self returnInternalValue:propName forInvocation:invocation];

		if (type == 'd')
		{
			double param;
			[invocation getReturnValue:&param];
			[cache setObject:[NSNumber numberWithDouble:param] forKey:propName];
		}
		else if (type == 'f')
		{
			float param;
			[invocation getReturnValue:&param];
			[cache setObject:[NSNumber numberWithFloat:param] forKey:propName];
		}
		else
		{
			id param;
			[invocation getReturnValue:&param];

			if (type == 'i')
				param = [NSNumber numberWithInt:(int)param];
			else if (type == 'l')
				param = [NSNumber numberWithLong:(int)param];
			else if (type == 'c')
				param = [NSNumber numberWithBool:(BOOL)param];
			
			else if (type == '@')
			{
				NSString *type = [[propType stringByReplacingOccurrencesOfString:@"@" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
				if ([NSClassFromString(type) isSubclassOfClass:[NSArray class]])
					[cache addObserver:self forKeyPath:propName options:0 context:nil];
				
				//don't have to worry about converting NSDictionary to DHUserDefaultsDictionary since digging into defaults will return it anyway (see below)
				
				if (!param)
					param = [NSNull null];
			}
			
			[cache setObject:param forKey:propName];
		}
	}
}

- (void) returnInternalValue:(NSString *)propName forInvocation:(NSInvocation *)invocation
{
	NSString *propType = [[self class] typeForProperty:propName];
	unichar type = [propType characterAtIndex:0];
	
	id obj = [cache objectForKey:propName];

	if (obj)
	{
		if (obj == [NSNull null])
			obj = nil;
		
		if (type == '@')
		{
			if ([obj isKindOfClass:[NSArray class]])
			{
				obj = [cache mutableArrayValueForKey:propName];
			}

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
		
		NSLog(@"found cached value");
		return;
	}
	
	
	NSLog(@"digging ");
	
	SEL selector = [self defaultsSelectorForType:type];
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.internalObject methodSignatureForSelector:selector]];
	inv.selector = selector;
	inv.target = self.internalObject;
	
	[inv setArgument:&propName atIndex:2];
	
	[inv invoke];
	
	if (type == 'i')
	{
		int ret;
		[inv getReturnValue:&ret];
		[invocation setReturnValue:&ret];
	}
	else if (type == 'l')
	{
		long ret;
		[inv getReturnValue:&ret];
		[invocation setReturnValue:&ret];
	}
	else if (type == 'c')
	{
		BOOL ret;
		[inv getReturnValue:&ret];
		[invocation setReturnValue:&ret];
	}
	else if (type == 'f')
	{
		float ret;
		[inv getReturnValue:&ret];
		[invocation setReturnValue:&ret];
	}
	else if (type == 'd')
	{
		double ret;
		[inv getReturnValue:&ret];
		[invocation setReturnValue:&ret];
	}
	else
	{
		id ret;
		[inv getReturnValue:&ret];
		
		if ([ret isKindOfClass:[NSArray class]])
		{
			id new = [self.internalObject mutableArrayValueForKey:propName];
			[invocation setReturnValue:&new];
		}
		else if ([propType isEqualToString:@"@\"DHUserDefaultsDictionary\""])
		{
			DHUserDefaultsDictionary *new = [DHUserDefaultsDictionary dictionaryWithDictionary:ret];
			[new setObserver:self];
			[new setObserverContext:propName];

			[invocation setReturnValue:&new];
		}
		else	
			[invocation setReturnValue:&ret];
	}
}

@end
