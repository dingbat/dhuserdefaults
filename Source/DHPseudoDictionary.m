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

@implementation DHPseudoDictionary
@synthesize internalObject;

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
 Introspection
 *****************************************/

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

+ (NSString *) typeForProperty:(NSString *)prop
{
	return [self getAttributeForProperty:prop prefix:@"T"];
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


- (void) dealloc
{
	[internalObject release];
	
	[super dealloc];
}


@end

