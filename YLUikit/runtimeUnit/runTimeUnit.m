//
//  runTimeUnit.m
//  YLUikit
//
//  Created by didi on 2018/7/31.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "runTimeUnit.h"
#import "MyClass.h"

@implementation runTimeUnit

- (void)runTest
{
    MyClass *myclass = [MyClass new];
    unsigned int outCount = 0;
    Class cls = myclass.class;
    
    //类名
    NSLog(@"class name : %s",class_getName(cls));
    NSLog(@"============================================");
    
    //父类
    NSLog(@"class name : %s",class_getName(class_getSuperclass(cls)));
    NSLog(@"============================================");
    
    //是否是元累类
    NSLog(@"Myclass is %@ a meta-class",class_isMetaClass(cls)?@"" : @"not");
    NSLog(@"============================================");
    
    //获取元类
    Class meta_class = objc_getMetaClass(class_getName(cls));
    NSLog(@"%s's meta-class is %s",class_getName(cls),class_getName(meta_class));
    NSLog(@"============================================");
    
    //变量实例大小
    NSLog(@"instance size : %zu",class_getInstanceSize(cls));
    NSLog(@"============================================");
    
    //成员变量
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    for (int i = 0 ; i< outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"Instance variable's name : %s at index : %d",ivar_getName(ivar),i);
    }
    free(ivars);
    
    Ivar string = class_getInstanceVariable(cls, "_string");
    if (string != NULL) {
        NSLog(@"instance variable %s",ivar_getName(string));
    }
    NSLog(@"============================================");
    
    
    //属性操作
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i =0 ; i< outCount; i++) {
        objc_property_t property = properties[i];
        NSLog(@"property's name : %s",property_getName(property));
    }
    
    free(properties);
    
    objc_property_t array = class_getProperty(cls, "array");
    if (array != NULL) {
        NSLog(@"peoperty %s",property_getName(array));
    }
    
    NSLog(@"============================================");
    
    //方法操作
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i =0 ; i< outCount; i++) {
        Method method = methods[i];
        NSLog(@"Method's name : %s",method_getName(method));
    }
    
    free(methods);
    
    Method method1 = class_getInstanceMethod(cls, @selector(method1));
    if (method1 != NULL) {
        NSLog(@"method %s",method_getName(method1));
    }
    
    Method classMethod =  class_getClassMethod(cls, @selector(classMewthod1));
    if (classMethod != NULL) {
        NSLog(@"ClassMethod %s",method_getName(classMethod));
    }
    
    NSLog(@"Myclass is %@ responsd to selector : method3WithArg1:arg2",class_respondsToSelector(cls, @selector(method3withArg1:arg2:))? @"" : @"not");
    
    IMP imp = class_getMethodImplementation(cls, @selector(method1));
    imp();
    
    NSLog(@"============================================");
    
    //协议
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(cls, &outCount);
    
    Protocol * protocol;
    for (int i =0 ; i< outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocl name : %s",protocol_getName(protocol));
        NSLog(@"Myclass is %@ responsed to protocol %s",class_conformsToProtocol(cls, protocol) ? @"" : @"not" , protocol_getName(protocol));
    }
    
    NSLog(@"============================================");
}

