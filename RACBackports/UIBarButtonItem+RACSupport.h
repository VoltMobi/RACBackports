//
//  UIBarButtonItem+RACSupport.h
//  ReactiveCocoa
//
//  Created by Kyle LeNeau on 3/27/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UIKit/UIKit.h>

@class RACSignal;

@interface UIBarButtonItem (RACSupport)

/// Sends the receiver whenever the item sends an action message.
///
/// **Note:** Subscribing to this signal will reset the item's target and
/// action. However, this signal can be used simultaneously with `rac_action`.
@property (nonatomic, strong, readonly) RACSignal *rac_actionSignal;

@end
