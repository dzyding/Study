//
//  TJFileViewController.m
//  TingJianApp
//
//  Created by 王东文 on 2019/5/14.
//  Copyright © 2019 zhangyu. All rights reserved.
//

#import "TJFileViewController.h"
#import "LocalFileModel.h"
#import "ZYFilePreView.h"
#import "Masonry.h"

@interface TJFileViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView * baseTableView;
@property (nonatomic,strong)NSMutableArray * baseMutableArray;


@end
static NSString * cellID = @"cell";
@implementation TJFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.filePath isEqualToString:NSHomeDirectory()])
    {
        self.navigationItem.title = @"根目录";
    }else
    {
        self.navigationItem.title = [self.filePath lastPathComponent];
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    [self reloadFileList];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:animated];
    self.navigationController.navigationBar.translucent = false;
}




#pragma mark - anyAction
- (void)reloadFileList
{
    [self.baseMutableArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        // 路径下的所有文件名
        
        NSArray *filePathArr = [manager contentsOfDirectoryAtPath:self.filePath error:nil];
        NSLog(@"arr = %@",filePathArr);
        NSMutableArray * tempArray = [NSMutableArray array];
        NSMutableArray * fileArr = [NSMutableArray array];
        for (NSString * file in filePathArr)
        {
            LocalFileModel * model = [[LocalFileModel alloc]init];
            model.filePath = [self.filePath stringByAppendingPathComponent:file];
            model.fileName = file;
            NSLog(@"file = %@",file);
            [tempArray addObject:model];
        }
        
        for (NSInteger a = 0; a < tempArray.count; a ++)
        {
            LocalFileModel * model = tempArray[a];
            if (model.isDirectory)
            {
                [self.baseMutableArray addObject:model];
            }else
            {
                [fileArr addObject:model];
            }
        }
        [self.baseMutableArray addObjectsFromArray:fileArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.baseTableView reloadData];
        });
    });
}




#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.baseMutableArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 0;
    }
    LocalFileModel * model = self.baseMutableArray[indexPath.row];
    NSString * fileNameString = model.fileName;
    cell.textLabel.text = fileNameString;
    if (model.isDirectory)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    LocalFileModel * model = self.baseMutableArray[indexPath.row];
    if (model.isDirectory)
    {
        TJFileViewController * fileVC = [[TJFileViewController alloc]init];
        fileVC.filePath = model.filePath;
        [self.navigationController pushViewController:fileVC animated:true];
    }else
    {
        ZYFilePreView * quickLookVC = [ZYFilePreView shareFilePreview];
        NSString * fullFilePath = [self.filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",model.fileName]];
        [quickLookVC quickLookWithPathArray:@[fullFilePath] titleArray:@[model.fileName] ViewController:self isPush:false];
    }

    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return UITableViewCellEditingStyleDelete;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        LocalFileModel * model = self.baseMutableArray[indexPath.row];
        NSString * fullFilePath = model.filePath;
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isFileExist = [manager fileExistsAtPath:fullFilePath];
        if (isFileExist)
        {
            BOOL isSuccess = [manager removeItemAtPath:fullFilePath error:nil];
            if (isSuccess)
            {
                [self.baseMutableArray removeObjectAtIndex:[indexPath row]];  //删除数组里的数据
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            }else
            {
                NSLog(@"删除失败");
                [tableView reloadData];
            }
        }else
        {
            NSLog(@"文件不存在");
        }
    }
}



#pragma mark - lazyload
- (UITableView *)baseTableView
{
    if (!_baseTableView)
    {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _baseTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        _baseTableView.delegate = self;
        _baseTableView.dataSource = self;
        _baseTableView.rowHeight = 50;
        _baseTableView.estimatedSectionFooterHeight = 0;
        _baseTableView.estimatedSectionHeaderHeight = 0;
        _baseTableView.estimatedRowHeight = 0;
        _baseTableView.backgroundColor = [UIColor clearColor];
    }
    return _baseTableView;
}

- (NSMutableArray *)baseMutableArray
{
    if (!_baseMutableArray)
    {
        _baseMutableArray = [NSMutableArray array];
    }
    return _baseMutableArray;
}



- (NSString *)filePath
{
    if (!_filePath)
    {
        _filePath = NSHomeDirectory();
    }
    return _filePath;
}
@end
