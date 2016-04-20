/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+WebCacheOperation.h"
#import "objc/runtime.h"

static char loadOperationKey;

@implementation UIView (WebCacheOperation)
/**
 *    用运行时获取属性loadOperationKey  如果不存在则创建
 */
- (NSMutableDictionary *)operationDictionary {
    NSMutableDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

/**
 *  添加下载操作
 *
 *  @param operation 要添加的操作
 *  @param key       UIImageViewAnimationImages 一组图片 ：UIImageViewImageLoad ：单张图片
 */

- (void)sd_setImageLoadOperation:(id)operation forKey:(NSString *)key {
    [self sd_cancelImageLoadOperationWithKey:key];   //先取消队列中对应key 的操作类型
    NSMutableDictionary *operationDictionary = [self operationDictionary];   //运用运行时获取操作队列属性
    [operationDictionary setObject:operation forKey:key];   //将要添加的操作加入到操作队列属性
    
}

- (void)sd_cancelImageLoadOperationWithKey:(NSString *)key {
    // Cancel in progress downloader from queue
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]){
            [(id<SDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)sd_removeImageLoadOperationWithKey:(NSString *)key {
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary removeObjectForKey:key];
}

@end
