//
//  PageViewVC.m
//  PageViewVCDemo
//
//  Created by 杜文亮 on 2017/10/25.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "PageViewCurlVC.h"
#import "ViewController.h"




@interface PageViewCurlVC ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSMutableArray *VCs;

@end




@implementation PageViewCurlVC

/*
     typedef NS_ENUM(NSInteger, UIPageViewControllerSpineLocation) 
    {
         //对于SCrollView类型的滑动效果 没有书轴 会返回下面这个枚举值
         
         UIPageViewControllerSpineLocationNone = 0,
         
         //以左边或者上边为轴进行翻转 界面同一时间只显示一个View
         
         UIPageViewControllerSpineLocationMin = 1,
         
         //以中间为轴进行翻转 界面同时可以显示两个View
         
         UIPageViewControllerSpineLocationMid = 2,
         
         //以下边或者右边为轴进行翻转 界面同一时间只显示一个View
         
         UIPageViewControllerSpineLocationMax = 3
     };
 */
-(UIPageViewController *)pageVC
{
    if (!_pageVC)
    {
        _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{@"UIPageViewControllerOptionSpineLocationKey":@(UIPageViewControllerSpineLocationMid)}];//设置书脊位置在中间（必须设置双叶显示）
        _pageVC.view.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 300);
        /*
            1.1，默认为NO,效果：背面无任何内容，一共self.VCs.count页；
            1.2，如果设置YES，效果：正反两面都有内容，一共self.VCs.count/2页
         
            2.1，如果我们当前屏幕仅展示一个页面（意思就是书脊不在屏幕中间）那么不用设置这个属性,
            2.2，如果设置了UIPageViewControllerSpineLocationMid（书脊在屏幕中间）这个选项,效果是翻开的书这样屏幕展示的就是两个页面,这个属性就必须设置为YES了.
         
            总结：这个属性控制反面是否产生内容，不受书脊的影响。也就是说2.1那种情况虽然没必要设置YES，但是也可以设置为YES，只不过书脊不在中间，我们无法观看反面内容，如果想美化背面的显示效果，可以这样做（小说里就是这样做的），但是这时候下面四个基本的四个方法调用顺序会变成2，2，1，3，也就是说一次翻页过程中会掉两次2，返回正反面的两个VC
         */
        _pageVC.doubleSided = YES;//设置双页显示，一次展示两页

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
    
    [self.pageVC setViewControllers:[self.VCs subarrayWithRange:NSMakeRange(0, 2)] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished)
    {
        NSLog(@"========只调一次");
    }];
}




#pragma mark - delegate and dataSource
/*
 *                              最基本、最重要的四个方法
     1，无论翻页是通过点击手势、还是滑动手势：
            doubleSided = YES:
                 中间部分翻页时调用顺序：2，2，1，3
                 首页（继续上翻）、末页（继续下翻）翻页时调用顺序：2一次（1，3都不会走）
            doubleSided = NO:
                 中间部分翻页时调用顺序：1，2，3
                 首页（继续上翻）、末页（继续下翻）翻页时调用顺序：2一次（1，3都不会走）
 
     2，在首页、末页中翻页，可以无限响应2
 */
//开始翻页 ---1
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    //pendingViewControllers里包含的就是即将显示的那个控制器, 是一个数组, 如果是单页显示的话, 其中只有一个元素
    UIViewController *vc = pendingViewControllers.firstObject;
    NSInteger index = [self.VCs indexOfObject:vc];
    NSLog(@"开始翻页,即将显示的VC：%ld",index);
}

//展示下一个VC ---2
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"↓↓↓↓↓↓↓↓");
    NSInteger index = [self.VCs indexOfObject:viewController];
    if ((index == self.VCs.count -1) || (index == NSNotFound))
    {
        NSLog(@"当前已经是最后一页");
        return nil;
    }
    index++;
    return self.VCs[index];
}

//展示上一个VC ---2
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSLog(@"↑↑↑↑↑↑↑↑");
    NSInteger index = [self.VCs indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound))
    {
        NSLog(@"当前已经是第一页");
        return nil;
    }
    index--;
    return self.VCs[index];
}

//翻页结束 ---3
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
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




/*
 *   只有UIPageViewControllerTransitionStylePageCurl类型的pageVC才会响应这3个方法(不知道具体怎么用，下面这么写会崩溃)
 */
//这个方法是在style是UIPageViewControllerTransitionStylePageCurl 并且横竖屏状态变化的时候触发,我们可以重新设置书脊的位置,比如如果屏幕是竖屏状态的时候我们就设置书脊位置是UIPageViewControllerSpineLocationMin或UIPageViewControllerSpineLocationMax, 如果屏幕是横屏状态的时候我们可以设置书脊位置是UIPageViewControllerSpineLocationMid
//- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    return UIPageViewControllerSpineLocationMin;
//}

//设置UIPageViewController支持的屏幕旋转类型
//- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
//{
//    return UIInterfaceOrientationMaskLandscape;
//}

//设置应用程序当前的屏幕的方向
//- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController
//{
//    return UIInterfaceOrientationPortrait;
//}



@end
