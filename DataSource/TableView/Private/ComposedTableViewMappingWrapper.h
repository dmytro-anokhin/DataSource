//
//  ComposedTableViewMappingWrapper.h
//
//  Created by Dmytro Anokhin on 25/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//

@import UIKit;

@class ComposedTableViewMapping;


NS_ASSUME_NONNULL_BEGIN


@interface ComposedTableViewMappingWrapper : NSObject

@property (nonatomic, nonnull, readonly) UITableView *wrappedView;
@property (nonatomic, nonnull, readonly) ComposedTableViewMapping *mapping;

- (nullable instancetype)initWithView:(nonnull UITableView *)view mapping:(nonnull ComposedTableViewMapping *)mapping;

+ (nonnull UITableView *)wrapperForTableView:(nonnull UITableView *)tableView mapping:(nonnull ComposedTableViewMapping *)mapping;

@property (nonatomic, nonnull, readonly) UITableView *tableView;

@end


NS_ASSUME_NONNULL_END
