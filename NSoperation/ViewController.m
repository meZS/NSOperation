//
//  ViewController.m
//  NSoperation
//
//  Created by wordy on 2017/7/6.
//  Copyright © 2017年 golddatacommunications. All rights reserved.
//

#import "ViewController.h"
#import "ZSOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /*
     NSOperation简介
     NSOperation和NSOperationQueue的基本使用
     创建任务
     创建队列
     将任务加入到队列中
     控制串行执行和并行执行的关键
     操作依赖
     一些其他方法
     */
    
    /*
     1. NSOperation简介
     
     NSOperation是苹果提供给我们的一套多线程解决方案。实际上NSOperation是基于GCD更高一层的封装，但是比GCD更简单易用、代码可读性也更高。
     
     NSOperation需要配合NSOperationQueue来实现多线程。因为默认情况下，NSOperation单独使用时系统同步执行操作，并没有开辟新线程的能力，只有配合NSOperationQueue才能实现异步执行。
     
     因为NSOperation是基于GCD的，那么使用起来也和GCD差不多，其中，NSOperation相当于GCD中的任务，而NSOperationQueue则相当于GCD中的队列。NSOperation实现多线程的使用步骤分为三步：
     
     创建任务：先将需要执行的操作封装到一个NSOperation对象中。
     创建队列：创建NSOperationQueue对象。
     将任务加入到队列中：然后将NSOperation对象添加到NSOperationQueue中。
     之后呢，系统就会自动将NSOperationQueue中的NSOperation取出来，在新线程中执行操作。
     
     下面我们来学习下NSOperation和NSOperationQueue的基本使用。
     
     2.NSOperation和NSOperationQueue的基本使用
     */


 #pragma mark  --// 1. 创建任务
        /*
     NSOperation是个抽象类，并不能封装任务。我们只有使用它的子类来封装任务。我们有三种方式来封装任务。
     
     使用子类NSInvocationOperation
     使用子类NSBlockOperation
     定义继承自NSOperation的子类，通过实现内部相应的方法来封装任务。
     在不使用NSOperationQueue，单独使用NSOperation的情况下系统同步执行操作，下面我们学习以下任务的三种创建方式。
     */
    
    
#pragma mark - 使用子类- NSInvocationOperation:
    
    
    NSLog(@"\n主线程==%@",[NSThread mainThread]);
    // 1. 创建NSInvocationOperation对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    // 2. 调用start 方法开始执行操作
    [op start];
    
    //PS: 如果单独使用NSInvocationOperation这个子类,没有使用NSOperationQueue队列的情况下,NSInvocationOperation在主线程中执行操作,并没有开启新线程
    
#pragma mark -使用子类- NSBlockOperation
    
    // 1. 创建NSInvocationOperation对像
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        NSLog(@"\n-111-blockOperation---%@",[NSThread currentThread]);
    }];
    // 2. 调用start 方法开始执行操作
    //     [op1 start];
    //PS: 如果单独使用NSBlockOperation这个子类,没有使用NSOperationQueue队列的情况下,NSBlockOperation也在主线程中执行操作,并没有开启新线程
    
    /*
     但是，NSBlockOperation还提供了一个方法addExecutionBlock:，通过addExecutionBlock:就可以为NSBlockOperation添加额外的操作，这些额外的操作就会在其他线程并发执行。
     */
    
    // 添加额外的任务在子线程
    [op1 addExecutionBlock:^{
        NSLog(@"\n-222-blockOperation---%@",[NSThread currentThread]);
    }];
    
    [op1 addExecutionBlock:^{
        NSLog(@"\n-333-blockOperation---%@",[NSThread currentThread]);
    }];
    
    [op1 addExecutionBlock:^{
        NSLog(@"\n-444-blockOperation---%@",[NSThread currentThread]);
    }];
    
    [op1 start];
    
    // PS:可以看出，blockOperationWithBlock:方法中的操作是在主线程中执行的，而addExecutionBlock:方法中的操作是在其他线程中执行的。
    
    
#pragma mark -- 定义继承自NSOperation的子类
    
    ZSOperation *op2 = [[ZSOperation alloc] init];
    [op2 start];
    // PS: 可以看出：在没有使用NSOperationQueue、单独使用自定义子类的情况下，是在主线程执行操作，并没有开启新线程。
   
#pragma mark --  // 2. 创建队列
    /*
     和GCD中的并发队列、串行队列略有不同的是：NSOperationQueue一共有两种队列：主队列、其他队列。其中其他队列同时包含了串行、并发功能。下边是主队列、其他队列的基本创建方法和特点。
     */
    
    // 主队列
    // 凡是添加到主队列中的任务,都会放到主线程中执行
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    // 其他队列(非主队列)
    // 添加到这种队列中的任务(NSOperation)
    // 同时包含了: 串行/并发功能
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    
    
