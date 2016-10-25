//
//  NSObjectAdditions.h
//  Test
//
//  Created by justdoit on 12-12-6.
//  Copyright (c) 2012年 tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface NSObject (NSObjectAdditions)

+ (void)printMethods;
- (void)printVariables;

+ (void)printPropertysDefine;
- (void)printPropertys;

- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects;

- (id)shallowCopy;
- (id)deepCopy;

- (BOOL)isEqualTo:(id)object;

- (Class)metaClass;
+ (Class)metaClass;

- (NSUInteger)instanceSize;
+ (NSUInteger)instanceSize;

- (void *)instanceVariable:(const char *)name;

- (void)setAssociatedObjectWithKey:(void *)key value:(id)value policy:(objc_AssociationPolicy)policy;
- (id)getAssociatedObjectWithKey:(void *)key;
- (void)removeAssociatedObjectWithKey:(void *)key;

+ (void)addInstanceMethodWithSelector:(SEL)selector imp:(IMP)imp typeEncoding:(char *)typeEncoding;
+ (void)addInstanceMethodWithSelector:(SEL)selector block:(void(^)(void))block;
+ (void)addClassMethodWithSelector:(SEL)selector imp:(IMP)imp typeEncoding:(char *)typeEncoding;
+ (void)addClassMethodWithSelector:(SEL)selector block:(void(^)(void))block;

+ (void)swizzleInstanceMethod:(SEL)selector otherMethod:(SEL)otherSelector;
+ (void)swizzleClassMethod:(SEL)selector otherMethod:(SEL)otherSelector;

@end
