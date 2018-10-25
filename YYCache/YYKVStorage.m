//
//  YYKVStorage.m
//  YLUikit
//
//  Created by didi on 2018/10/24.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "YYKVStorage.h"

#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif

static const NSUInteger kMaxErrorRetryCount = 8;
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
static const int kPathLengthMax = PATH_MAX - 64;
static NSString * const kDBFileName = @"mainfest.sqlite";
static NSString *const kDBShmFileName = @"manifest.sqlite-shm";
static NSString *const kDBWalFileName = @"manifest.sqlite-wal";
static NSString * const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";



@implementation YYKVStorage
{
    NSString *_path;
    NSString *_dbPath;
    NSString *_dataPath;
    
    sqlite3 *_db;
    CFMutableDictionaryRef _dbStmtCache;
    NSTimeInterval _dbLastOpenErrorTime;
    NSUInteger _dbOpenErrorCount;
}

#pragma mark _db Methods

- (BOOL)_dbOpen{
    if (_db) return YES;
    
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        _dbLastOpenErrorTime = 0;
        _dbOpenErrorCount = 0;
        return YES;
    }
    else
    {
        _db = NULL;
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        _dbOpenErrorCount ++ ;
        if (_errorLogsEnabled) {
            NSLog(@"%s line: %d sqlite open failed (%d).",__FUNCTION__,__LINE__,result);
        }
        return NO;
    }
    
}

- (BOOL)_dbClose{
    if (!_db) return YES;
    
    int result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil))!=0) {
                    sqlite3_finalize(stmt); //
                    retry = YES;
                }
                
            }
        }
        else if(result != SQLITE_OK){
            if (_errorLogsEnabled) {
                NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
            }
        }
        
    } while (retry);
    _db = NULL;
    return YES;
}

- (BOOL)_dbCheck{
    if (!_db) {
        if (_dbOpenErrorCount < kMaxErrorRetryCount && CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
            return [self _dbOpen] && [self _dbInitialize];
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

/*
 WAL(write ahead logging)一种日志模式，事务执行变更，修改数据页会产生日志
 synchronous off 事务提交，不作synchronous操作，直接返回  NORMAL 日志头不作sync操作 FULL 强制刷日志(WAL)，强制数据页(journal)
 
 
 
*/
- (BOOL)_dbInitialize{
    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal;create table if not exists manifest (key text,filename text,size integer, inline_data blob,modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on  manifest(last_access_time);";
    return [self _dbExecute:sql];
}

- (BOOL)_dbExecute:(NSString *)sql{
    if (sql.length == 0) return NO;
    if (![self _dbCheck]) return NO;
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        if (_errorLogsEnabled) {
            NSLog(@"%s line: %d sqlite exec error (%d):%s.",__FUNCTION__,__LINE__,result,error);
        }
        sqlite3_free(error);
    }
    
    return result == SQLITE_OK;
}

#pragma mark -- private


- (void)_reset{
    
}

#pragma mark -- public

- (instancetype)initWithPath:(NSString *)path type:(YYKVStorgeType)type
{
    if (path.length == 0 || path.length > kPathLengthMax ) {
        NSLog(@"YYKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    if (type > YYKVStorgeTypeMixed) {
        NSLog(@"YYKVStorage init error: invalid path: [%lu].", (unsigned long)type);
        return nil;
    }
    
    self = [super init];
    _path = path.copy;
    _type = type;
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    
    if (![self _dbOpen] || ![self _dbInitialize]) {
        //db create faile,maybe broken
        [self _dbClose];
        [self _reset];
        
    }
    
    return self;
}


@end
