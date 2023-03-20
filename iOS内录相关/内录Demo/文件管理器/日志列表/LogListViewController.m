//
//  LogListViewController.m
//  TJWebsocketTest
//
//  Created by 王东文 on 2018/8/20.
//  Copyright © 2018年 王东文. All rights reserved.
//

#import "LogListViewController.h"
#import "ZYFilePreView.h"
#import "TJFileModel.h"
#import "Masonry.h"

@interface LogListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView * baseTableView;
@property (nonatomic,strong)NSMutableArray * baseMutableArray;

@end

static NSString * cellID = @"cell";
@implementation LogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"日志列表";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.baseTableView];
    [self seekAllLog];
    
    UIBarButtonItem * barBtm = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = barBtm;
    
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
//    
//    UIBarButtonItem * fileBtn = [[UIBarButtonItem alloc]initWithTitle:@"文件管理" style:(UIBarButtonItemStylePlain) target:self action:@selector(fileBrowse)];
//    self.navigationItem.rightBarButtonItem = fileBtn;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:animated];
    self.navigationController.navigationBar.translucent = false;
}



- (void)dismiss
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)fileBrowse
{
    
}

#pragma mark - anyAction

- (void)seekAllLog
{
    NSFileManager *manager = [NSFileManager defaultManager];
    // 路径下的所有文件名
    
    NSArray *filePathArr = [manager contentsOfDirectoryAtPath:self.filePath error:nil];
   // NSLog(@"arr = %@",filePathArr);
    for (NSString * file in filePathArr)
    {
        if ([file.pathExtension isEqualToString:@"txt"])
        {
            [self.baseMutableArray addObject:[self getFileModelWith:file]];
        }
    }
    
    [self sortTheDataSource];
}

- (TJFileModel *)getFileModelWith:(NSString *)fileName
{
    TJFileModel * model = [[TJFileModel alloc]init];
    model.fileName = fileName;
    NSString * creatTime = [fileName stringByDeletingPathExtension];
    creatTime = [creatTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
    creatTime = [creatTime stringByReplacingOccurrencesOfString:@":" withString:@""];
    creatTime = [creatTime stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger creatTimeInt = [creatTime integerValue];
    model.creatTime = creatTimeInt;
    return model;
}




- (void)sortTheDataSource
{
    NSArray *result = [self.baseMutableArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        TJFileModel * model1 = (TJFileModel *)obj1;
        TJFileModel * model2 = (TJFileModel *)obj2;
        
        if (model1.creatTime < model2.creatTime)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }else
        {
             return (NSComparisonResult)NSOrderedAscending;
        }
        
    }];
    
    self.baseMutableArray = [NSMutableArray arrayWithArray:result];
    [self.baseTableView reloadData];
}






#pragma mark - UITabelViewDelegate

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
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    TJFileModel * model = self.baseMutableArray[indexPath.row];
    NSString * fileNameString = model.fileName;
    cell.textLabel.text = fileNameString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TJFileModel * model = self.baseMutableArray[indexPath.row];
    ZYFilePreView * quickLookVC = [ZYFilePreView shareFilePreview];
    NSString * fullFilePath = [self.filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",model.fileName]];
    [quickLookVC quickLookWithPathArray:@[fullFilePath] titleArray:@[model.fileName] ViewController:self isPush:true];
    
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
        TJFileModel * model = self.baseMutableArray[indexPath.row];
        NSString * fullFilePath = [self.filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",model.fileName]];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isFileExist = [manager fileExistsAtPath:fullFilePath];
        if (isFileExist)
        {
            [manager removeItemAtPath:fullFilePath error:nil];
        }
        
        [self.baseMutableArray removeObjectAtIndex:[indexPath row]];  //删除数组里的数据
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
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
        _filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    }
    return _filePath;
}

@end
