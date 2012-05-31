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
#import <objc/runtime.h>

@interface DHUserDefaults (private)

- (id) initWithDefaults:(NSUserDefaults *)defaults;

@end

@implementation DHUserDefaults

//
// Returns the type encoding for the given property
// See https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
//
- (unichar) typeForProperty:(NSString *)prop
{
	objc_property_t property = class_getProperty(self.class, [prop UTF8String]);
	if (!property)
		return 0;
	
	NSString *atts = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
	//this will return some garbage like "Ti,GgetFoo,SsetFoo:,Vproperty"
	
	NSString *type = [[[atts componentsSeparatedByString:@","] objectAtIndex:0] substringFromIndex:1];
	return [type characterAtIndex:0];
}

//
// Returns a "wrapped" NSUserDefaults --
// Instance of DHUserDefaults that'll be used as a proxy
//
- (id) initWithDefaults:(NSUserDefaults *)proxyObj;
{
	self = [super init];
	if (self)
	{
		def = proxyObj;
	}
	return self;
}

//
// Methods to access standardUserDefaults as an instance of DHUserDefaults 
//
+ (id) standardUserDefaults
{
	return [self defaults];
}
+ (id) defaults
{
	return [[DHUserDefaults alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

//
// Forward any NSUserDefaults to the proxy
// This allows using synchronize, setObject:forKey:, etc on a DHUserDefaults
//
- (id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([NSUserDefaults instancesRespondToSelector:aSelector])
	{
		return def;
	}
	
	return self;
}

//
// Parses "setSomething:" or "something" selectors to "something"
//
- (NSString *) propertyNameFromSelectorString:(NSString *)stringSelector
{
	int parameterCount = [[stringSelector componentsSeparatedByString:@":"] count]-1;

	if (parameterCount == 0)
	{
		return stringSelector;
	}
	
	if (parameterCount == 1 && [stringSelector hasPrefix:@"set"])
	{
		return [NSString stringWithFormat:@"%@%@",
					 [[stringSelector substringWithRange:NSMakeRange(3, 1)] lowercaseString],
					 [stringSelector substringWithRange:NSMakeRange(4, [stringSelector length]-5)]];
	}
	
	return nil;
}

//
// Constructs a method signature (looks like "v@:i" to set an integer or "v@:@" to set an object, etc)
// Required for forwardInvocation to work
//
- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	NSString *stringSelector = NSStringFromSelector(sel);
	NSString *propName = [self propertyNameFromSelectorString:stringSelector];
	unichar type = [self typeForProperty:propName];

	if (propName && type > 0)
	{
		NSString *signature;
		
		if ([stringSelector rangeOfString:@":"].location == NSNotFound)
		{
			signature = [NSString stringWithFormat:@"%C%s%s",type,@encode(id),@encode(SEL)];
		}
		else
		{
			signature = [NSString stringWithFormat:@"%s%s%s%C",@encode(void),@encode(id),@encode(SEL),type];
		}

		return [NSMethodSignature signatureWithObjCTypes:[signature UTF8String]];
	}
	
	return nil;
}

//
// Pick up any "method missings" that match a method with no parameters or a setX: method
// - Constructs "xForKey:" or "setX:forKey:" based on property type
// - Calls the constructed method on the proxy `def` object
// - Makes `invocation` return the return value from that method
//
- (void) forwardInvocation:(NSInvocation *)invocation
{	
	NSString *stringSelector = NSStringFromSelector(invocation.selector);
	NSString *propName = [self propertyNameFromSelectorString:stringSelector];
	unichar type = [self typeForProperty:propName];
	
	if (propName && type > 0)
	{
		NSString *selectorElement = (type == '@' ? @"object" : 
									 type == 'i' ? @"integer" :
									 type == 'l' ? @"integer" :
									 type == 'c' ? @"bool" :
									 type == 'f' ? @"float" : 
									 type == 'd' ? @"double" : nil);
		
		if ([stringSelector rangeOfString:@":"].location == NSNotFound)
		{
			NSString *defaultsSelectorName = [NSString stringWithFormat:@"%@ForKey:",selectorElement];
			
			SEL selector = NSSelectorFromString(defaultsSelectorName);
			
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[def methodSignatureForSelector:selector]];
			inv.selector = selector;
			inv.target = def;

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
				[invocation setReturnValue:&ret];
			}
		}
		else
		{
			NSString *defaultsSelectorName = [NSString stringWithFormat:@"set%@:forKey:",[selectorElement capitalizedString]];
			
			SEL selector = NSSelectorFromString(defaultsSelectorName);
			
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[def methodSignatureForSelector:selector]];
			inv.selector = selector;
			inv.target = def;
			
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
				[inv setArgument:&param atIndex:2];
			}

			[inv invoke];
		}
	}
	else
	{
		[super forwardInvocation:invocation];
	}
}

- (BOOL) respondsToSelector:(SEL)aSelector
{
	return !![self methodSignatureForSelector:aSelector];
}

@end
