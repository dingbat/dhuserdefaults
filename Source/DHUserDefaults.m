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

/**
 
 Category on NSObject for retrieving properties and getter/setters

 */
@implementation NSObject (DHIntrospection)

+ (NSString *) getAttributeForProperty:(NSString *)prop prefix:(NSString *)attrPrefix
{
	objc_property_t property = class_getProperty(self, [prop UTF8String]);
	if (!property)
		return nil;
	
	// This will return some garbage like "Ti,GgetFoo,SsetFoo:,Vproperty"
	// See https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
	
	NSString *atts = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
	
	for (NSString *att in [atts componentsSeparatedByString:@","])
		if ([att hasPrefix:attrPrefix])
			return [att substringFromIndex:1];
	
	return nil;
}

+ (unichar) typeForProperty:(NSString *)prop
{
	return [[self getAttributeForProperty:prop prefix:@"T"] characterAtIndex:0];
}

+ (NSString *) getterForProperty:(NSString *)prop
{
	NSString *s = [self getAttributeForProperty:prop prefix:@"G"];
	if (!s)
		s = prop;
	
	return s;
}

+ (NSString *) setterForProperty:(NSString *)prop
{
	NSString *s = [self getAttributeForProperty:prop prefix:@"S"];
	if (!s)
	{
		NSString *uppercaseProp = [[[prop substringToIndex:1] uppercaseString] stringByAppendingString:[prop substringFromIndex:1]];
		s = [NSString stringWithFormat:@"set%@:",uppercaseProp];
	}
	
	return s;
}

+ (NSDictionary *) propertiesByGettersOrSetters:(int)getter0setter1
{
	unsigned int propertyCount;
	//copy all properties for self (will be a Class)
	objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
	if (properties)
	{
		NSMutableDictionary *results = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
		
		while (propertyCount--)
		{
			//get each ivar name and add it to the results
			const char *propName = property_getName(properties[propertyCount]);
			
			NSString *prop = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
			NSString *getterSetter;
			if (getter0setter1 == 0)
				getterSetter = [self getterForProperty:prop];
			else
				getterSetter = [self setterForProperty:prop];
			
			[results setObject:prop forKey:getterSetter];
		}
		
		free(properties);	
		return results;
	}
	return nil;
}

@end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


@interface DHUserDefaults (private)

- (id) initWithDefaults:(NSUserDefaults *)defaults;

@end

@implementation DHUserDefaults

static DHUserDefaults *shared = nil;

/**
 
 Returns a "wrapped" NSUserDefaults (instance of DHUserDefaults that'll be used as a proxy)
 
 */
- (id) initWithDefaults:(NSUserDefaults *)proxyObj;
{
	self = [super init];
	if (self)
	{
		def = proxyObj;
	}
	return self;
}

/**
 
 Methods to access standardUserDefaults as an instance of DHUserDefaults 
 
 */
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
	return shared;//[[DHUserDefaults alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

/**
 
 Forward any NSUserDefaults to the proxy.
 This allows using synchronize, setObject:forKey:, etc on a DHUserDefaults
 
 */
- (id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([NSUserDefaults instancesRespondToSelector:aSelector])
	{
		return def;
	}
	
	return self;
}

/**
 
 Constructs a method signature (looks like "v@:i" to set an integer or "v@:@" to set an object, etc)
 Required for forwardInvocation to work.
 
 */
- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	NSString *stringSelector = NSStringFromSelector(sel);
	BOOL setter = ([stringSelector rangeOfString:@":"].location != NSNotFound);
	
	NSString *propName = [[[self class] propertiesByGettersOrSetters:setter] objectForKey:stringSelector];
	unichar type = [[self class] typeForProperty:propName];
	
	if (propName && type > 0)
	{
		NSString *signature;
		
		if (setter)
		{
			signature = [NSString stringWithFormat:@"%s%s%s%C",@encode(void),@encode(id),@encode(SEL),type];
		}
		else
		{
			signature = [NSString stringWithFormat:@"%C%s%s",type,@encode(id),@encode(SEL)];
		}
		
		return [NSMethodSignature signatureWithObjCTypes:[signature UTF8String]];
	}
	
	return nil;
}

/**
 
 Pick up any "method missings" that match a getter/setter
 - Constructs "xForKey:" or "setX:forKey:" based on property type
 - Calls the constructed method on the proxy `def` object
 - Makes `invocation` return the return value from that method
 
 */
- (void) forwardInvocation:(NSInvocation *)invocation
{	
	NSString *stringSelector = NSStringFromSelector(invocation.selector);
	BOOL setter = ([stringSelector rangeOfString:@":"].location != NSNotFound);
	
	NSString *propName = [[[self class] propertiesByGettersOrSetters:setter] objectForKey:stringSelector];
	unichar type = [[self class] typeForProperty:propName];
	
	if (propName && type > 0)
	{
		//Supports all the types supported by NSUserDefaults methods
		NSString *selectorElement = (type == '@' ? @"object" : 
									 type == 'i' ? @"integer" :
									 type == 'l' ? @"integer" :
									 type == 'c' ? @"bool" :
									 type == 'f' ? @"float" : 
									 type == 'd' ? @"double" : nil);
		
		if (!setter)
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
				
				if ([ret isKindOfClass:[NSArray class]])
				{
					id new = [self mutableArrayValueForKey:propName];
					[invocation setReturnValue:&new];
				}
				else if ([ret isKindOfClass:[NSDictionary class]])
				{
					id new = [NSMutableDictionary dictionaryWithDictionary:ret];
					[invocation setReturnValue:&new];
				}
				else	
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
