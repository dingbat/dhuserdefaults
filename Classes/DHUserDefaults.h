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
 
	 @interface DHUserDefaults (myapp)
	 @end
	 
	 @implementation DHUserDefaults (myapp)
	 @end
 
 Now let's make it a bit more interesting with some properties (with @dynamics in the implementation):

	 @interface DHUserDefaults (myapp)
	 
	 @property (nonatomic, strong) NSString *config1;
	 @property (nonatomic) NSInteger config2;

	 @end

	 @implementation DHUserDefaults (myapp)
	 @dynamic config1, config2;
 
	 @end

 And that's it!
 
 Now you can call:
 
	[DHUserDefaults standardUserDefaults].config1 = @"hi"
	[DHUserDefaults standardUserDefaults].config2 = 55
 
 And gets:

	[DHUserDefaults standardUserDefaults].config1
	[DHUserDefaults standardUserDefaults].config2
 
 
 And everything'll be saved to NSUserDefaults!
 
	[DHUserDefaults standardUserDefaults].config1  === [[NSUserDefaults standardUserDefaults] objectForKey:@"config1"]

 */

//Subclasses NSUserDefaults so that Xcode doesn't get angry when calling NSUserDefaults methods
//  (will just forward those methods to `def` anyway)
@interface DHUserDefaults : NSUserDefaults
{
	NSUserDefaults *def;
}

+ (DHUserDefaults *) standardUserDefaults;

@end