#pragma mark --//3. 将任务加入到队列中
    // NSOperation需要配合NSOperationQueue来实现多线程。
    
//    我们需要将创建好的任务加入到队列中去。总共有两种方法
     [self addOperationToQueue1];
    
      [self addOperationToQueue2];
    
#pragma mark - 3. 控制串行执行和并行执行的关键
    
    //NSOperationQueue创建的其他队列同时具有串行、并发功能，上边我们演示了并发功能，那么他的串行功能是如何实现的？
    //这里有个关键参数maxConcurrentOperationCount，叫做最大并发数。
//    最大并发数：maxConcurrentOperationCount
//    maxConcurrentOperationCount默认情况下为-1，表示不进行限制，默认为并发执行。
//    当maxConcurrentOperationCount为1时，进行串行执行。
//    当maxConcurrentOperationCount大于1时，进行并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整。
    
    //设置最大并发数
    
    [self operationQueue];
    
#pragma mark -- 操作依赖
    //NSOperation和NSOperationQueue最吸引人的地方是它能添加操作之间的依赖关系。比如说有A、B两个操作，其中A执行完操作，B才能执行操作，那么就需要让B依赖于A。
    [self addDependency];
    
#pragma nark -- 一些其他方法
    // - (void)cancle; NSOperation提供的方法，可取消单个操作
    // - (void)cancelAllOperations; NSOperationQueue提供的方法，可以取消队列的所有操作
    // - (void)setSuspended:(BOOL)b; 可设置任务的暂停和恢复，YES代表暂停队列，NO代表恢复队列
    // - (BOOL)isSuspended; 判断暂停状态
    
    [op1 cancel]; // 取消单个操作
    [queue cancelAllOperations];// 取消队列中所有操作
    [queue setSuspended:YES]; // 设置任务的暂停和恢复
    [queue isSuspended];// BOOL:判断暂定状态
//    注意：
//    这里的暂停和取消并不代表可以将当前的操作立即取消，而是当当前的操作执行完毕之后不再执行新的操作。
//    暂停和取消的区别就在于：暂停操作之后还可以恢复操作，继续向下执行；而取消操作之后，所有的操作就清空了，无法再接着执行剩下的操作。
    

}

- (void)run
{
    NSLog(@"\n--InvocationOperation--%@",[NSThread currentThread]);
}

- (void)addOperationToQueue1
{
    // 1. 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 2. 创建操作
    // 创建NSInvocationOperation
    NSInvocationOperation *op  = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(act ) object:nil];
    // 创建NSBlockOperation
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i ++) {
            
            NSLog(@"***====****%@",[NSThread currentThread]);
        }
    }];
    [queue addOperation:op];
    [queue addOperation:op1];

     // PS: 可以看出：NSInvocationOperation和NSOperationQueue结合后能够开启新线程，进行并发执行.NSBlockOperation和NSOperationQueue也能够开启新线程，进行并发执行。
    
}
- (void)act
{
    for (int i = 0 ; i < 2; i ++) {
        NSLog(@"===****===%@",[NSThread currentThread]);
    }
}
- (void)addOperationToQueue2
{
    //无需先创建任务，在block中添加任务，直接将任务block加入到队列中。
    // 1. 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2. 添加操作到队列中：addOperationWithBlock:
    [queue addOperationWithBlock:^{
        
        for (int i = 0; i < 2; i ++) {
            NSLog(@"+++====+++%@",[NSThread currentThread]);
        }
    }];
    
    // PS:可以看出addOperationWithBlock:和NSOperationQueue能够开启新线程，进行并发执行。
}

- (void)operationQueue
{
    // 1 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 设置最大并发数,默认为-1,不限制. 设为1.串行执行. 大于1时,并发执行,达到系统限制时,系统会做自动调整.
    queue.maxConcurrentOperationCount = 1; //串行队列
    // 添加任务
    [queue addOperationWithBlock:^{
        //
        NSLog(@"1-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"2-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"3-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"4-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"5-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"6-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"7-----%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    
    // 可以看出：当最大并发数为1时，任务是按顺序串行执行的。当最大并发数为2时，任务是并发执行的。而且开启线程数量是由系统决定的，不需要我们来管理。这样看来，是不是比GCD还要简单了许多？

}
- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"----11111-----%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"----22222-----%@",[NSThread currentThread]);
    }];
    [op2 addDependency:op1];//任务2 依赖于 任务1,先执行任务1,在执行任务2.
    [queue addOperation:op1];
    [queue addOperation:op2];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
