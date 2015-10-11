//
//  UIBarButtonItem+RACSupport.m
//  ReactiveCocoa
//
//  Created by Kyle LeNeau on 3/27/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "UIBarButtonItem+RACSupport.h"

static void *UIBarButtonItemActionDisposableKey = &UIBarButtonItemActionDisposableKey;

@implementation UIBarButtonItem (RACSupport)

- (void)rac_actionReceived:(id)sender {
	RACSubject *subject = objc_getAssociatedObject(self, @selector(rac_actionSignal));
	[subject sendNext:self];
}

- (RACSignal *)rac_actionSignal {
	@weakify(self);
	return [[[RACSignal
		defer:^{
			@strongify(self);

			RACSubject *subject = objc_getAssociatedObject(self, @selector(rac_actionSignal));
			if (subject == nil) {
				subject = [RACSubject subject];
				objc_setAssociatedObject(self, @selector(rac_actionSignal), subject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

				if (self.target != nil) NSLog(@"WARNING: UIBarButtonItem.rac_actionSignal hijacks the item's existing target and action");

				self.target = self;
				self.action = @selector(rac_actionReceived:);
			}

			return subject;
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"UIBarButtonItem -rac_actionSignal"];
}

@end
