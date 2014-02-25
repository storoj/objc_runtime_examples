//
//  ELAppDelegate.m
//  Runtime Demo
//
//  Created by Alexey Storozhev on 25.02.14.
//  Copyright (c) 2014 e-Legion. All rights reserved.
//

#import "ELAppDelegate.h"
#import "utilities.h"

@implementation ELAppDelegate

+ (void)initialize
{
    Class connectionClass = NSClassFromString(@"UIRuntimeConnection");
    Method method = class_getInstanceMethod(connectionClass, NSSelectorFromString(@"initWithCoder:"));

    method_swizzle1_id(method, NULL, ^void(id selfAfter, SEL pSelector, id argument) {
        NSLog(@"%@ %@ %@", [selfAfter valueForKey:@"label"], [[selfAfter valueForKey:@"source"] class], [[selfAfter valueForKey:@"destination"] class]);
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

@end