//
//  DHUserDefaultsDictionary.h
//  DHUserDefaults
//
//  Created by Dan Hassin on 6/28/12.
//
//

#import "DHPseudoDictionary.h"

@class DHUserDefaultsDictionary;

@protocol DHPseudoDictionaryObserving <NSObject>

- (void) pseudoDictionaryWasModified:(DHUserDefaultsDictionary *)dict;

@end

@interface DHUserDefaultsDictionary : DHPseudoDictionary <DHPseudoDictionaryObserving>

- (id) init;
- (id) initWithDictionary:(NSDictionary *)dict;

+ (DHUserDefaultsDictionary *) dictionary;
+ (DHUserDefaultsDictionary *) dictionaryWithDictionary:(NSDictionary *)dict;

@property (nonatomic, assign) id<DHPseudoDictionaryObserving> observer;
@property (nonatomic, retain) NSString *observerContext;

@end


// These aren't actually implemented in DHUserDefaultsDictionary - these will be forwarded to the internal object
// Xcode gets angry cause it doesn't recognize them though, so here are just some common dictionary methods
// If you need any other ones just add them here
//    NOTE: init methods (or factory methods) WILL NOT WORK HERE - see how -init and +dictionary etc are implemented
@interface DHUserDefaultsDictionary (DHUserDefaultsDictionaryForwarding)

- (int) count;
- (NSArray *) allKeys;
- (NSArray *) allValues;
- (void) setObject:(id)obj forKey:(id)aKey;
- (id) objectForKey:(id)aKey;

@end