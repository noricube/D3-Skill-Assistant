//
//  D3KeyTextField.m
//  d3key
//
//  Created by sunghyuk-imac on 2016. 3. 4..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import "D3KeyTextField.h"
#import "D3KeyConfigService.h"
#import "KeyEventCaptureService.h"

@implementation D3KeyTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)becomeFirstResponder {
    BOOL flag=[super becomeFirstResponder];
    
    if(flag)
    {
        // text field will become first responder
        [[KeyEventCaptureService sharedService] registerEvent:self];    
    }
    
    return flag;
}


@end
