//
//  RNAsr.h
//  RNAsr
//
//  Created by YangJiang on 2020/5/14.
//

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

typedef NS_OPTIONS(NSUInteger, AsrStatus) {
   IDLE             = 1 << 0,       /* 空闲状态 */
   RECORDING        = 1 << 1,       /* 正在录音 */
   RECOGNIZING      = 1 << 2,       /* 正在识别 */
};

@interface RNAsr : NSObject <RCTBridgeModule>

@end
  
