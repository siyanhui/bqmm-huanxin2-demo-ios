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
    if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView.textView setMmTextData:model.mmExt[@"msg_data"]];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        //大表情显示
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSArray *codes = nil;
        if (model.mmExt[@"msg_data"]) {
            codes = @[model.mmExt[@"msg_data"][0][0]];
        }
        //兼容1.0之前（含）版本的消息格式
        else {
            codes = @[model.text];
        }
        __weak typeof(self) weakSelf = self;
        [[MMEmotionCentre defaultCentre] fetchEmojisByType:MMFetchTypeBig codes:codes completionHandler:^(NSArray *emojis) {
            if (emojis.count > 0) {
                MMEmoji *emoji = emojis[0];
                if ([weakSelf.model.mmExt[@"msg_data"][0][0] isEqualToString:emoji.emojiCode]) {
                    weakSelf.bubbleView.imageView.image = emoji.emojiImage;
                }
            }
            else {
                weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
            }
        }];
        
    }else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        self.bubbleView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];
        NSString *webStickerUrl = msgData[WEBSTICKER_URL];
        NSURL *url = [[NSURL alloc] initWithString:webStickerUrl];
        if (url != nil) {
            __weak typeof(self) weakSelf = self;
            [self.bubbleView.imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageAvoidAutoSetImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if(error == nil && image) {
                    if (image.images.count > 1) {
                        weakSelf.bubbleView.imageView.animationImages = image.images;
                        weakSelf.bubbleView.imageView.image = image.images[0];
                        weakSelf.bubbleView.imageView.animationDuration = image.duration;
                        [weakSelf.bubbleView.imageView startAnimating];
                    }else{
                        weakSelf.bubbleView.imageView.image = image;
                    }
                }else{
                    weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
                }
            }];
        }else{
            self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
        }
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
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return kEMMessageImageSizeHeight;
    }else if([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        return model.gifSize.height;
    }
    else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}

@end
