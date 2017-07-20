# AppTableViewPlaceholderView
* 具体的代码我也不多说了，思路可以在[零行代码为App添加异常加载占位图](http://www.cocoachina.com/ios/20161213/18270.html)这篇文章看到，我也是参考了这篇文章而作；  
* 在原文中作者的本意是想达到零行代码实现为App添加异常加载占位图的，但是由于tableView在首次加载的时候会reload一次，所以他便引入了firstLoad这个变量，最终导致了零行代码的崩塌；    
*  在本demo中，我便继续开始了零行代码的研究，其实也很简单，将每次都需要设置的self.tableView.firstLoad = Yes替换成了在+load方法中

		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:isFirstLoad];   
		
	这样一来，便真正的实现了零行代码的功效；   
	
* 但是这个也只是仅仅针对不需要点击事件响应的情况，假如遇到需要点击重新进行请求、点击进入网络设置等情况，零行代码还是不行滴； 因为每次点击之后必然会有一个回掉或者代理方法需要执行；最开始的时候，我想的也就将就了，但是后面发现每个控制器都要写，有点繁琐，于是乎：    
我将其抽离到了基类中，这样子一来，便只需要写一次就可以了；     



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
		        _tableView.dataSource = self;
		        _tableView.delegate = self;
		        _tableView.reRequestDelegate = self;
		    }
		    return _tableView;
		}


