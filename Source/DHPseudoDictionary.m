/*
 
 DHPseudoDictionary.h
 
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

#import "DHPseudoDictionary.h"
#import <objc/runtime.h>

NSString * const DHUserDefaultsFinishedMirrorPropertyNotification	= @"DHUserDefaultsFinishedMirrorPropertyNotification";

@implementation DHPseudoDictionary
@synthesize internalObject, mirrors;

/*******************************************
 Cool stuff
*******************************************/

- (id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.internalObject respondsToSelector:aSelector] && ![self methodSignatureForSelector:aSelector])
		return self.internalObject;
	
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
	unichar type = [[[self class] typeForProperty:propName] characterAtIndex:0];
	
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

- (BOOL) respondsToSelector:(SEL)aSelector
{
	return !![self methodSignatureForSelector:aSelector];
}

/**
 Routes an invocation to either a set or get method, passing in the property
 (These methods need to be implemented in subclasses)
 */
- (void) forwardInvocation:(NSInvocation *)anInvocation
{
	NSString *stringSelector = NSStringFromSelector(anInvocation.selector);
	BOOL setter = ([stringSelector rangeOfString:@":"].location != NSNotFound);
	
	NSString *propName = [[[self class] propertiesByGettersOrSetters:setter] objectForKey:stringSelector];
	
	if (setter)
	{
		[self setInternalValue:propName fromInvocation:anInvocation];
		
		for (NSObject *mirror in mirrors)
		{
			[self mirrorValueFromInvocation:anInvocation useReturnValue:NO ontoObject:mirror forProperty:propName];
		}
	}
	else
	{
		[self returnInternalValue:propName forInvocation:anInvocation];
	}
}

- (void) returnInternalValue:(NSString *)key forInvocation:(NSInvocation *)inv
{
	[NSException raise:@"Abstract class" format:@"returnInternalValue:forInvocation: not defined (tried to access prop %@)",key];
}

- (void) setInternalValue:(NSString *)key fromInvocation:(NSInvocation *)inv
{
	[NSException raise:@"Abstract class" format:@"setInternalValue:fromInvocation: not defined (tried to set prop %@)",key];
}

/*******************************************
 Mirroring
 *****************************************/

- (void) mirrorValue:(id)value ontoObject:(NSObject *)object forProperty:(NSString *)property
{
	NSString *defaultsSelectorName = [self.class setterForProperty:property class:object.class];
	SEL selector = NSSelectorFromString(defaultsSelectorName);
	
	if ([object respondsToSelector:selector])
		[object performSelector:selector withObject:value];
}

- (void) mirrorValueFromInvocation:(NSInvocation *)invocation useReturnValue:(BOOL)ret ontoObject:(NSObject *)object forProperty:(NSString *)property
{
	NSString *propType = [self.class typeForProperty:property class:object.class];
	if (!propType)
		return;
		
	unichar type = [propType characterAtIndex:0];
	
	NSString *defaultsSelectorName = [self.class setterForProperty:property class:object.class];
	
	SEL selector = NSSelectorFromString(defaultsSelectorName);
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
	inv.selector = selector;
	inv.target = object;
		
	if (type == 'i')
	{
		int param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'l')
	{
		long param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'c')
	{
		BOOL param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'f')
	{
		float param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	else if (type == 'd')
	{
		double param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	else
	{
		id param;
		if (!ret)
			[invocation getArgument:&param atIndex:2];
		else
			[invocation getReturnValue:&param];
		[inv setArgument:&param atIndex:2];
	}
	
	[inv invoke];
}

- (void) mirrorPropertiesToObject:(id)object
{
	if (!mirrors)
	{
		self.mirrors = [[NSMutableArray alloc] init];
	}
	
	[mirrors addObject:object];
}

- (void) mirrorPropertiesAsync
{
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		[self mirrorProperties];
	});
}

- (void) mirrorProperties
{
	if (mirrors.count == 0)
		return;
	
	NSDictionary *properties = [self.class propertiesByGettersOrSetters:0];
	for (NSString *getter in properties)
	{
		SEL sel = NSSelectorFromString(getter);
		NSString *property = [properties objectForKey:getter];
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
		inv.target = self;
		inv.selector = sel;
		
		[inv invoke];
		
		for (NSObject *mirror in mirrors)
		{
			[self mirrorValueFromInvocation:inv useReturnValue:YES ontoObject:mirror forProperty:property];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:DHUserDefaultsFinishedMirrorPropertyNotification
														object:self userInfo:[NSDictionary dictionaryWithObject:property forKey:@"keyPath"]];
	}
}


/*******************************************
 Introspection
 *****************************************/

+ (NSString *) getAttributeForProperty:(NSString *)prop prefix:(NSString *)attrPrefix class:(Class)class
{
	objc_property_t property = class_getProperty(class, [prop UTF8String]);
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

+ (NSString *) typeForProperty:(NSString *)prop
{
	return [self getAttributeForProperty:prop prefix:@"T" class:self];
}

+ (NSString *) typeForProperty:(NSString *)prop class:(Class)c
{
	return [self getAttributeForProperty:prop prefix:@"T" class:c];
}

+ (NSString *) getterForProperty:(NSString *)prop
{
	NSString *s = [self getAttributeForProperty:prop prefix:@"G" class:self];
	if (!s)
		s = prop;
	
	return s;
}

+ (NSString *) setterForProperty:(NSString *)prop class:(Class)c
{
	NSString *s = [self getAttributeForProperty:prop prefix:@"S" class:c];
	if (!s)
	{
		NSString *uppercaseProp = [[[prop substringToIndex:1] uppercaseString] stringByAppendingString:[prop substringFromIndex:1]];
		s = [NSString stringWithFormat:@"set%@:",uppercaseProp];
	}
	
	return s;
}

+ (NSString *) setterForProperty:(NSString *)prop
{
	return [self setterForProperty:prop class:self];
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


- (void) dealloc
{
	[mirrors release];
	[internalObject release];
	
	[super dealloc];
}


@end

