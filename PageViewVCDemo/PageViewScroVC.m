//
//  PageViewScroVC.m
//  PageViewVCDemo
//
//  Created by 杜文亮 on 2017/10/26.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "PageViewScroVC.h"
#import "ViewController.h"




@interface PageViewScroVC ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSMutableArray *VCs;
@property (nonatomic,assign) NSInteger currentIndex;

@end




@implementation PageViewScroVC

/*
     1,style: 这个参数是UIPageViewController翻页的过渡样式,系统提供了两种过度样式,分别是
     1) UIPageViewControllerTransitionStylePageCurl : 卷曲样式类似翻书效果
     2) UIPageViewControllerTransitionStyleScroll : UIScrollView滚动效果
     
     2,navigationOrientation: 这个参数是UIPageViewController导航方向,系统提供了两种方式,分别是
     1) UIPageViewControllerNavigationOrientationHorizontal : 水平导航方式
     2) UIPageViewControllerNavigationOrientationVertical : 垂直导航方式
     
     3,options: 这个参数是可选的,传入的是对UIPageViewController的一些配置组成的字典,不过这个参数只能以UIPageViewControllerOptionSpineLocationKey和UIPageViewControllerOptionInterPageSpacingKey这两个key组成的字典.
     1) UIPageViewControllerOptionSpineLocationKey 这个key只有在style是翻书效果UIPageViewControllerTransitionStylePageCurl的时候才有作用, 它定义的是书脊的位置,值对应着UIPageViewControllerSpineLocation这个枚举项,不要定义错了哦.
     2) UIPageViewControllerOptionInterPageSpacingKey这个key只有在style是UIScrollView滚动效果UIPageViewControllerTransitionStyleScroll的时候才有作用, 它定义的是两个页面之间的间距(默认间距是0).
 */

-(UIPageViewController *)pageVC
{
    if (!_pageVC)
    {
        //设置scro方式、设置滚动方向、设置间隔距离
        _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{@"UIPageViewControllerOptionInterPageSpacingKey":@(10)}];
        _pageVC.view.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 300);
        
        _pageVC.delegate = self;
        _pageVC.dataSource = self;
        
        [self addChildViewController:_pageVC];
        [self.view addSubview:_pageVC.view];
    }
    return _pageVC;
}

-(NSMutableArray *)VCs
{
    if (!_VCs)
    {
        _VCs = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 6; i++)
        {
            ViewController *vc = [[ViewController alloc] init];
            [_VCs addObject:vc];
        }
    }
    return _VCs;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.pageVC setViewControllers:@[self.VCs.firstObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished)
     {
         NSLog(@"========只调一次");
     }];
    
    //设置指示器(只适用于UIPageViewControllerTransitionStyleScroll、UIPageViewControllerNavigationOrientationHorizontal这种组合初始化的pageVC)显示不完美，目前未找到解决办法，所以用来做新手引导页不太完美，还是用老办法collectionView来做新手引导页
    UIPageControl *proxy = [UIPageControl appearance];
    [proxy setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [proxy setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [proxy setBackgroundColor:[UIColor yellowColor]];
}




#pragma mark - delegate and dataSource
/*
 *                          最基本、最重要的四个方法
    未设置UIPageControl（一般不会设置）
        完全依靠手势实现切换，调用顺序是：1，2，3（翻页成功）；1，2（翻页失败）。首页（继续上翻）、末页（继续下翻）只会响应一次2，之后继续首页上翻、末页下翻1，2，3都不会响应（注意：不是绝对的，通常情况下是这样，测试时默写操作可能不是这样）
        注意：1，scro类型的调用顺序和curl类型的不一样！但是里面关于index的处理却是一样的，这一点曾经令我相当疑惑！两种类型的异同在各自方法中有详解
             2，首页首次翻页时，会先立刻调用两次3，一次before，一次after，哪个先调和本次的手势方向有关
        
    设置了UIPageControl
        手势切换（全程手势切换）调用顺序不变（同上），但是通过点击（全程点击）UIPageControl实现切换的话，调用顺序变成1，3，2（注意：如果手势、点击交叉使用，顺序就混乱了）
 */
//开始翻页 ---1
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    //pendingViewControllers里包含的就是即将显示的那个控制器, 是一个数组, 如果是单页显示的话, 其中只有一个元素
    UIViewController *vc = pendingViewControllers.firstObject;
    NSInteger index = [self.VCs indexOfObject:vc];
    NSLog(@"开始翻页,即将显示的VC：%ld",index);
}

//翻页结束 ---2
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    //previousViewControllers里面是翻页前的VC
    if (completed)
    {
        UIViewController *vc = previousViewControllers.firstObject;
        NSInteger index = [self.VCs indexOfObject:vc];
        NSLog(@"翻页结束,翻页成功,翻页之前的VC：%ld",index);
        //        NSLog(@"%@",pageViewController.childViewControllers);
    }
    else
    {
        NSLog(@"翻页结束,翻页失败");
    }
}

//展示下一个VC ---3
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    /*
        viewController是当前显示的VC
            scro:但因为调用顺序是1，2，3，此时已翻页完毕，这个index实际上是翻页完成后VC的index，而不是翻页前的VC的index（界面效果：已经动画切换到了下个VC才调用这里）
            curl:调用顺序是3，1，2，此时翻页还未开始，这个index是翻页前的VC的index（界面效果：还未开始动画切换就调用这里）
     */
    NSInteger index = [self.VCs indexOfObject:viewController];
    self.currentIndex = index;
    NSLog(@"后后后后后后后后：%ld",index);
    if ((index == self.VCs.count -1) || (index == NSNotFound))
    {
        NSLog(@"当前已经是最后一页");
        return nil;
    }
    /*
        下面两步操作，无论scro还是curl，返回的都是“当前正在显示VC”的下一个VC，但是：
            scro:翻页早已结束，当前显示的已经是我们期望的VC。此时执行下面操作，返回的下一个VC并不是我们所期望出现在屏幕上的（逻辑值不正常，但尽管逻辑上是返回的是期望VC的下一个VC，可是屏幕显示依然使我们期望的VC，等于说这两步操作看起来貌似没起作用）
            curl:翻页还未开始，当前显示的是翻页前的VC。此时执行下面操作，返回我们期望的VC（逻辑值正常）
            总结：那么怎么理解scro中的逻辑值反常的现象呢？首先我尝试将scro逻辑值修改为正常的（不执行--或者++，直接返回我们期望的VC），但是运行起来效果却是不正常的！最后，我将scro这一现象暂时称为一种预加载
     */
    index++;
    return self.VCs[index];
}

//展示上一个VC ---3
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.VCs indexOfObject:viewController];
    self.currentIndex = index;
    NSLog(@"前前前前前前前：%ld",index);
    if ((index == 0) || (index == NSNotFound))
    {
        NSLog(@"当前已经是第一页");
        return nil;
    }
    index--;
    return self.VCs[index];
}




/*
 *   设置UIPageControl指示器需要的两个代理方法,只适用于UIPageViewControllerTransitionStyleScroll、UIPageViewControllerNavigationOrientationHorizontal这种组合初始化的pageVC
 */
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.VCs.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentIndex;
}



@end
