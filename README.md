# FFmpegDecodeH264_OpenGLESRenderYUV
FFmpegDecodeH264_OpenGLESRenderYUV
工程完整介绍参见技术论坛：http://www.jianshu.com/p/7f97bd0004db

1.FFmpeg解码
输入一个沙河内的视频文件（比如：flv格式，内存小）解码为一帧一帧的图片集合（像素格式，内存大）yuv

2.openGL渲染图片yuv数据
openGL渲染图片yuv数据
这里先渲染的是一张yuv图片,若屏幕出现绿色或打印说参数错误,一般是视频/图片的宽高不对引起的,请仔细查看资源宽高属性,

3.openGL渲染-H264解码
调用h264解码的类H264DecodeTool 进行mtv.h264或者mtv.mp4格式视频解码，解码为yuv，然后通过openGLES渲染显示解码后yuv。

4.播放器搭建：
就是之前编译的ffmpeg的库导入GitHub上的kxmovie：https://github.com/kolyvan/kxmovie
参见：我的文章：KxMovieViewController：http://www.jianshu.com/p/cd33f4ac10e5

更多资源欢迎进入学习交流平台：QQ群：224110749
有问题也可以联系我QQ:1107214478(一个做iOS开发的小生，但是我并不觉的我是在做iOS)

若是觉得对你有用，欢迎打赏：
![Image text](https://github.com/mrzhao12/FFmpegDecodeH264_OpenGLESRenderYUV/blob/master/img-folder/0279F8A0-048B-4796-95F0-7AEB69EEB6D5.png)

![Image text](https://github.com/mrzhao12/FFmpegDecodeH264_OpenGLESRenderYUV/blob/master/img-folder/A75FCB6C-5AB9-48BC-8098-BC3B37E363A6.png)

