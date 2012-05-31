**DHUserDefaults**
=======
A class that uses some Cocoa message forwarding magic to make setting and retrieving NSUserDefaults easier.

****

I'm talking about this:

```objc
[[NSUserDefaults standardUserDefaults] setObject:@"hello" forKey:@"someSetting"];
```

into this:

```objc
[DHUserDefaults defaults].someSetting = @"hello";
```

With hardly any work!


How do I use this thing?
--------------

First, define a category of DHUserDefaults for your app in a .h file or something:

```objc
@interface DHUserDefaults (YourApp)
@end

@implementation DHUserDefaults (YourApp)
@end
```
 
Now give it some flavor. Add the keys you use often as properties, declared as `@dynamic`.

```objc
@interface DHUserDefaults (YourApp)

@property (nonatomic, strong) NSString *configString;
@property (nonatomic)         NSInteger configInt;

@end


@implementation DHUserDefaults (YourApp)
@dynamic configString, configInt;

@end
```

And that's it!
 
Well,
----------

```objc
[DHUserDefaults defaults].configString = @"hi";
// [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:@"configString"];

[DHUserDefaults defaults].configString;
// [[NSUserDefaults standardUserDefaults] objectForKey:@"configString"];


[DHUserDefaults defaults].configInt = 5;
// [[NSUserDefaults standardUserDefaults] setInteger:@"hi" forKey:@"configInt"];

[DHUserDefaults defaults].configInt;
// [[NSUserDefaults standardUserDefaults] integerForKey:@"configInt"];
```

isn't that nice?

* Plus, there's no need to define key constants anymore!