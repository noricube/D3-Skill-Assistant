//
//  KeyEventCaptureService.h
//  d3key
//
//  Created by sunghyuk-imac on 2016. 3. 8..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "D3KeyTextField.h"

@interface KeyEventCaptureService : NSObject

@property (nonatomic, strong) D3KeyTextField *textField;

+ (KeyEventCaptureService *) sharedService;

- (void) registerEvent:(D3KeyTextField *) textField;
- (void) removeEvent;

@end
