//
//  DTSRTableViewProxy.h
//  DataSource
//
//  Created by Dmytro Anokhin on 04/09/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

@import UIKit;

@class TableViewSectionMapping;

NS_ASSUME_NONNULL_BEGIN


@interface DTSRTableViewProxy : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) TableViewSectionMapping *mapping;

+ (UITableView *)proxyWithTableView:(UITableView *)tableView mapping:(TableViewSectionMapping *)mapping;

- (instancetype)initWithTableView:(UITableView *)tableView mapping:(TableViewSectionMapping *)mapping;

@end


NS_ASSUME_NONNULL_END