- (void)creatClassAndObject
{
    /*
     // 创建一个新类和元类
     Class objc_allocateClassPair ( Class superclass, const char *name, size_t extraBytes ); //如果创建的是root class，则superclass为Nil。extraBytes通常为0
     
     // 销毁一个类及其相关联的类
     void objc_disposeClassPair ( Class cls ); //在运行中还存在或存在子类实例，就不能够调用这个。
     
     // 在应用中注册由objc_allocateClassPair创建的类
     void objc_registerClassPair ( Class cls ); //创建了新类后，然后使用class_addMethod，class_addIvar函数为新类添加方法，实例变量和属性后再调用这个来注册类，再之后就能够用了。
     
     */

    Class cls = objc_allocateClassPair(MyClass.class, "MySubClass", 0);
    IMP imp_submethod1 = class_getMethodImplementation([runTimeUnit class], @selector(subMethod));
    class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
    class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
    class_addIvar(cls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");
    
    objc_property_attribute_t type = {"T","@\"NSString\""};
    objc_property_attribute_t ownership = {"C",""};
    objc_property_attribute_t backingivar = {"V","_ivar1"};
    objc_property_attribute_t attrs[] = {type,ownership,backingivar};
    
    class_addProperty(cls, "property2", attrs, 3);
    objc_registerClassPair(cls);
    
    id instance = [[cls alloc] init];
    [instance performSelector:@selector(submethod1)];
    [instance performSelector:@selector(method1)];
    
}

- (void)subMethod
{
    NSLog(@"run sub method 1");
}

- (void)dyCreatObject{
    id theObject = class_createInstance(NSString.class, sizeof(unsigned));
    id str1 = [theObject init];
    NSLog(@"%@",[str1 class]);
    
    id str2 = [NSString new];
    NSLog(@"%@",[str2 class]);
}


 // 修改类实例的实例变量的值
 Ivar object_setInstanceVariable ( id obj, const char *name, void *value );
 // 获取对象实例变量的值
 Ivar object_getInstanceVariable ( id obj, const char *name, void **outValue );
 // 返回指向给定对象分配的任何额外字节的指针
 void * object_getIndexedIvars ( id obj );
 // 返回对象中实例变量的值
 id object_getIvar ( id obj, Ivar ivar );
 // 设置对象中实例变量的值
 void object_setIvar ( id obj, Ivar ivar, id value );
 //修改类实例的实例变量的值

- (void)instanceMethod{
    /*
     // 返回指定对象的一份拷贝
     id object_copy ( id obj, size_t size );
     
     // 释放指定对象占用的内存
     id object_dispose ( id obj );*/
     
    NSObject *a = [NSObject new];
    id newB = object_copy(a,class_getInstanceSize(MyClass.class));
    object_setClass(newB, MyClass.class);
    object_dispose(a);
    
    int numClasses;
    Class *classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        NSLog(@"num of class is %d",numClasses);
        
        for (int i = 0; i<numClasses; i++) {
            Class class = classes[i];
            NSLog(@"class Name %s",class_getName(class));
        }
    }
    
    free(classes);
}

// 获取已注册的类定义的列表
int objc_getClassList ( Class *buffer, int bufferCount );
// 创建并返回一个指向所有已注册类的指针列表
Class * objc_copyClassList ( unsigned int *outCount );
// 返回指定类的类定义
Class objc_lookUpClass ( const char *name );
Class objc_getClass ( const char *name );
Class objc_getRequiredClass ( const char *name );
// 返回指定类的元类
Class objc_getMetaClass ( const char *name );

/*
 实例变量类型，指向objc_ivar结构体的指针，ivar指针地址是根据class结构体的地址加上基地址偏移字节得到的。
 
 typedef struct objc_ivar *Ivar;
 
 struct objc_ivar {
 char *ivar_name OBJC2_UNAVAILABLE; // 变量名
 char *ivar_type OBJC2_UNAVAILABLE; // 变量类型
 int ivar_offset OBJC2_UNAVAILABLE; // 基地址偏移字节
 #ifdef __LP64__
 int space OBJC2_UNAVAILABLE;
 #endif
 }
 
 属性类型，指向objc_property结构体
 typedef struct objc_property *objc_property_t;
 
 objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
 objc_property_t *protocol_copyPropertyList(Protocol *proto, unsigned int *outCount)

 */

- (void)ivarAndProperty{
    //获取属性列表
   // id myclass = objc_getClass("MyClass");
   // unsigned int outCount;
   // objc_property_t *properties = class_copyPropertyList(myclass, &outCount);
    
    //查找属性名称
    const char *property_getName(objc_property_t _Nonnull property) ;
    
    //通过给定的名称来在类和协议中获取属性的引用.
    objc_property_t class_getProperty(Class cls, const char *name);
    objc_property_t protocol_getProperty(Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty);
    
    //发掘属性名称和@encode类型字符串
    const char *property_getAttributes(objc_property_t property);
    
    //从一个类中获取它的属性.
    id myclass = objc_getClass("MyClass");
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(myclass, &outCount);
    
    for (int i = 0; i< outCount; i++) {
        objc_property_t property = properties[i];
        fprintf(stdout, "%s %s\n",property_getName(property),property_getAttributes(property));
    }
    
    
    [[Test alloc] init];
}



- (void)testAssociate{
    //将一个对象连接到其它对象
    static char myKey;
//    objc_setAssociatedObject(self, &myKey, anObject, OBJC_ASSOCIATION_RETAIN);
    //获取一个新的关联的对象
//    id anObject = objc_getAssociatedObject(self, &myKey);
    //使用objc_removeAssociatedObjects函数移除一个关联对象
}




@end
