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
	self.internalObject = proxyDefaults;
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
	}
	else if (type == 'l')
	{
		long param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'c')
	{
		BOOL param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'f')
	{
		float param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'd')
	{
		double param;
		[invocation getArgument:&param atIndex:2];
		[inv setArgument:&param atIndex:2];
	}
	else
	{
		id param;
		[invocation getArgument:&param atIndex:2];
		
		if ([param isKindOfClass:[DHUserDefaultsDictionary class]])
		{
			[param setObserver:self withContext:propName];
			
			NSDictionary *dict = [param internalObject];
			[inv setArgument:&dict atIndex:2];
		}
		else
			[inv setArgument:&param atIndex:2];
	}
	
	[inv invoke];
}


- (void) dictionaryUpdated:(NSDictionary *)dict context:(NSString *)context
{
	[self.internalObject setObject:dict forKey:context];
}

- (void) returnInternalValue:(NSString *)propName forInvocation:(NSInvocation *)invocation
{
	NSString *propType = [[self class] typeForProperty:propName];
	unichar type = [propType characterAtIndex:0];
	
	NSString *defaultsSelectorName = [NSString stringWithFormat:@"%@ForKey:",[self selectorElementForType:type]];
	
	SEL selector = NSSelectorFromString(defaultsSelectorName);
	
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
			[new setObserver:self withContext:propName];
			[invocation setReturnValue:&new];
		}
		else	
			[invocation setReturnValue:&ret];
	}
}

@end
