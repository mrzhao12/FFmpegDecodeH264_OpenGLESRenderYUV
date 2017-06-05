//
//  OpenGLESRenderYUVImageVC.m
//  FFmpegDecodeH264_OpenGLESRenderYUV
//
//  Created by sjhz on 2017/6/3.
//  Copyright © 2017年 sjhz. All rights reserved.
//

#import "OpenGLESRenderYUVImageVC.h"

#import "OpenGLView20.h"
@interface OpenGLESRenderYUVImageVC ()

@end

@implementation OpenGLESRenderYUVImageVC

    {
        NSData *yuvData;
        OpenGLView20 * myview;
    }

- (void)dealloc {
    
    //    [_openglview release];
    NSLog(@"OpenGLVC--dealloc");
    //    [super dealloc];
    printf("%s\n",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OpenGLESRenderYUVImageVC";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *yuvFile = [[NSBundle mainBundle] pathForResource:@"cuc_view_480x272" ofType:@"yuv"];
//     NSString *yuvFile = [[NSBundle mainBundle] pathForResource:@"jpgimage1_image_640_480" ofType:@"yuv"];
    yuvData = [NSData dataWithContentsOfFile:yuvFile];
    NSLog(@"the reader length is %lu", (unsigned long)yuvData.length);
//    
    myview = [[OpenGLView20 alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 40)];
    
//    myview = [[OpenGLView20 alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 232)];
    [self.view addSubview:myview];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UInt8 * pFrameRGB = (UInt8*)[yuvData bytes];
    [myview setVideoSize:640 height:480];
//    [myview displayYUV420pData:pFrameRGB width:640 height:480];
#warning 此处的width和height一定要和yuv像素的宽高一一对应，错一个数字就会出现绿色，不显示图片
    
     [myview displayYUV420pData:pFrameRGB width:480 height:272];
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
