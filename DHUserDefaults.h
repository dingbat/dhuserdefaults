//
//  DHUserDefaults.h
//  DHUserDefaults
//
//  Created by Dan Hassin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 How do I use this thing?
 
 Well, define a category of DHUserDefaults for your app in a .h file or something:
 
	 @interface DHUserDefaults (YourApp)
	 @end
 
	 @implementation DHUserDefaults (YourApp)
	 @end
 
 Now let's make it a bit more interesting with some properties (with @dynamics in the implementation):

	 @interface DHUserDefaults (YourApp)
	 
	 @property (nonatomic, strong) NSString *configString;
	 @property (nonatomic) NSInteger configInt;

	 @end

 
	 @implementation DHUserDefaults (YourApp)
	 @dynamic configString, configInt;
 
	 @end

 And that's it!
 
 Now you can call:
 
	[DHUserDefaults standardUserDefaults].configString = @"hi"
	[DHUserDefaults standardUserDefaults].config2 = 55
 
 And gets:

	[DHUserDefaults standardUserDefaults].configString
	[DHUserDefaults standardUserDefaults].config2
 
 
 And everything'll be saved to NSUserDefaults!
 
	[DHUserDefaults standardUserDefaults].configString = @"hi"
	// === [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:@"configString"]
 
	[DHUserDefaults standardUserDefaults].configString
	// === [[NSUserDefaults standardUserDefaults] objectForKey:@"configString"]
	

	[DHUserDefaults standardUserDefaults].configInt = 5
	// === [[NSUserDefaults standardUserDefaults] setInteger:@"hi" forKey:@"configInt"]
 
	[DHUserDefaults standardUserDefaults].configInt
	// === [[NSUserDefaults standardUserDefaults] integerForKey:@"configInt"]

 */

//Subclasses NSUserDefaults so that Xcode doesn't get angry when calling NSUserDefaults methods
//  (will just forward those methods to `def` anyway)
@interface DHUserDefaults : NSUserDefaults
{
	NSUserDefaults *def;
}

+ (DHUserDefaults *) standardUserDefaults;

@end
