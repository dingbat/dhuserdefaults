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

Drop the sources into your project and define a category for **DHUserDefaults** in an .h file or something:

```objc
@interface DHUserDefaults (MyApp)
@end

@implementation DHUserDefaults (MyApp)
@end
```
 
Now let's give it some flavor. Add properties, declared as `@dynamic` in the implementation:

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

And that's it!
 
Now what?
----------

Go ahead:

```objc
[DHUserDefaults defaults].configString = @"hi";
// [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:@"configString"];

[DHUserDefaults defaults].configInt = 5;
// [[NSUserDefaults standardUserDefaults] setInteger:@"hi" forKey:@"configInt"];

[DHUserDefaults defaults].isConfigBool;
// [[NSUserDefaults standardUserDefaults] boolForKey:@"configBool"];
```

(or with `[DHUserDefaults standardUserDefaults]` if you prefer.)

* You can use it just like you would with NSUserDefaults:

  ```objc
  [[DHUserDefaults defaults] synchronize];
  ```

* **Plus,** there's no need to fumble around with those key constants anymore!