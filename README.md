# RHParallaxRefreshControl
---

A TableView Parallax Refresh Control.

![Effect](https://raw.githubusercontent.com/Rannie/RHParallaxRefreshControl/master/Screenshot.gif)

###Usage
---

Initial and block event callback.

```
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   ......
   
   _parallaxContext = [RHParallaxRefreshContext context];
   __weak typeof(self) weakSelf = self;
   [_parallaxContext setBeginRefreshingCallback:^{
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           if (weakSelf.parallaxContext.isRefreshing)
               [weakSelf.parallaxContext endRefreshing];
       });
   }];
}
```

Specify the imageview

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * const HeaderIdentifier = @"HEADER";
  UITableViewCell * cell = nil;
  if (indexPath.row == 0)
  {
      cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
      if (!cell)
      {
          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Header];
          UIImageView *refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, REFRESH_CONTROL_HEIGHT)];
          [cell.contentView addSubview:refreshImageView];
          refreshImageView.image = [UIImage imageNamed:@"subaru"];
          
      	  [_parallaxContext setupParallaxOnImageView:refreshImageView scrollView:tableView];
      }
  }
  else
  {
      ......
  }
  
  return cell;
}
```

Scroll Delegate

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   [_parallaxContext scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
   [_parallaxContext scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}
```

###LICENSE
---

The MIT License (MIT)

Copyright (c) 2015 Hanran Liu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.