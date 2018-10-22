##Effective Objective-c 2.0

##熟悉OBJect-C

###第一节:Objective-C 语言起源
* OC使用消息结构,而非函数调用
 * 使用消息结构的语言,执行代码由运行环境决定
 * 使用函数调用的语言,执行代码由编译器决定
 * OC的重要工作都有“运行期组件”完成.
* OC是C语言的超集
 * **理解C语言的内存模型**
 * **理解C语言的指针**
* 对象内存总分配在堆上,不会分配在栈上.

###第二节:类的头文件少引入其他头文件
* 与C和C++一样,OC使用"头文件 .h"和"实现文件 .m". 如果在头文件引入其他其他类的头文件(.h),就会一并引入所有的内容.
* 头文件引入其他类的头文件会增加编译时间.
* 如果两个类互相引入头文件,会导致死循环,**无法正确被编译**.(比如两个头文件互相引用,其中一个在头文件定义另一个类属性,编译不过去)

* 如果头文件只需要知道类名,则可以在头文件用**@class**向前声明,然后在实现文件引入其他类头文件.**只有在需要时才引入**
* 如果一定要知道其他类的细节,例如其他类里面申明的协议.则可以在实现文件的"class-continuation分类"里面引入头文件,实现协议.

* 在引入头文件之前,确定是否必要,首先用**向前引用**,然后用**"class-continuation分类"**.

###第三节:多用字面变量,少用与之等价的方法.(待确定)

* 字面变量等同于“语法糖”,效果等同于县创建数组(字典),然后把方括号(大括号)内的所有对象加进去.
* 用字面变量创建,在监测到方括号(大括号)里面的对象是nil,会发生**crash,找到问题原因**.
* 用等价的方法会将第一个nil对象前面的对象加入数组(字典),**不好定位到问题所在.**
* 不过对于程序来说,如果不崩溃,并且可以知道加入的对象由nil,出现问题.(1.自己实现创建方法检验 2.hook崩溃的方法,使之不崩溃.3 ?)

###第四节: 多用类型变量,少用#define预处理指令(重点理解)

* 预处理指令只是简单替换,定义出来的**常量**没有类型信息.
* 定义类型变量命名:
 * 在某编译单元内,前面字母加**k**
 * 常量在类之外可见,以类名为前缀.
* Object-C没有“名称空间”,所以预处理和类型常量声明在**头文件**会引起互相冲突,所以加上类的前缀,表明所属的类.
* (私用)不打算公开的常量,声明在**实现文件中**.并且变量一定用**static**和**const**修饰.
 * const不能修改变量.
 * static保证该变量仅在编译单元(.m实现文件)可见.**如果不加static,则会为它创建外部符号,其他编译单元由重名的,会抛出异常**
 * 实现如果变量用const和static同时修饰,编译器不会创建符号,效果等用#define.
* (公用)打算公开常量,这个类的常量需要放在“全局符号表”里,供给其他编译单元可用.一般这样定义:  

```
//.h  
extern NSString * const EOCStringConst;  
//.m
NSString * const EOCStringConst = @"value";
```
 * 理解 * const 和 const *的意思.从右往左读,**常量指针**和**指针常量**.
 * extern告诉编译器,全局符号表里会有叫EOCStringConst的符号,允许代码使用此常量.

###第5节:用枚举表示状态,选项,状态码(重要)
* 表示状态机的状态,状态吗,方法选项等值,不要用魔法数(0,1,2)等表示,要用枚举表示,给这些值起便于理解的名字.
* 多个枚举状态可以组合时,可以将各选项的值定义为2的幂,然后用“按位或操作符”来组合.例如: 
 
```
enum UIViewAutoresizing{
	UIViewAutoresizingNone    = 0,
	UIViewAutoresizingTop     = 1<<0,
	UIViewAutoresizingDown    = 1<<1,
}
enum UIViewAutoresizing resizing = UIViewAutoresizingTop| UIViewAutoresizingDown;
if(resizing & UIViewAutoresizingTop){
   //选择了UIViewAutoresizingTop.
}
```
* 可以用苹果自带的宏定义使用,一个表示单个枚举选项 **NS_ENUM**,一个表示组合的枚举**NS_OPTIONS**.
 * 两个宏具有向后兼容性,如果目标平台编译器支持新语法,则使用新语法,否则使用就语法.
 * 其中苹果宏的写法还是值得借鉴的.(老版代码)   
 
```
#if (__cplusplus && __cplusplus >= 201103L 
       && (__has_extension(cxx_strong_enums)
       || __has_feature(objc_fixed_enum))) 
       || (!__cplusplus 
       && __has_feature(objc_fixed_enum))  
				#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type  
				#if (__cplusplus)  
						#define NS_OPTIONS(_type, _name) _type _name; enum : _type  
				#else  
						#define NS_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type  
				#endif  
#else  
	#define NS_ENUM(_type, _name) _type _name; enum  
	#define NS_OPTIONS(_type, _name) _type _name; enum  
#endif  
```
* 使用Switch分支处理枚举类型时,不要加default分支,这样加入新枚举之后,编译器会提示开发者处理新枚举.

##对象、消息、运行时
* 对象是基本构造单元,对象用来存储并传递数据
* 对象之间传递数据并执行任务叫做“消息传递”
* 程序运行起来之后,为其提供相关支持的代码叫做 runtime,比如消息传递,创建类的实例对象,检查,修改类,对象和方法等.

***


###第六节 理解属性概念

####属性简介
* 对象如何封装数据,OC对象会把所需的数据保存为各种**实力变量**.实例变量一般通过存取方法来访问.
* **属性**一般用于封装对象的数据.

```
属性 = 自动生成实例变量 + 自动生成存取方法函数 + 调用存储方法时的内存管理
```
* 编译器会把“点运算”转换为存取方法.
* 可以用@synthesize指定实例变量的名字
* @dynamic 告诉编译器不自动创建**实例变量和存储方法**,并且不会报错,相信在运行期可以找到.

####ABI

* 不用属性的话,在头文件通过@public和@private定义实例变量.例如下面所写:

```
@interface EOCPerson : NSObject{
@public
	NSDate *_dateOfBirth; //多加出来的
	NSString *_firstName;
	NSString *_lastName;
@private
	NSString *_some;

}
@end
```
**对象布局在编译器就已经固定,比如访问_firstName变量,编译器把它替换为偏移量,偏移量是硬编码,表示距离存放对象的内存起始地址有多远**
但如果由增加一个实例 _dateOfBirth, _firstName的偏移量指向了_dateOfBirth. 如果想取值正确,**必须重新编译**.

* OC的做法:把实例变量当作存储偏移量的**特殊变量**.由**类对象**保管,偏移量会在运行期查找,如果类的定义变了,存储的偏移量就变了.这样何时访问实例变量都能使用正确的偏移量,甚至能新增新的实例变量,这就是稳固的“应用二进制接口”(ABI)

####属性特质(内存管理)

* 原子性:atomicity 非原子性:nonatomic(默认)
* 读写权限
 * readwrite(默认),属性拥有get和set方法.
 * readonly(只读),只会生成获取方法.
 * 一般属性对外公布只读属性,在class-continuation分类中重新定义读写属性.
* 内存管理语义
 * assign 基本类型,纯量类型的简单赋值,没有内存管理
 * strong 拥有关系,先retain新值,release旧值,设置新值.
 * weak 非拥有关系,引用计数不增加,对象清空,该指针为nil
 * unsafe_unretained 对象类型的简单赋值,没有内存管理
 * copy 将其“copy”,不可变的copy,保护对象可变的特质对外公布为不可变.