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
}
@end

@implementation _YYLinkedMapNode
@end

@interface _YYLinkedMap : NSObject{
    @package
    CFMutableDictionaryRef _dic;
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


@implementation YYMemoryCache

@end
