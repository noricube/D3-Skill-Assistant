//
//  D3DelayTextField.m
//  d3key
//
//  Created by sunghyuk-imac on 2016. 3. 8..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import "D3DelayTextField.h"
#import "KeyEventCaptureService.h"

@implementation D3DelayTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)becomeFirstResponder {
    BOOL flag=[super becomeFirstResponder];
    
    if(flag)
    {
        // text field will become first responder
        [[KeyEventCaptureService sharedService] removeEvent];
        [self performSelector:@selector(selectText:) withObject:self afterDelay:0];
    }
    
    return flag;
}

@end
