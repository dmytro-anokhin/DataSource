//
//  ComposedTableViewMappingWrapper.m
//
//  Created by Dmytro Anokhin on 25/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//

#import "ComposedTableViewMappingWrapper.h"

#import "DataSource/DataSource-Swift.h"
#import <objc/runtime.h>


@implementation ComposedTableViewMappingWrapper

+ (nonnull UITableView *)wrapperForTableView:(nonnull UITableView *)tableView mapping:(nonnull ComposedTableViewMapping *)mapping
{
    return [[self alloc] initWithView:tableView mapping:mapping];
}

- (UITableView *)tableView
{
    return self.wrappedView;
}

- (nullable instancetype)initWithView:(nonnull UITableView *)view mapping:(nonnull ComposedTableViewMapping *)mapping
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _wrappedView = view;
    _mapping = mapping;
    
    return self;
}

#pragma mark - Forwarding to internal representation

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _wrappedView;
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super instanceMethodSignatureForSelector:selector];
    if (signature)
        return signature;

    return [[UITableView class] instanceMethodSignatureForSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature)
        return signature;
    else
        return [[self forwardingTargetForSelector:selector] methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [super respondsToSelector:aSelector];
    if (!responds)
        responds = [[self forwardingTargetForSelector:aSelector] respondsToSelector:aSelector];
    return responds;
}

+ (BOOL)instancesRespondToSelector:(SEL)selector
{
    if (!selector)
        return NO;

    if (class_respondsToSelector(self, selector))
        return YES;

    return [UITableView instancesRespondToSelector:selector];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_wrappedView valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [_wrappedView setValue:value forKey:key];
}

@end
