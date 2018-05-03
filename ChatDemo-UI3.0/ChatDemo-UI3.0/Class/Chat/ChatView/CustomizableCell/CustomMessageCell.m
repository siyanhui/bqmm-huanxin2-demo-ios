//
//  CustomMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 15/8/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "CustomMessageCell.h"
#import "EMBubbleView+Gif.h"
#import "EMGifImage.h"
#import "UIImageView+HeadImage.h"
#import "UIImageView+WebCache.h"

#import "EaseMob.h"

//BQMM集成
#import <BQMM/BQMM.h>
#import "EMBubbleView+MMText.h"
#import "MMTextView.h"


@interface CustomMessageCell ()

@end

@implementation CustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    BOOL flag = NO;
    switch (model.bodyType) {
        case eMessageBodyType_Text:
        {
            if ([model.mmExt objectForKey:@"em_emotion"]) {
                flag = YES;
            }
            else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
                flag = YES;
            }
            else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
                flag = YES;
            }else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
                flag = YES;
            }
        }
            break;
        default:
            break;
    }    return flag;

}

//BQMM集成
- (void)setCustomModel:(id<IMessageModel>)model
{
    self.contentView.backgroundColor = [UIColor clearColor];
    if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView.textView setMmTextData:model.mmExt[@"msg_data"]];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        //大表情显示
        self.bubbleView.backgroundColor = [UIColor clearColor];
        self.bubbleView.imageView.backgroundColor = [UIColor clearColor];
        
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSString *emojiCode = nil;
        if (model.mmExt[TEXT_MESG_DATA]) {
            emojiCode = model.mmExt[TEXT_MESG_DATA][0][0];
        }
        //兼容1.0之前（含）版本的消息格式
        else {
            emojiCode = model.text;
        }
        
        if (emojiCode != nil && emojiCode.length > 0) {
            self.bubbleView.imageView.errorImage = [UIImage imageNamed:@"mm_emoji_error"];
            self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
            [self.bubbleView.imageView setImageWithEmojiCode:emojiCode];
        }else {
            self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
        }
        
    }else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        
        self.bubbleView.backgroundColor = [UIColor clearColor];
        self.bubbleView.imageView.backgroundColor = [UIColor clearColor];
        
        
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];
        NSString *webStickerUrl = msgData[WEBSTICKER_URL];
        NSString *webStickerId = msgData[WEBSTICKER_ID];
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        self.bubbleView.imageView.errorImage = [UIImage imageNamed:@"mm_emoji_error"];
        [self.bubbleView.imageView setImageWithUrl:webStickerUrl gifId:webStickerId];
    }else{
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

//BQMM集成
- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView setupMMTextBubbleViewWithModel:model];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"] || [model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
}

//BQMM集成
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView updateMMTextMargin:bubbleMargin];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"] || [model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }

}

//BQMM集成
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        return model.isSender?@"EaseMessageCellSendMMText":@"EaseMessageCellRecvMMText";
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }else if([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        return model.isSender?@"EaseMessageCellSendWebSticker":@"EaseMessageCellRecvWebSticker";
    }
    else {
        NSString *identifier = [EaseBaseMessageCell cellIdentifierWithModel:model];
        return identifier;
    }
}

//BQMM集成
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        return 100;
    }
    else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}

@end
