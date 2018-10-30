/**
 - BKMobile
 - SmiliesManager.m
 - Created by HY on 2018/7/20.
 - Copyright © 2018年 com.mobile-kingdom.bkapps. All rights reserved.
 - 说明：表情管理类，管理表情的下载和使用
 */

#import "SmiliesManager.h"

//保存网络下载的表情数据key值
static NSString * const kSmileyDataKey = @"kSmileyDataKey.plist";//kSmileyDataKey = @"kSmileyDataKey.plist";

//本地存放表情文件的文件夹名称 HKSmiley
static NSString * const kSmileyPath = @"EKSmiley";

@interface SmiliesManager ()
@property (nonatomic, strong) NSMutableArray *smiliesList;
@end

@implementation SmiliesManager

+ (SmiliesManager *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self mDownloadSmilies];
    }
    return self;
}

#pragma mark - 请求表情数据
- (void)mDownloadSmilies {
    NSArray *smileyData = [BKSaveData readArrayByFile:kSmileyDataKey];
    if (smileyData.count) return;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoticon" ofType:@"json"];
    if (!path) return;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    if (json.allKeys.count) {
        NSArray *array = json[@"data"];
        //保存图片数组方便后面
        [BKSaveData writeArrayToFile:array fileName:kSmileyDataKey];
    }
//    if (smileyData.count) {
//        DLog(@"已存在表情库");
//    } else {
//        //重新获取表情文件
//        [BKHttpUtil mHttpWithUrl:BAPI_Smiley parameter:nil response:^(BKNetworkModel *model, NSString *netErr) {
//            if (model.status == 1) {
//                NSArray *bdata = model.data;
//                //保存图片数组方便后面
//                [BKSaveData writeArrayToFile:bdata fileName:SmileyKey];
//            }
//        }];
//    }
}

//根据表情代码，返回本地表情图片
- (UIImage *)coreImageRuleMate:(NSString *)str{
    __block UIImage *image;
    [self.smiliesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SmiliesModel *model = (SmiliesModel *)obj;
        if ([str isEqualToString:model.search] || [model.replace hasSuffix:str]) {
            *stop = true;
            image = [UIImage imageWithContentsOfFile:model.replace];
            return ;
        }
    }];
    return image;
}

//根据表情代码，返回本地表情路径
- (NSString *)coreImagePath:(NSString *)str{
    __block NSString *path = @"";
    [self.smiliesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SmiliesModel *model = (SmiliesModel *)obj;
        if ([str isEqualToString:model.search]) {
            *stop = true;
            path = model.replace;
            return ;
        }
    }];
    return path;
}

//把相对应的表情替换成本地路径地址
- (NSMutableArray *)smiliesArray {
    if ( !_smiliesArray ) {
        _smiliesArray = [[NSMutableArray alloc] initWithCapacity:0];
        //获取表情本地文件（数组）
        NSArray *smiley = [BKSaveData readArrayByFile:kSmileyDataKey];
        [smiley enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *items = obj[@"items"];
            //文件夹名字
            NSString *fileName = obj[@"directory"];
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *replace = obj[@"replace"];
                NSRange range = [replace rangeOfString:[NSString stringWithFormat:@"%@/",fileName]];
                replace = [replace substringFromIndex:range.location];
                NSString *path = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] pathForResource:kSmileyPath ofType:@"bundle"],replace];
                //封装成对象，便于获取
                SmiliesModel *model = [[SmiliesModel alloc] init];
                model.search = obj[@"search"];
                model.replace = path;
                [self.smiliesArray addObject:model];
            }];
        }];
    }
    return _smiliesArray;
}

@end
