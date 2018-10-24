//
//  YYMemoryCache.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/10/8.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "YYMemoryCache.h"
#import <pthread.h>

static inline dispatch_queue_t YYMemoryCacheGetReleaseQueue(){
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@interface _YYLinkedMapNode : NSObject{
    @package
    __unsafe_unretained _YYLinkedMapNode *_prev;
    __unsafe_unretained _YYLinkedMapNode *_next;
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end

@implementation _YYLinkedMapNode
@end

@interface _YYLinkedMap : NSObject{ //主要通过双链表的形式 来构成LRU算法
    @package
    CFMutableDictionaryRef _dic;
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    
    _YYLinkedMapNode *_head;
    _YYLinkedMapNode *_tail;
    
    BOOL _releaseAsynchronously;
    BOOL _releaseOnMainThread;
}

- (void)insertNodeAtHead:(_YYLinkedMapNode *)node;

- (void)bringNodeToHead:(_YYLinkedMapNode *)node;

- (void)removeNode:(_YYLinkedMapNode *)node;

- (_YYLinkedMapNode *)removeTailNode;

- (void)removeAll;

@end

@implementation _YYLinkedMap

- (instancetype)init{
    self = [super init];
    if (self) {
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _releaseAsynchronously = YES;
        _releaseOnMainThread = NO;
    }
    return self;
}

- (void)dealloc{
    CFRelease(_dic);
}

- (void)insertNodeAtHead:(_YYLinkedMapNode *)node{
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    }else{
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(_YYLinkedMapNode *)node{
    if (_head == node) return;
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    }else{
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(_YYLinkedMapNode *)node{
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_YYLinkedMapNode *)removeTailNode{
    if (!_tail) {
        return nil;
    }
    _YYLinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(_tail->_key));
    
    if (_head == _tail) {
        _head = _tail = nil;
    }else{
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
    
}

- (void)removeAll{
    _head = nil;
    _tail = nil;
    
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder);
            });
        }
        else if (_releaseOnMainThread && !pthread_main_np()){
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(holder); // hold and release in specified queue
            });
        }
        else{
            CFRelease(holder);
        }
        
    }
}

@end


@implementation YYMemoryCache{
    pthread_mutex_t _lock;
    _YYLinkedMap *_lru;
    dispatch_queue_t _queue;
}

#pragma mark -- private

//定时释放  类似定时器的效果  5s一次的递归调用
- (void)_trimRecursively{
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self)  return ;
        [self _trimInBackrground];
        [self _trimRecursively];
        
    });
}

- (void)_trimInBackrground{
    dispatch_async(_queue, ^{
        [self _trimToAge:self->_ageLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToCost:self->_costLimit];
    });
}

- (void)_trimToCost:(NSUInteger)costLimit{
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (_lru->_totalCost <= costLimit)
    {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return ;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit){
                _YYLinkedMapNode *node = [_lru removeTailNode];
                if (node) {
                    [holder addObject:node];
                }
            }
            else{
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }
        else
        {
            usleep(10 * 1000); //10ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseAsynchronously ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
    
}

- (void)_trimToCount:(NSUInteger)countLimit{
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (_lru->_totalCount <= countLimit)
    {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return ;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {  //非阻塞版本 如果 mutex 所引用的互斥对象当前被任何线程（包括当前线程）锁定，则将立即返回该调用
            if (_lru->_totalCount > countLimit){
                _YYLinkedMapNode *node = [_lru removeTailNode];
                if (node) {
                    [holder addObject:node];
                }
            }
            else{
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }
        else
        {
            usleep(10 * 1000); //10ms  如果被其他线程锁定  则休息10ms再去执行
        }
    }
    if (holder.count) {  //对象在别的线程异步释放  对性能进行细微的提高
        dispatch_queue_t queue = _lru->_releaseAsynchronously ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)_trimToAge:(NSTimeInterval)ageLimit{
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit){
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return ;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_tail && (now - _lru -> _tail -> _time) > ageLimit){
                _YYLinkedMapNode *node = [_lru removeTailNode];
                if (node) {
                    [holder addObject:node];
                }
            }
            else{
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }
        else
        {
            usleep(10 * 1000); //10ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseAsynchronously ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)_appDidReceiveMemoryWarningNotification
{
    if (self.didReciveMemoryWarningBlock) {
        self.didReciveMemoryWarningBlock(self);
    }
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)_appDidEnterBackgroundNotification
{
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

#pragma mark -- public

- (instancetype)init
{
    self = [super init];
    pthread_mutex_init(&_lock, NULL);
    _lru = [_YYLinkedMap new];
    _queue = dispatch_queue_create("com.chenyuliang.cache.memory", DISPATCH_QUEUE_SERIAL);
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self _trimRecursively];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
    pthread_mutex_destroy(&_lock);
    
}

- (NSUInteger)totalCost
{
    pthread_mutex_lock(&_lock);
    NSUInteger cost = _lru->_totalCost;
    pthread_mutex_unlock(&_lock);
    return cost;
}

- (NSUInteger)totalCount
{
    pthread_mutex_lock(&_lock);
    NSUInteger count = _lru->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (BOOL)releaseOnMainThread
{
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _lru->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread
{
    pthread_mutex_lock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)releaseAsynchronously
{
    pthread_mutex_lock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
    return releaseAsynchronously;
}

- (void)setReleaseAsynchronously:(BOOL)releaseAsynchronously
{
    pthread_mutex_lock(&_lock);
    _lru->_releaseAsynchronously = releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsObjectForKey:(id)key
{
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_lru->_dic,  (__bridge const void *)key);
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key
{
    if (!key)  return nil;
    pthread_mutex_lock(&_lock);
    _YYLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)key);
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeToHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self setObject:object forKey:key withCost:0];
}


- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost
{
    if (!key)  return;
    if (!object) {
        [self removeObjectForKey:key];
        return ;
    }
    pthread_mutex_lock(&_lock);
    _YYLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)key);
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru bringNodeToHead:node];
        
    }else{
        node = [_YYLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }
    if (_lru->_totalCost>_costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:self->_costLimit];
        });
    }
    
    if (_lru->_totalCount > _countLimit) {
        _YYLinkedMapNode *node = [_lru removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class];
            });
        }else if (_lru->_releaseOnMainThread && !pthread_main_np()){
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
        
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id)key
{
    if (!key)  return;
    pthread_mutex_lock(&_lock);
    _YYLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)key);
    if (node) {
        [_lru removeNode:node];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class];
            });
        }else if (_lru->_releaseOnMainThread && !pthread_main_np()){
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
    }
    pthread_mutex_unlock(&_lock);
    
}

- (void)removeAllObjects
{
    pthread_mutex_lock(&_lock);
    [_lru removeAll];
    pthread_mutex_unlock(&_lock);
    
}

- (void)trimToCost:(NSUInteger)cost
{
    [self _trimToCost:cost];
}

- (void)trimToCount:(NSUInteger)count
{
    [self _trimToCount:count];
}

- (void)trimToAge:(NSTimeInterval)age
{
    [self _trimToAge:age];
}

- (NSString *)description{
    if (_name) {
        return [NSString stringWithFormat:@"<%@: %p> (%@)",self.class,self,_name];
    }else{
        return [NSString stringWithFormat:@"<%@: %p>",self.class,self];
    }
}

@end
