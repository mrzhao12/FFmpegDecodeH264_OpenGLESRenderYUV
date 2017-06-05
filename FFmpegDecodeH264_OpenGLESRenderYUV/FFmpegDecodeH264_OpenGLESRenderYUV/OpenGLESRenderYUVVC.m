//
//  OpenGLESRenderYUVVC.m
//  FFmpegDecodeH264_OpenGLESRenderYUV
//
//  Created by sjhz on 2017/6/3.
//  Copyright © 2017年 sjhz. All rights reserved.
//

#import "OpenGLESRenderYUVVC.h"
#import "OpenGLView20.h"
@interface OpenGLESRenderYUVVC ()

@end

@implementation OpenGLESRenderYUVVC
{
    AVFormatContext	*pFormatCtx;
    int				videoindex;
    AVCodecContext	*pCodecCtx;
    AVCodec			*pCodec;
    
    OpenGLView20 * myview;

}
#pragma mark - lifeCycle
- (void)dealloc {
    //    [super dealloc];
    
    printf("%s\n",__func__);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OpenGLESRenderYUVVC";

    self.view.backgroundColor = [UIColor whiteColor];
//    [self decode];
    myview = [[OpenGLView20 alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 40)];
    [self.view addSubview:myview];
    
}

- (void)viewDidAppear:(BOOL)animated{
//- (void)decode{
//{
    [super viewDidAppear:animated];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"nwn" ofType:@"mp4"];
    //       NSString *path = [[NSBundle mainBundle] pathForResource:@"deream_320x192" ofType:@"264"];
//              NSString *path = [[NSBundle mainBundle] pathForResource:@"521_720x576" ofType:@"flv"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"air_320x240" ofType:@"264"];
    const char *filepath= [path UTF8String];
    
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    if(avformat_open_input(&pFormatCtx,filepath,NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        exit(1);
    }
    
    /*
     * av_find_stream_info()：ffmpeg版本更新后没有这个函数了，用avformat_find_stream_info这个函数，可以自己看一下版本更新改动
     */
    //    if(av_find_stream_info(pFormatCtx)<0)
    if(avformat_find_stream_info(pFormatCtx, NULL) < 0)
    {
        printf("Couldn't find stream information.\n");
        exit(1);
    }
    
    videoindex=-1;
    for(int i=0; i<pFormatCtx->nb_streams; i++)
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO)
        {
            videoindex=i;
            break;
        }
    if(videoindex==-1)
    {
        printf("Didn't find a video stream.\n");
        exit(1);
    }
    pCodecCtx=pFormatCtx->streams[videoindex]->codec;
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL)
    {
        printf("Codec not found.\n");
        exit(1);
    }
    /*
     * avcodec_open()：ffmpeg版本更新后没有这个函数了，用avformat_find_stream_info这个函数，可以自己看一下版本更新改动
     * avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, AVDictionary **options)
     */
    //    if(avcodec_open(pCodecCtx, pCodec)<0)
    if(avcodec_open2(pCodecCtx, pCodec, NULL)<0)
    {
        printf("Could not open codec.\n");
        exit(1);
    }
    AVFrame	*pFrame,*pFrameYUV;
//    pFrame=codec_alloc_frame();
//    pFrameYUV=avcodec_alloc_frame();
    
        pFrame=av_frame_alloc();
       pFrameYUV=av_frame_alloc();
    uint8_t *out_buffer;
    // PIX_FMT_YUV420P
//    out_buffer=new uint8_t[avpicture_get_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height)];
     out_buffer= avpicture_get_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    avpicture_fill((AVPicture *)pFrameYUV, out_buffer, AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    
    int ret, got_picture;
    int y_size = pCodecCtx->width * pCodecCtx->height;
    
    AVPacket *packet=(AVPacket *)malloc(sizeof(AVPacket));
    av_new_packet(packet, y_size);
    
    printf("video infomation：\n");
    av_dump_format(pFormatCtx,0,filepath,0);
    
    while(av_read_frame(pFormatCtx, packet)>=0)
    {
        if(packet->stream_index==videoindex)
        {
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if(ret < 0)
            {
                printf("Decode Error.\n");
                exit(1);
            }
            if(got_picture)
            {
                char *buf = (char *)malloc(pFrame->width * pFrame->height * 3 / 2);
                
                AVPicture *pict;
                int w, h;
                char *y, *u, *v;
                pict = (AVPicture *)pFrame;//这里的frame就是解码出来的AVFrame
                w = pFrame->width;
                h = pFrame->height;
                y = buf;
                u = y + w * h;
                v = u + w * h / 4;
                
                for (int i=0; i<h; i++)
                    memcpy(y + w * i, pict->data[0] + pict->linesize[0] * i, w);
                for (int i=0; i<h/2; i++)
                    memcpy(u + w / 2 * i, pict->data[1] + pict->linesize[1] * i, w / 2);
                for (int i=0; i<h/2; i++)
                    memcpy(v + w / 2 * i, pict->data[2] + pict->linesize[2] * i, w / 2);
                
                [myview setVideoSize:pFrame->width height:pFrame->height];
                [myview displayYUV420pData:buf width:pFrame->width height:pFrame->height];
                free(buf);
            }
        }
        av_free_packet(packet);
    }
//    delete[] out_buffer;
    out_buffer = nil;
    av_free(pFrameYUV);
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
