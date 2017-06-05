//
//  PlayerVC.m
//  FFmpegDecodeH264_OpenGLESRenderYUV
//
//  Created by sjhz on 2017/6/3.
//  Copyright © 2017年 sjhz. All rights reserved.
//

#import "PlayerVC.h"

@interface PlayerVC ()

@end

@implementation PlayerVC

#pragma mark - lifeCycle
- (void)dealloc {
    //    [super dealloc];
    
    printf("%s\n",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PlayerVC";
    self.view.backgroundColor = [UIColor whiteColor];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
