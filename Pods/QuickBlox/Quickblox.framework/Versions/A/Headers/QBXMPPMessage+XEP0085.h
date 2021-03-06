#import <Foundation/Foundation.h>
#import "QBXMPPMessage.h"


@interface QBXMPPMessage(XEP0085)

- (NSString *)chatState;

- (BOOL)hasChatState;

- (BOOL)hasActiveChatState;
- (BOOL)hasComposingChatState;
- (BOOL)hasPausedChatState;
- (BOOL)hasInactiveChatState;
- (BOOL)hasGoneChatState;

- (void)addActiveChatState;
- (void)addComposingChatState;
- (void)addPausedChatState;
- (void)addInactiveChatState;
- (void)addGoneChatState;

@end