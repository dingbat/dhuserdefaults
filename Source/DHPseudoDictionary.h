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

#import <Foundation/Foundation.h>

extern NSString * const DHUserDefaultsFinishedMirrorPropertyNotification;

@interface DHPseudoDictionary : NSObject

@property (nonatomic, retain) id internalObject;
@property (nonatomic, retain) NSMutableArray *mirrors;

- (void) mirrorPropertiesToObject:(id)object;
- (void) mirrorValue:(id)value ontoObject:(NSObject *)object forProperty:(NSString *)property;

- (void) mirrorProperties;
- (void) mirrorPropertiesAsync;

@end


@interface DHPseudoDictionary (MethodsToOverride)

//methods to override
- (void) returnInternalValue:(NSString *)key forInvocation:(NSInvocation *)inv;
- (void) setInternalValue:(NSString *)key fromInvocation:(NSInvocation *)inv;

@end


@interface DHPseudoDictionary (DHIntrospection)

+ (NSString *) getAttributeForProperty:(NSString *)prop prefix:(NSString *)attrPrefix;
+ (NSString *) typeForProperty:(NSString *)prop;
+ (NSString *) getterForProperty:(NSString *)prop;
+ (NSString *) setterForProperty:(NSString *)prop;
+ (NSDictionary *) propertiesByGettersOrSetters:(int)getter0setter1;

@end

