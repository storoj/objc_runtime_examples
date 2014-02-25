//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//

@interface Observer : NSProxy
+ (instancetype)observerWithObject:(id)object;
@end
