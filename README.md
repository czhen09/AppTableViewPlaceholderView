# UITableView占位图的低耦合性设计   


## 缘由  
基于面向对象的开发原则中的`迪米特法则`:`一个软件实体应当尽可能少的与其他实体发生相互作用`;为了降低列表无数据占位图的使用成本及代码耦合性,对网上现用的一些解决方案加以优化;


## 核心  
针对基于runtime替换reloadData方法的相关,这里就不做多阐述了,本文主要讨论以下几个问题:  

* `1.需要显示占位图的情况;`    
* `2.tableView初次系统调用reloadData方法的干扰排除最优方案;`   
* `3.网络因服务器故障请求失败的处理;`  
* `4.占位图触发再次网络请求的策略;`  

## 问题1:需要显示占位图的情况       
现在流行的判断方案是:  

* `tableView.rows==0; ` 

我需要补充说明的是:


* `tableView.sections>0&&tableView.rows==0&&tableView.viewForHeaderInSection!=nil;  ` 

针对第一种`rows==0`的情况就不做多解释;第二种的话主要就是:当一个列表的数据绑定在`sectionHeaderView`上面,此时`row==0`;然后需求是:点击`sectionHeaderView`,展开`section`,刷新数据;`row>=0`;所以如果仅仅考虑`rows==0`的情况,在第二种需求的情况占位图显示就会异常;    

`补充:`无网络的时候直接加载占位图;

## 问题2:tableView初次系统调用reloadData方法的干扰排除最优方案   

在网上我看到的解决方案是:   
在category给UITableView新增isFirstReload属性;如果是第一次加载的话设置`tableView.isFirstReload = YES`;然后内部的判断是:  
		
	if (!self.firstReload) {
        [self checkEmpty];
    }
    self.firstReload = NO;
    
针对每次都需要在控制器中调用`tableView.isFirstReload = YES`,我也是做了很多优化,比如最开始的时候我会想直接在基类viewDidLoad或者利用`Aspects`切入viewWillApear``方法中:遍历子视图,如果是`[UITableView Class]`或者`[UICollectionView Class]`就直接调用;   


	- (void)aspectViewWillAppearWithViewController:(UIViewController *)viewController
	{
	    NSArray *subViews = viewController.view.subviews;
	    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
	        if ([view isKindOfClass:[UITableView class]]) {
	            UITableView *tableView = (UITableView *)view;
	            if (!tableView.isNotFirstReload) {
	                tableView.isNotFirstReload = NO;
	            }
	        }
	        //如果tableView非self.view的直接子视图,而是孙视图....  
	        //可用递归优化;
	        NSArray *secondLevelSubviews = view.subviews;
	        [secondLevelSubviews enumerateObjectsUsingBlock:^(UIView *secondView, NSUInteger idx, BOOL * _Nonnull stop) {
	            if ([secondView isKindOfClass:[UITableView class]]) {
	                UITableView *tableView = (UITableView *)secondView;
	                if (!tableView.isNotFirstReload) {
	                    tableView.isNotFirstReload = NO;
	                }
	            }
	            NSArray *thirdLevelSubviews = secondView.subviews;
	            [thirdLevelSubviews enumerateObjectsUsingBlock:^(UIView *thirdView, NSUInteger idx, BOOL * _Nonnull stop) {
	                if ([thirdView isKindOfClass:[UITableView class]]) {
	                    UITableView *tableView = (UITableView *)thirdView;
	                    if (!tableView.isNotFirstReload) {
	                        tableView.isNotFirstReload = NO;
	                    }
	                }
	            }];
	        }];
	    }];
	}
如此优化,是可以达到效果,但是在视图启动的时候遍历子视图无非是性能耗损的;最后脑筋急转弯,其实也就是一个很简单的方法就能解决这个问题:   
	
	@property (nonatomic, assign) BOOL isNotFirstReload;  

-
	
	if (self.isNotFirstReload) {
        [self checkEmpty];
    }
    self.isNotFirstReload = YES;  
    
BOOL属性第一次加载的时候本来就是NO,也就避免了外部的传入;  

