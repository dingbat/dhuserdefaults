/*
 
 DHUserDefaults.h
 
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
#import "DHPseudoDictionary.h"
#import "DHUserDefaultsDictionary.h"

@interface DHUserDefaults : DHPseudoDictionary <DHPseudoDictionaryObserving>

+ (DHUserDefaults *) standardUserDefaults;
+ (DHUserDefaults *) defaults;

@end

// These aren't actually implemented in DHUserDefaults - these will be forwarded to the internal object
// Xcode gets angry cause it doesn't recognize them though, so here are just some common dictionary methods
// If you need any other ones just add them here
//    NOTE: init methods (or factory methods) WILL NOT WORK HERE - see how +standardUserDefaults is implemented
@interface DHUserDefaults (DHUserDefaultsForwarding)

- (void) synchronize;

@end

