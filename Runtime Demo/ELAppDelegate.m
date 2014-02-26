//
//  ELAppDelegate.m
//  Runtime Demo
//
//  Created by Alexey Storozhev on 25.02.14.
//  Copyright (c) 2014 e-Legion. All rights reserved.
//

#import <objc/message.h>
#import "ELAppDelegate.h"
#import "utilities.h"

@interface UIRuntimeConnection : NSObject <NSCoding>

@property (nonatomic, strong) id destination;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) id source;

- (void)connect;
- (void)connectForSimulator;

@end

@interface UIRuntimeEventConnection : UIRuntimeConnection

@property (nonatomic, readonly) SEL action;
@property (nonatomic, assign) UIControlEvents eventMask;
@property (nonatomic, readonly) id target;

@end

@interface UIRuntimeOutletConnection : UIRuntimeConnection
@end

@implementation ELAppDelegate

+ (void)initialize
{
    SEL selector = NSSelectorFromString(@"initWithCoder:");

    Class baseClass = NSClassFromString(@"UIRuntimeConnection");
    Method baseMethod = class_getInstanceMethod(baseClass, selector);

    Class outletClass = NSClassFromString(@"UIRuntimeOutletConnection");

    id(^initWithCoderBlock)(id, id) = ^id(id aSelf, id aDecoder) {
        struct objc_super _super = {
            .receiver = aSelf,
            .super_class = [[aSelf class] superclass]
        };

        return objc_msgSendSuper(&_super, selector, aDecoder);
    };
    IMP initWithCoderImp = imp_implementationWithBlock(initWithCoderBlock);

    class_addMethod(outletClass, selector, initWithCoderImp, method_getTypeEncoding(baseMethod));

    Method outletMethod = class_getInstanceMethod(outletClass, selector);

    method_swizzle1_id(outletMethod, NULL, ^void(UIRuntimeOutletConnection *connection, SEL sel, id arg) {
        NSString *name = [connection label];
        Class sourceClass = [[connection source] class];
        Class destinationClass = [[connection destination] class];

        NSLog(@"%@ got %@ *%@", sourceClass, destinationClass, name);
    });

    Class eventClass = NSClassFromString(@"UIRuntimeEventConnection");
    Method eventMethod = class_getInstanceMethod(eventClass, selector);

    method_swizzle1_id(eventMethod, NULL, ^void(UIRuntimeEventConnection *connection, SEL sel, id arg) {
        NSString *controlEventsString = NSStringFromUIControlEvents([connection eventMask]);

        NSString *action = NSStringFromSelector([connection action]);

        Class sourceClass = [[connection source] class];
        Class targetClass = [[connection target] class];

        NSLog(@"%@ -[%@ %@(%@ *)]", controlEventsString, targetClass, action, sourceClass);
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

@end