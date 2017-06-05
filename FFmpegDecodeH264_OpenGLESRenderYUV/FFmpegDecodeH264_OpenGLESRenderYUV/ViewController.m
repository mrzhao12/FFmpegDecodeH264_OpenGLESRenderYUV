//
//  ViewController.m
//  FFmpegDecodeH264_OpenGLESRenderYUV
//
//  Created by sjhz on 2017/6/3.
//  Copyright © 2017年 sjhz. All rights reserved.
//

#import "ViewController.h"
#import "FFmpegVC.h"
#import "OpenGLESRenderYUVImageVC.h"
#import "OpenGLESRenderYUVVC.h"
#import "PlayerVC.h"
#define screenSize [UIScreen mainScreen].bounds.size
static NSString *kCellID = @"kCellID";
@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - lifeCycle
- (void)dealloc {
    //    [super dealloc];
    
    printf("%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
}

#pragma mark - getter lazyLoadMethod
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 300) style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


#pragma mark - dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"FFmpeg解码";
            break;
        case 1:
            cell.textLabel.text = @"openGL渲染图片yuv数据";
            break;
        case 2:
            cell.textLabel.text = @"openGL渲染_H264解码";
            break;
        case 3:
            cell.textLabel.text = @"播放器搭建";
            break;
        default:
            cell.textLabel.text = @"";
            break;
    }
    return cell;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            FFmpegVC *vc = [[FFmpegVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            
            break;
        case 1:{
            OpenGLESRenderYUVImageVC *vc= [[OpenGLESRenderYUVImageVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:{
            OpenGLESRenderYUVVC *vc = [[OpenGLESRenderYUVVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 3:{
            PlayerVC *vc = [[PlayerVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
