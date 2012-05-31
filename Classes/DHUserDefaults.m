//
//  DHUserDefaults.m
//  DHUserDefaults
//
//  Created by Dan Hassin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DHUserDefaults.h"
#import <objc/runtime.h>

@interface DHUserDefaults (private)

- (id) initWithDefaults:(NSUserDefaults *)defaults;

@end

@implementation DHUserDefaults

- (unichar) typeForProperty:(NSString *)prop
{
	//see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
	
	objc_property_t property = class_getProperty(self.class, [prop UTF8String]);
	if (!property)
		return 0;
	
	NSString *atts = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
	//this will return some garbage like "Ti,GgetFoo,SsetFoo:,Vproperty"
	
	NSString *type = [[[atts componentsSeparatedByString:@","] objectAtIndex:0] substringFromIndex:1];
	return [type characterAtIndex:0];
}

- (id) initWithDefaults:(NSUserDefaults *)proxyObj;
{
	self = [super init];
	if (self)
	{
		def = proxyObj;
	}
	return self;
}

+ (id) standardUserDefaults
{
	return [[DHUserDefaults alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (BOOL) respondsToSelector:(SEL)aSelector
{
	return !![self methodSignatureForSelector:aSelector];
}

- (id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([NSUserDefaults instancesRespondToSelector:aSelector])
	{
		return def;
	}
	
	return self;
}

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

@end
