**DHUserDefaults**
=======
A class that uses some Cocoa magic like message forwarding and KVO to ease a lot of NSUserDefaulting pain.

****

I'm talking about this:

```objc
[[NSUserDefaults standardUserDefaults] setObject:@"hello" forKey:@"someSetting"];
```
```objc
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSMutableArray *theArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"array"]];
[theArray addObject:@"hi"];
[defaults setObject:theArray forKey:@"array"];
```
```objc
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"dict"]];
[theDict setObject:[NSNumber numberWithInt:5] forKey:@"someInteger"];
[defaults setObject:theDict forKey:@"dict"];
```

into this:

```objc
[DHUserDefaults defaults].someSetting = @"hello";
```
```objc
[[DHUserDefaults defaults].array addObject:@"hi"];
```
```objc
[DHUserDefaults defaults].dict.someInteger = 5;
```

### **o_o**

********

********

*********

# WARNINGWARNINGWARNINGWARNINGWARNINGWARNING

**I 100% discourage you from using this.** It was a fun project and all and would've been cool but performs **horribly** in a production app. Forwarding invocations and constructing method signatures and everything is (to my surprise) a giant CPU drain.

Your app **will** experience very significant lag whenever accessing NSUserDefaults through DHUserDefaults. I've even implemented several solutions like mirroring and caching (both of which you can check out the branches for), but nothing worked in the end like good ol' `[[NSUserDefaults standardUserDefaults] objectForKey:]`. Stick with it.

Sorry!

-Dan

PS: You *could* dispatch all your gets and sets asynchronously, but that's just more trouble. If you hate writing it out *that much* (as I do) write up some macros!

******

********

*********

How do I use this thing?
--------------

Drop the sources into your project. (If you're using ARC, you'll need to disable it for DHUserDefaults. Go to your active target, select "Build Phases", and add `-fno-objc-arc` to the DHUserDefaults source files in the "Compile Sources" section.)

Define a category for **DHUserDefaults** in a .h file:

```objc
#import "DHUserDefaults.h"

@interface DHUserDefaults (MyApp)
@end

@implementation DHUserDefaults (MyApp)
@end
```
 
Now, give it some flavor. Add some properties, each declared as `@dynamic` in the implementation:

```objc
@interface DHUserDefaults (MyApp)

@property NSInteger configInt;
@property NSString *configString;
@property (getter = isConfigBool) BOOL configBool;

@end


@implementation DHUserDefaults (MyApp)
@dynamic configInt, configString, configBool;

@end
```

That's it! And no need to fumble around with key constants anymore!

Enjoy:

```objc
[DHUserDefaults defaults].configString = @"hi";
// [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:@"configString"];

[DHUserDefaults defaults].configInt = 5;
// [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"configInt"];

BOOL b = [DHUserDefaults defaults].isConfigBool;
// BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"configBool"];
```
 
(or with `[DHUserDefaults standardUserDefaults]` if you prefer.)
 
More magic!
----------

NSUserDefaults only supports immutable arrays and dictionaries, meaning that you have to retrieve your container, mutate it, and then re-set it. DHUserDefaults solves this too.

Given:

```objc
@interface DHUserDefaults (MyApp)

@property NSMutableArray *configArray;
@property DHUserDefaultsDictionary *configDictionary;
// (DHUserDefaultsDictionary used instead of NSMutableDictionary)

@end


@implementation DHUserDefaults (MyApp)
@dynamic configArray, configDictionary;

@end
```

You can very easily update your properties (which can already be mutable), without having to set it back to defaults:

```objc
[[DHUserDefaults defaults].configArray addObject:@"hi"];
// NSMutableArray *theArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"configArray"]];
// [theArray addObject:@"hi"];
// [[NSUserDefaults standardUserDefaults] setObject:theArray forKey:@"configArray"];

[[DHUserDefaults defaults].configDictionary setObject:@"hi" forKey:@"aString"];
// NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"configDictionary"]];
// [theDict setObject:@"hi" forKey:@"aString"];
// [[NSUserDefaults standardUserDefaults] setObject:theDict forKey:@"configDictionary"];
```

Give me more!
---------

_And_, the included **DHUserDefaultsDictionary** class (used instead of NSMutableDictionary, but identical) supports the dot-notation magic too! This is done the same as above, this time defining a category on **DHUserDefaultsDictionary**:

```objc
@interface DHUserDefaultsDictionary (MyApp)

@property NSString *aString;
@property int anInt;  // Bam! Primitive types in a dictionary! (works by autoconversion to/from NSNumber)

@end

@implementation DHUserDefaultsDictionary (MyApp)
@dynamic aString, anInt;

@end
```

Lets you then... (as you can see, it can also be used outside of defaults context)

```objc
DHUserDefaultsDictionary *dict = [DHUserDefaultsDictionary dictionary];

dict.aString = @"hello";
// [dict setObject:@"hello" forKey:@"aString"];

int i = dict.anInt;
// int i = [[dict objectForKey:@"anInt"] intValue];
```

And thus, for the grand finale...

```objc
[DHUserDefaults defaults].configDictionary.aString = @"Hi";
// NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
// NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"configDictionary"]];
// [theDict setObject:@"hi" forKey:@"aString"];
// [defaults setObject:theDict forKey:@"configDictionary"];

[DHUserDefaults defaults].configDictionary.anInt = 5;
// NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
// NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"configDictionary"]];
// [theDict setObject:[NSNumber numberWithInt:5] forKey:@"anInt"];
// [defaults setObject:theDict forKey:@"configDictionary"];
```

For those of you counting every character you type, that's a whopping _**600%**_ greater efficiency.

Message forwarding
--------

Lastly, you can use either of these classes just like you would with their NS counterparts:

```objc
[[DHUserDefaults defaults] synchronize];
```

```objc
DHUserDefaultsDictionary *d = [DHUserDefaultsDictionary dictionary];
[d objectForKey:<a key>];
```

Notes
-------

* Should be available on every iOS/Mac OS version.
* Requires Automatic Reference Counting (ARC) to be _disabled_. If your project is using ARC:
  * After you drop the files in, go to your active target, select "Build Phases", and add `-fno-objc-arc` to the DHUserDefaults source files in the "Compile Sources" section.

License (MIT)
---------

Copyright (c) 2012 Dan Hassin.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
