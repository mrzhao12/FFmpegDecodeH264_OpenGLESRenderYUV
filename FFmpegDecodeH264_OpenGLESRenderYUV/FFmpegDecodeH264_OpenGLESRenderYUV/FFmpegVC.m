//
//  FFmpegVC.m
//  FFmpegDecodeH264_OpenGLESRenderYUV
//
//  Created by sjhz on 2017/6/3.
//  Copyright © 2017年 sjhz. All rights reserved.
//
#warning 输入一个沙河内的视频文件（比如：flv格式，内存小）解码为一帧一帧的图片集合（像素格式，内存大）yuv

#import "FFmpegVC.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
@interface FFmpegVC ()

@end

@implementation FFmpegVC

#pragma mark - lifeCycle
- (void)dealloc {
    printf("%s\n",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FFmpegVC";
    self.view.backgroundColor = [UIColor whiteColor];
   [self decode];
}
#pragma mark - privateMethod
- (void)decode {
    
    //初始化所有组件
    av_register_all();
    
    //声明上下文
    AVFormatContext	*pFormatCtx;
    
    //初始化上下文
    pFormatCtx = avformat_alloc_context();
    
    char output_str_full[500]={0};
    char info[1000]={0};
    //获取文件路径
    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"521_720x576.flv" ofType:nil];
    //
    //    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"cuc_view_encode.jpg" ofType:nil];
    
    
    const char * path = [filePath UTF8String];
    
    if (path == NULL) {
        
        printf("无法找到文件路径/n");
        
        return ;
    }
    NSString *myout = @"myYUV521_720x576";
    NSString *output_str= [NSString stringWithFormat:@"%@.yuv",myout];
    NSString *output_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:output_str];
    sprintf(output_str_full,"%s",[output_nsstr UTF8String]);
    printf("Output Path:%s\n",output_str_full);
    //打开视频流
    if(avformat_open_input(&pFormatCtx,path,NULL,NULL)!=0){
        
        NSLog(@"不能打开流");
        
        return ;
    }
    
    //查看视频流信息
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        
        NSLog(@"不能成功查看视频流信息");
        
        return ;
    }
    
    int i,videoIndex;
    
    videoIndex = -1;
    
    //对上下文中的视频流进行遍历
    for (i = 0; i<pFormatCtx->nb_streams; i++) {
        
        //找到视频流信息后跳出循环
#warning 注释的是弃用的，最新版本没有的方法
        //        if(pFormatCtx->streams[i]->codecpar->codec_type==AVMEDIA_TYPE_VIDEO){
        //
        //            videoIndex=i;
        //
        //            break;
        //
        ////        }
        //4.在多个数据流中找到视频流 类型为：AVMEDIA_TYPE_VIDEO
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            videoIndex=i;
            break;
        }
    }
    
    //若videoIndex还为初值那么说明没有找到视频流
    if(videoIndex==-1){
        
        NSLog(@"没有找到视频流");
        
        return ;
    }
    
    //声明编码器上下文结构体
    //这里新版本不再使用AVCodecContext这个结构体了,具体原因我也不太清楚,好像是AVCodecContext过于臃肿
    AVCodecContext	* pCodecCtx;
    
    pCodecCtx = pFormatCtx->streams[videoIndex]->codec;
    
    //声明解码器类型
    AVCodec	*pCodec;
    
    //查找解码器
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    
    if (pCodec == NULL) {
        
        NSLog(@"解码器没找到");
        
        return;
    }
    
    
    //打开解码器
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        NSLog(@"解码器打开失败");
        return;
    }
    
    //解码后的数据
    AVFrame *pFream,*pFreamYUV;
    
    pFream = av_frame_alloc();
    
    pFreamYUV = av_frame_alloc();
    
    uint8_t *out_buffer;
    
    //分配内存
    //根据像素格式,宽高分配
    out_buffer = (uint8_t *)av_malloc(avpicture_get_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height));
    
    //用ptr中的内容根据文件格式（YUV…） 和分辨率填充picture。这里由于是在初始化阶段，所以填充的可能全是零。
    avpicture_fill((AVPicture*)pFreamYUV, out_buffer, AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    
    //解码前的数据
    AVPacket *packet;
    
    //开辟空间
    packet =(AVPacket *)av_malloc(sizeof(AVPacket));
    
    /*******************************输出信息*********************************************/
    
    NSLog(@"--------------- File Information ----------------");
    
    //打印视频信息,av_dump_format()是一个手工调试的函数，能使我们看到pFormatCtx->streams里面有什么内容
    av_dump_format(pFormatCtx, 0, path, 0);
    
    NSLog(@"-------------------------------------------------");
    
    //主要用来对图像进行变化,这里是为了缩放,把黑边裁去
    struct SwsContext * img_convert_ctx;
    
    
    /**
     该函数包含以下参数：
     srcW：源图像的宽
     srcH：源图像的高
     srcFormat：源图像的像素格式
     dstW：目标图像的宽
     dstH：目标图像的高
     dstFormat：目标图像的像素格式
     flags：设定图像拉伸使用的算法
     成功执行的话返回生成的SwsContext，否则返回NULL。
     */
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                     pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);
    
    
    sprintf(info,   "[Input     ]%s\n", [filePath UTF8String]);
    sprintf(info, "%s[Output    ]%s\n",info,[output_str UTF8String]);
    sprintf(info, "%s[Format    ]%s\n",info, pFormatCtx->iformat->name);
    sprintf(info, "%s[Codec     ]%s\n",info, pCodecCtx->codec->name);
    sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
    printf("$$$$$$$$%s",info);
    FILE *fp_yuv;
    fp_yuv=fopen(output_str_full,"wb+");
    if(fp_yuv==NULL){
        printf("Cannot open output file.\n");
        return;
    }
    //解码序号
    int frame_cnt = 0;
    
    int got_picture_ptr = 0;
    
    //循环读取每一帧
    while (av_read_frame(pFormatCtx, packet)>=0) {
        
        //若为视频流信息
        if (packet->stream_index == videoIndex) {
            
            //解码一帧数据,输入一个压缩编码的结构体AVPacket，输出一个解码后的结构体AVFrame。
            int ret = avcodec_decode_video2(pCodecCtx, pFream, &got_picture_ptr, packet);
            
            //当解码失败
            if (ret < 0) {
                
                NSLog(@"解码失败");
                
                return;
            }
            
            if (got_picture_ptr) {
                //处理图像数据,用于转换像素
                //使用这个api非常耗性能
                //data解码后的图像像素数据
                //linesize对视频来说是一行像素的大小
                sws_scale(img_convert_ctx, (const uint8_t * const *)pFream->data, pFream->linesize, 0, pCodecCtx->height, pFreamYUV->data, pFreamYUV->linesize);
                //                NSInteger videoW = 512;
                //                NSInteger videoH = 288;
                //                self.openglView = [[OpenglView alloc] initWithFrame:CGRectMake(0, 64,screenSize, 300)];
                //
                //                [self.openglView setVideoSize:videoW height:videoH];
                //
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //
                //                    sleep(1);
                //
                //                    [self.openglView displayYUV420pData:pFreamYUV->data width:videoW height:videoH];
                //
                //                });
                //
                //                [self.view addSubview:self.openglView];
                //
                ///////自己加的
                int y_size;
                // 现在的pFrameYUv里面就是我们需要的yuv数据。
                // NSLog(@"-----pFrameYUV:%d",pFrameYUV->data);
                y_size=pCodecCtx->width*pCodecCtx->height;
                fwrite(pFreamYUV->data[0],1,y_size,fp_yuv);    //Y
                fwrite(pFreamYUV->data[1],1,y_size/4,fp_yuv);  //U
                fwrite(pFreamYUV->data[2],1,y_size/4,fp_yuv);  //V
                //Output info
                char pictype_str[10]={0};
                switch(pFream->pict_type){
                    case AV_PICTURE_TYPE_I:sprintf(pictype_str,"I");break;
                    case AV_PICTURE_TYPE_P:sprintf(pictype_str,"P");break;
                    case AV_PICTURE_TYPE_B:sprintf(pictype_str,"B");break;
                    default:sprintf(pictype_str,"Other");break;
                        
                        ///////////
                }
                
                NSLog(@"解码序号%d,Type:%s",frame_cnt,pictype_str);
                // NSLog(@"------pFreamYUV:%@",pFreamYUV);
                frame_cnt ++;
            }
        }
        
        //销毁packet
        av_free_packet(packet);
    }
    
    //销毁
    sws_freeContext(img_convert_ctx);
    
    av_frame_free(&pFreamYUV);
    
    av_frame_free(&pFream);
    
    avcodec_close(pCodecCtx);
    
    avformat_close_input(&pFormatCtx);
    
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
