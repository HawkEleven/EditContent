//
//  UIButton+RACCommandSupport.m
//  ReactiveCocoa
//
//  Created by Ash Furrow on 2013-06-06.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UIButton+RACCommandSupport.h"
#import "EXTKeyPathCoding.h"
#import "RACCommand.h"
#import "RACDisposable.h"
#import "RACSignal+Operations.h"
#import <objc/runtime.h>
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"

static void *UIButtonRACCommandKey = &UIButtonRACCommandKey;
static void *UIButtonEnabledDisposableKey = &UIButtonEnabledDisposableKey;

@implementation UIButton (RACCommandSupport)

- (RACCommand *)rac_command {
	return objc_getAssociatedObject(self, UIButtonRACCommandKey);
}

- (void)setRac_command:(RACCommand *)command {
	objc_setAssociatedObject(self, UIButtonRACCommandKey, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	// Check for stored signal in order to remove it and add a new one
	RACDisposable *disposable = objc_getAssociatedObject(self, UIButtonEnabledDisposableKey);
	[disposable dispose];
	
	if (command == nil) return;
	
	disposable = [command.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	objc_setAssociatedObject(self, UIButtonEnabledDisposableKey, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[self rac_hijackActionAndTargetIfNeeded];
}

- (void)rac_hijackActionAndTargetIfNeeded {
	SEL hijackSelector = @selector(rac_commandPerformAction:);
	
	for (NSString *selector in [self actionsForTarget:self forControlEvent:UIControlEventTouchUpInside]) {
		if (hijackSelector == NSSelectorFromString(selector)) {
			return;
		}
	}
	
	[self addTarget:self action:hijackSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void)rac_commandPerformAction:(id)sender {
	[self.rac_command execute:sender];
}

- (RACSignal *)rac_touchupInsideSignal {
    @weakify(self);
    
    return [[RACSignal
             createSignal:^(id<RACSubscriber> subscriber) {
                 @strongify(self);
                 
                 [self addTarget:subscriber action:@selector(sendNext:) forControlEvents:UIControlEventTouchUpInside];
                 [self.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
                     [subscriber sendCompleted];
                 }]];
                 
                 return [RACDisposable disposableWithBlock:^{
                     @strongify(self);
                     [self removeTarget:subscriber action:@selector(sendNext:) forControlEvents:UIControlEventTouchUpInside];
                 }];
             }]
            setNameWithFormat:@"%@ -rac_touchupInsideSignal", RACDescription(self)];
}
@end