## ~~问题3:网络因服务器故障请求失败的处理~~       
~~也就是在网络请求的时候走`failure`的时候;一般情况下,在控制器失败的回调中我们不会手动调用`[self.taleView reloadData]`;如果不调用的话,就不能正确的加载占位图了;当然你也可以在失败的回调中调用reloadData方法解决这个问题;我这里给出另外一种解决方案:~~  


~~通过`window`的`rootViewController`拿到当前的控制器,然后通过遍历当前控制器的子视图获取`tableView`,调用`reloadData`方法,主要代码如下:~~ 


		+ (instancetype)shareInstance
	{
	    static RequestFailureHandler *shareInstance;
	    static dispatch_once_t onceToken;
	    dispatch_once(&onceToken, ^{
	        shareInstance = [[RequestFailureHandler alloc] init];
	    });
	    return shareInstance;
	}
	- (void)handleRequestFailure
	{
	    //根控制器是UINavigationController
	    if ([self.rootVC isKindOfClass:[UINavigationController class]]) {
	        [[RequestFailureHandler shareInstance] handleWithNavgationController:(UINavigationController *)self.rootVC];
	    }else
	    {
	        //没有UINavigationController的情况下
	        [[RequestFailureHandler shareInstance] findTargetViewWithController:self.rootVC];
	    }
	}
	- (void)handleWithNavgationController:(UINavigationController *)nav
	{
	    UIViewController *vc = nav.visibleViewController;
	    if (vc.childViewControllers.count>0) {
	        
	        if ([vc.childViewControllers.firstObject isKindOfClass:[UIPageViewController class]]) {
	            UIPageViewController *pageVc = (UIPageViewController *)vc.childViewControllers.firstObject;
	            UIViewController *pageChild = pageVc.viewControllers.firstObject;
	            [[RequestFailureHandler shareInstance] findTargetViewWithController:pageChild];
	        }
	    }else{
	        [[RequestFailureHandler shareInstance] findTargetViewWithController:vc];
	    }
	}
	- (void)findTargetViewWithController:(UIViewController *)viewController
	{
	    NSArray *subViews = viewController.view.subviews;
	    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
	        if ([view isKindOfClass:[UITableView class]]) {
	            UITableView *tableView = (UITableView *)view;
	            [tableView reloadData];
	        }
	    }];
	}
	#pragma mark - Getters & Setters
	- (UIViewController *)rootVC
	{
	    if (!_rootVC) {
	        _rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
	    }
	    return _rootVC;
	}

~~针对这个做法,子视图的遍历,性能是会耗损的;但是考虑到这个主要是请求失败的回掉中(不像在问题2中是在控制器启动的时候);耗损也不会影响其他,并且能够统一处理;所以凑合能用;~~


`补充:`后面突然这个方案存在一个问题:那就是当一个界面存在多个请求的时候,其中任何一个请求失败会干扰占位图的加载;暂时没想到更好的解决办法;

## 问题4:占位图触发再次网络请求的策略   
事件回调:    

* block回调  
* delegate回调  

可以直接在每个控制器中接收回调,并完成再次请求;我在这里想的在基类懒加载tableView对象,然后设置代理接收回调;在回调里面调用网络请求的统一方法;  

	
	- (void)loadData
	{
	   //子类重写这个方法，并且在这个方法中进行网络请求
	}
	
	#pragma mark - ReRequesDataDelegate
	- (void)reRequesData
	{
	    [self loadData];
	}
	
	- (UITableView *)tableView
	{
	    if (!_tableView) {
	        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
	        _tableView.tableFooterView = [UIView new];
	        _tableView.dataSource = self;
	        _tableView.delegate = self;
	        _tableView.reRequestDelegate = self;
	    }
	    return _tableView;
	}   

这样的话,子类只需要重写`loadData`;并在里面执行网络请求,就可以达到目的;


## 更多精彩:     
[软件化ESJsonFormat插件,脱离Xcode环境运行](https://github.com/czhen09/ESJsonFormatForMac)    
[iOS_K线三方库](https://github.com/czhen09/ZXKline)   


