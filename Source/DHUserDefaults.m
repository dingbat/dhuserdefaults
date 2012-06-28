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
@implementation DHPseudoDictionary (DHIntrospection)

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

@end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface DHPseudoDictionary (private)

//methods to override
- (void) returnInternalValue:(NSString *)key forInvocation:(NSInvocation *)inv;
- (void) setInternalValue:(NSString *)key fromInvocation:(NSInvocation *)inv;

@end

@interface DHUserDefaults (private)

- (id) initWithDefaults:(NSUserDefaults *)defaults;

- (void) dictionaryUpdated:(NSDictionary *)dict context:(NSString *)context;

@end

@interface DHPseudoDictionary (synth)
@property (nonatomic, assign) id internalObject;
@end

@implementation DHPseudoDictionary (synth)
@dynamic internalObject;

- (void) setInternalObject:(id)internalObject
{
	_internalObject = internalObject;
}

- (id) internalObject
{
	return _internalObject;
}

@end

@implementation DHPseudoDictionary

- (id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.internalObject respondsToSelector:aSelector])
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
	[NSException raise:@"Abstract class" format:@"setInternalValue:forKey: not defined (tried to set prop %@)",key];
}

@end

@interface DHUserDefaultsDictionary (private)

- (void) setObserver:(id)o withContext:(NSString *)c;

@end

@implementation DHUserDefaultsDictionary

- (void) setObserver:(id)o withContext:(NSString *)c
{
	context = c;
	observer = o;
}

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

- (void) setRepresentationAsArgumentToInvocation:(NSInvocation *)inv atIndex:(NSInteger)idx
{
	NSDictionary *dict = self.internalObject;
	[inv setArgument:&dict atIndex:idx];
}

- (void) setObject:(id)obj forKey:(id)aKey
{
	[self.internalObject setObject:observer forKey:aKey];
	
	[observer dictionaryUpdated:self.internalObject context:context];
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
	
	id obj = [self.internalObject objectForKey:propName];
	
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
			[param setRepresentationAsArgumentToInvocation:inv atIndex:2];
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
