//
//  D3KeyConfigService.h
//  d3key
//
//  Created by sunghyuk-imac on 2016. 3. 7..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "D3KeyConfig.h"

@interface D3KeyConfigService : NSObject

@property (assign) BOOL active;

+ (D3KeyConfigService *) sharedService;

- (CGKeyCode) keyCodeWithString:(NSString *) string;
- (NSString *) stringWithKeycode:(CGKeyCode) keyCode;

- (D3KeyConfig *) loadConfig:(NSString *) configId;
- (void) saveConfig:(D3KeyConfig *) config withConfigId:(NSString *) configId;
@end
