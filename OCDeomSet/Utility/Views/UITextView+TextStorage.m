//
//  UITextView+TextStorage.m
//  OCDeomSet
//
//  Created by ligb on 2018/10/31.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import "UITextView+TextStorage.h"

@interface EmoticonTextAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *emoticonCode;
@property(assign, nonatomic) CGFloat emoticonSize;  //For emoji image size
@end

@implementation EmoticonTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return [self scaleImageSizeToWidth:_emoticonSize];
}

- (CGRect)scaleImageSizeToWidth:(CGFloat)width {
    CGFloat factor = 1.0;
    CGSize oriSize = self.image.size;
    factor = (CGFloat) (width / oriSize.width);
    return CGRectMake(0, 0, oriSize.width * factor, oriSize.height * factor);
}
@end


@implementation UITextView (TextStorage)

- (void)emoticonEncode:(NSString *)encode
           emoticonImg:(UIImage *)img
                  rang:(NSRange)rang
                insert:(BOOL)isInsert {
    EmoticonTextAttachment *emojiTextAttachment = [EmoticonTextAttachment new];
    emojiTextAttachment.emoticonCode = encode;
    emojiTextAttachment.image = img;
    emojiTextAttachment.emoticonSize = 30.0;
    
    NSAttributedString *attring = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];
    if (isInsert) {
        //Insert emoji image
        [self.textStorage insertAttributedString:attring atIndex:rang.location];
        //Move selection location
        self.selectedRange = NSMakeRange(rang.location + 1, rang.length);
        [self.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:rang];
    } else {
        [self.textStorage replaceCharactersInRange:rang withAttributedString:attring];
    }
}

- (NSString *)attstringEncodeEmoticon {
    NSAttributedString *string = self.textStorage;
    NSMutableString *plainString = [NSMutableString stringWithString:string.string];
    __block NSUInteger base = 0;
    [string enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, string.length)
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        if (value && [value isKindOfClass:[EmoticonTextAttachment class]]) {
                            [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                       withString:((EmoticonTextAttachment *) value).emoticonCode];
                            base += ((EmoticonTextAttachment *) value).emoticonCode.length - 1;
                        }
                    }];
    return plainString;
}

@end
