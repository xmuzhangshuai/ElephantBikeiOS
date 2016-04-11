//
//  QuestionDetailViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/28.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "UISize.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import "MyURLConnection.h"
#import "lame.h"
#import "AppDelegate.h"
#import "ChargeViewController.h"
#import "PayViewController.h"

/**
 *  ASI部分
 **/
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define kRecordAudioFile @"myRecord.caf"
#define documentPath    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface QuestionDetailViewController ()<AVAudioRecorderDelegate, MyURLConnectionDelegate, AVAudioPlayerDelegate, ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UILabel *QuestionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *FirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *SecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *ThirdLabel;
@property (weak, nonatomic) IBOutlet UIView *QuestionDetailView;

@end

@implementation QuestionDetailViewController{
    /** 确定提交按钮*/
    UIButton *confirmButton;
    /** 录音功能按钮*/
    UIButton *speakButton;
    //textfield的内容
    
    
    /** 创建录音对象*/
    AVAudioRecorder *recorder;
    AVAudioSession *audioSession;
    /** 创建播放对象*/
    AVAudioPlayer *audioPlayer;
    /** 录音声波监控*/
    NSTimer *timer;
    /** 音频波动*/
//    UIProgressView *audioPower;
    
    /** 长按之后的动画效果，callView*/
    UIView *callView;
    UIImageView *VoiceImageView;
    UIView *maskView;
    
    
    /** 录音结束后要获取该录音文件*/
    NSFileManager *fileManager;
    /** 获取录音文件 data*/
    NSData *RecordData;
    
    /** mp3文件目录*/
    NSString *mp3FilePath;
    NSData *mp3Data;
    
    
    NSUserDefaults *userDefaults;
    
    BOOL ismissing;
    
    // 返回的录音url
    NSString *voiceUrl;
    
    AppDelegate *myAppDelegate;
    
    UIView *cover;
    
    PayViewController *payViewController;
}


-(id)init{
    if (self == [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        fileManager = [NSFileManager defaultManager];
        RecordData = [[NSData alloc] init];
        mp3FilePath = [[NSString alloc] init];
        mp3Data = [[NSData alloc] init];
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        cover = [[UIView alloc] init];
        payViewController = [[PayViewController alloc] init];
    }
    return self;
}


-(void)NavigationInit{
    self.navigationItem.title = @"遇到问题";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backQuestionView)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

-(void)UIInit{
    confirmButton = [[UIButton alloc] init];
    speakButton = [[UIButton alloc] init];
    self.QuestionDetailView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    
    [self setTitleLabel];
 

    /** 设置音频会话*/
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    /** 录音机对象*/
    NSURL *url = [self getSavePath];
    NSDictionary *setting = [self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    recorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    recorder.delegate=self;
    recorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    /** 定时器*/
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    
    /** 音频波动的progressView*/
//    audioPower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    
    /** 动画效果View*/
    callView = [[UIView alloc] init];
    maskView = [[UIView alloc] init];
    VoiceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yinjie(6) @2x.png"]];
    
    
    
    [self UILayout];
    
}

-(void)UILayout{
    confirmButton.frame = CGRectMake(0, 0, 0.8*SCREEN_WIDTH, 0.06*SCREEN_HEIGHT);
    confirmButton.center = CGPointMake(0.50*SCREEN_WIDTH, 0.95*SCREEN_HEIGHT);
//    [confirmButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self setconfirmButtonTitle];
    [confirmButton addTarget:self action:@selector(commitRecord) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    confirmButton.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];
    confirmButton.layer.masksToBounds = YES;
    confirmButton.layer.cornerRadius = 6;

    
    speakButton.frame = CGRectMake(0, 0, 0.281*SCREEN_WIDTH, 0.151*SCREEN_HEIGHT);
    speakButton.center = CGPointMake(0.50*SCREEN_WIDTH, 0.80*SCREEN_HEIGHT);
    speakButton.backgroundColor = [UIColor greenColor];
    speakButton.layer.masksToBounds = YES;
    speakButton.layer.cornerRadius = 15;
    
//    audioPower.center = CGPointMake(0.5*SCREEN_WIDTH, 0.5*SCREEN_HEIGHT);
    
    
    
    /** 添加长按手势按钮*/
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGR:)];
    longPressGR.allowableMovement = NO;
    longPressGR.minimumPressDuration = 0.2;
    [speakButton addGestureRecognizer:longPressGR];
    
    
    self.QuestionNameLabel.text = self.QuestionName;
    self.QuestionNameLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    if ([self.QuestionName isEqualToString:@"在计费期间单车丢失"]) {
        speakButton.hidden = YES;
    }
    
    
    /** 设置语音动画效果*/
    callView.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    callView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    callView.hidden = YES;
    
    VoiceImageView.frame = CGRectMake(0, 0, callView.frame.size.width/2, callView.frame.size.height/2);
    VoiceImageView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    
    
    
    
    
    [callView addSubview:VoiceImageView];
    [self.view addSubview:callView];
    [self.view addSubview:confirmButton];
    [self.view addSubview:speakButton];
//    [self.view addSubview:audioPower];
    
    
}

#pragma  mark - 录音文件的保存路径
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];

    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

#pragma mark - 录音设置
-(NSDictionary *)getAudioSetting{
    
    /** 录音设置*/
    /*NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    //设置录音格式
    [recordSetting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    [recordSetting setObject:@(kAudioFormatMPEGLayer3) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [recordSetting setObject:@(44100.0) forKey:AVSampleRateKey];
    //设置通道,这里采用双声道，转换成MP3格式必须是双声道
    [recordSetting setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [recordSetting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [recordSetting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //音频质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];*/
    NSDictionary *recordSetting = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16],
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
    return recordSetting;
}

#pragma mark - 长按按钮响应事件
-(void)longPressGR:(UILongPressGestureRecognizer *)ParamSender{
    if (ParamSender.state == UIGestureRecognizerStateBegan) {
        callView.hidden = NO;
        NSLog(@"开始");
        // 收到验证码  进行提示
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 一个控件
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"正在录音";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
        [self.view addSubview:cover];
        [recorder record];
        timer.fireDate = [NSDate distantPast];
    }
    if (ParamSender.state == UIGestureRecognizerStateEnded) {
        [cover removeFromSuperview];
        NSLog(@"结束");
        callView.hidden = YES;
        [timer invalidate];
        timer = nil;
        [recorder stop];
        timer.fireDate = [NSDate distantFuture];
//        audioPower.progress = 0.0;
    }
}

#pragma mark - 录音 动画设置
-(void)changImage{
    [recorder updateMeters];//更新测量值
    float avg = [recorder averagePowerForChannel:0];
    float minValue = -60;
    float range = 60;
    float outRange = 100;
    if (avg < minValue) {
        avg = minValue;
    }
    float decibels = (avg + range) / range * outRange;
//    maskH.constant = _yinjieBtn.frame.size.height - decibels * _yinjieBtn.frame.size.height / 100;
    maskView.layer.frame = CGRectMake(0, VoiceImageView.frame.size.height - decibels * VoiceImageView.frame.size.height / 100, VoiceImageView.frame.size.width, VoiceImageView.frame.size.height);
    [VoiceImageView.layer setMask:maskView.layer];
}



#pragma  mark - 录音声波设置
-(void)audioPowerChange{
    /** 更新测试值*/
    [recorder updateMeters];
    float power = [recorder averagePowerForChannel:0];
    CGFloat progress = (1.0/160.0)*(power+160.0);
//    [audioPower setProgress:progress];
}


#pragma mark - 录音机代理方法
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    if (![audioPlayer isPlaying]) {
//        [audioPlayer play];
     [self cafToMp3:[documentPath stringByAppendingPathComponent:kRecordAudioFile]];
    NSError *error = nil;
    NSLog(@"mp3播放器初始化中的路径：%@", mp3FilePath);
//    AVAudioPlayer *secondPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:mp3FilePath] error:&error];
//    [secondPlay play];
//    }
    if (flag) {
        NSLog(@"录音完成");
    }
//    RecordData = [NSData dataWithContentsOfFile:[documentPath stringByAppendingPathComponent:kRecordAudioFile]];
//    NSLog(@"RecordData:.......%@", RecordData);
   
    mp3Data = [NSData dataWithContentsOfFile:mp3FilePath];
    NSLog(@"mp3Data:.....%@", mp3Data);
    
    
    //确定文件是否存在
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSLog(@"%@", path);
//    /** 获取当前文件的子文件夹*/
//    NSArray *subPath = [fileManager subpathsAtPath:path];
//    NSLog(@"subPath: %@", subPath);
//    for (NSString *audioPath in subPath) {
//        if ([audioPath.pathExtension isEqualToString:@"caf"]) {
//            [audioPathList addObject:[path stringByAppendingPathComponent:audioPath]];
////            [audioPathList addObject:audioPath];
//            NSLog(@"audioPath: %@", audioPath);
//        }
//    }
//    NSLog(@"%@", audioPathList);
//    NSData *data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:audioPathList[0]]];
    
//    NSLog(@"data:,...%@", RecordData);
    
}


#pragma mark - sendRequest
-(void)requestForDetailQuestion{
    if (![self.QuestionName isEqualToString:@"在计费期间单车丢失"]) {
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/uploadvoice"];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setFile:mp3FilePath forKey:@"file"];
        [request setDelegate:self];
        [request startAsynchronous];
    }else {
        myAppDelegate.isMissing = YES;
        // 提交问题类型，跳回到计费页面
        NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&voiceurl=%@", bikeno, phoneNumber, self.QuestionName, voiceUrl];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"uploadQues"];
    }
}

#pragma mark - ASI代理
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
    NSDictionary *receiveData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveData[@"status"];
    NSLog(@"status:..%@", status);
    if ([status isEqualToString:@"success"]) {
        NSString *receiveurl = receiveData[@"url"];
        NSLog(@"url:..%@", receiveurl);
        voiceUrl = receiveurl;
        NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        if([self.QuestionName isEqualToString:@"输入密码后无法开锁"] || [self.QuestionName isEqualToString:@"锁车后不显示还车密码或还车密码错误"]) {
            myAppDelegate.isFreeze = YES;
        }
        // 提交问题类型，跳回到计费页面
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&voiceurl=%@", bikeno, phoneNumber, self.QuestionName, voiceUrl];
        NSLog(@"bikeno%@, phone=%@, type%@, voiceurl%@", bikeno, phoneNumber, self.QuestionName, voiceUrl);
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"uploadQues"];
    }else {
        [cover removeFromSuperview];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的网络忙，提交失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [cover removeFromSuperview];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的网络忙，提交失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma  mark - 服务器返回
-(void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data{
    NSDictionary *receiveData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveData[@"status"];
    NSLog(@"status%@", status);
    self.delegate = payViewController;
    if ([connection.name isEqualToString:@"uploadQues"]) {
        if ([status isEqualToString:@"success"]) {
            // 上传成功 判断，分为2种情况 跳到计费页面和跳到付款页面
            if ([self.QuestionName isEqualToString:@"不影响还车的损坏问题"]) {
                [cover removeFromSuperview];
                // 收到验证码  进行提示
                cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                cover.alpha = 1;
                // 半黑膜
                UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
                containerView.backgroundColor = [UIColor blackColor];
                containerView.alpha = 0.8;
                containerView.layer.cornerRadius = CORNERRADIUS*2;
                [cover addSubview:containerView];
                // 一个控件
                UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
                hintMes.text = @"提交成功";
                hintMes.textColor = [UIColor whiteColor];
                hintMes.textAlignment = NSTextAlignmentCenter;
                [containerView addSubview:hintMes];
                [self.view addSubview:cover];
                // 显示时间
                NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            }else {
                if ([self.QuestionName isEqualToString:@"在计费期间单车丢失"]) {
                    NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
                    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/missbikefee"];
                    NSURL *url = [NSURL URLWithString:urlStr];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                    NSLog(@"bikeid=%@, phone=%@, type=%@, ismissing=%d", bikeno, phoneNumber, self.QuestionName, myAppDelegate.isMissing);
                    NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&ismissing=%d", bikeno, phoneNumber, self.QuestionName, 1];
                    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                            [request setHTTPBody:data];
                    [request setHTTPMethod:@"POST"];
                    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMissBikeFee"];
                }else {
                    // 另外两个问题类型
                    // 获取使用时长 金额
                    // 请求服务器 异步post
                    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
                    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                    NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
                    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
                    NSURL *url = [NSURL URLWithString:urlStr];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@&isfinish=%d&isnatural=%d", phoneNumber, bikeNo, accessToken, 1, 2];
                    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                    [request setHTTPBody:data];
                    [request setHTTPMethod:@"POST"];
                    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMoney"];
                }
            }
        }else {
            [cover removeFromSuperview];
            NSString *message = receiveData[@"message"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"getMoney"]) {
        // 解析数据
        // 需要根据time来判断是丢车还是无法还车
        myAppDelegate.isEndRiding = YES;
        NSString *status = receiveData[@"status"];
        NSString *fee = receiveData[@"fee"];
        NSString *time = receiveData[@"time"];
        NSLog(@"fee:%@, time:%@", fee, time);
        if ([status isEqualToString:@"success"]) {
            [cover removeFromSuperview];
            [self.delegate getMoney:fee/*服务器获取*/ andTime:time/*服务器获取*/ andIsLose:NO];
            // 收到验证码  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            // 一个控件
            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes.text = @"提交成功";
            hintMes.textColor = [UIColor whiteColor];
            hintMes.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes];
            [self.view addSubview:cover];
            // 显示时间
            NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        }
    }else if ([connection.name isEqualToString:@"getMissBikeFee"]) {
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.isEndRiding = YES;
            NSString *fee = receiveData[@"fee"];
            [self.delegate getMoney:fee andTime:@"" andIsLose:YES];
            [cover removeFromSuperview];
            // 收到验证码  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            // 一个控件
            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes.text = @"提交成功";
            hintMes.textColor = [UIColor whiteColor];
            hintMes.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes];
            [self.view addSubview:cover];
            // 显示时间
            NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        }
    }
}
#pragma mark - 连接超时
-(void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"请求失败");
}

- (void)removeView {
    [cover removeFromSuperview];
    if (![self.QuestionName isEqualToString:@"不影响还车的损坏问题"]) {
        myAppDelegate.isEndRiding = YES;
        [self.navigationController pushViewController:payViewController animated:YES];
    }else {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[ChargeViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }
}



#pragma mark - confirmButtonTitle and commitRecord
-(void)setconfirmButtonTitle{
    if ([self.QuestionName isEqualToString:@"输入密码后无法开锁" ]) {
        [confirmButton setTitle:@"确定无法解锁" forState:UIControlStateNormal];
    }else if ([self.QuestionName isEqualToString:@"在计费期间单车丢失" ]) {
        [confirmButton setTitle:@"确认丢失" forState:UIControlStateNormal];
    }else if ([self.QuestionName isEqualToString:@"锁车后不显示还车密码或还车密码错误" ]) {
        [confirmButton setTitle:@"确认无法还车" forState:UIControlStateNormal];
    }else if ([self.QuestionName isEqualToString:@"不影响还车的损坏问题"]){
        [confirmButton setTitle:@"确认提交" forState:UIControlStateNormal];
    }
}

-(void)commitRecord{
    NSFileManager *fileManager1 = [NSFileManager defaultManager];
    if ([fileManager1 fileExistsAtPath:mp3FilePath] || [self.QuestionName isEqualToString:@"在计费期间单车丢失"]) {
        //验证等待动画
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"正在提交";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:cover];
        [self requestForDetailQuestion];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请录入您的语音" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


#pragma mark - back
-(void)backQuestionView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self UIInit];
    [self NavigationInit];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSFileManager *fileManager1 = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:mp3FilePath]) {
        [fileManager1 removeItemAtPath:mp3FilePath error:nil];
    }
}

#pragma mark - 界面显示
-(void)setTitleLabel{
     self.FirstLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
     self.SecondLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
     self.ThirdLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    
    if ([self.QuestionName isEqualToString:@"输入密码后无法开锁"]) {
        self.FirstLabel.text = @"由于大象车锁的自身问题，可能存在输入密码后无法开锁的情况，请您通过语音方式向我们描述具体情况，经工作人员核实后，您将获得5元误时赔偿。";
        self.SecondLabel.text = [NSString stringWithFormat:@"语音描述：\n请您尽可能详细的描述单车停放的具体位置和具体问题，以便我们工作人员尽快找到问题单车"];
        self.ThirdLabel.text =  [NSString stringWithFormat:@"其他说明：\n请您再次确认车锁无法被打开，当您点击“确认无法开锁后”，您的账户会被临时锁定，待工作人员找到问题单车后即可解锁，时间一般不超过3小时。"];
       
    }
    if ([self.QuestionName isEqualToString:@"在计费期间单车丢失"]) {
        self.FirstLabel.text = @"在计费期间，如果由于您的疏忽导致您借用的单车丢失，您需要赔偿由于单车丢失，所带来的财产损失";
        self.SecondLabel.text = [NSString stringWithFormat:@"赔偿金额：\n300元/辆"];
        self.ThirdLabel.text = [NSString stringWithFormat:@"其他说明：\n请您再次确认您借用的单车已经丢失，当您点击“确认丢失后”，您的账户会被锁定，在您支付了赔偿金后即可解锁。"];
    }
    if ([self.QuestionName isEqualToString:@"锁车后不显示还车密码或还车密码错误"]) {
        self.FirstLabel.text = @"由于大象车锁的自身问题，可能存在锁车后不显示还车密码或提示还车密码错误的情况，请您在确认车锁已经被锁上后，通过语音方式向我们描述具体情况";
        self.SecondLabel.text = [NSString stringWithFormat:@"语音描述：\n请您尽可能详细地描述单车停放的具体位置和具体问题，以便我们的工作人员尽快找到问题单车。"];
        self.ThirdLabel.text = @"其他说明：\n请您再次确认已经将车锁锁上，当您点击“确认无法还车”后，您的账户会被临时锁定，待工作人员找到问题单车后即可解锁，时间一般不超过3个小时。";
    }
    if ([self.QuestionName isEqualToString:@"不影响还车的损坏问题"]) {
        self.FirstLabel.text = @"我们非常抱歉由于单车损坏没能提供最好的骑行服务，您不需要为任何原因的损坏负有责任，如果您能通过语音方式向我们描述损坏的具体情况，我们将不胜感激！";
        self.SecondLabel.text = @"语音描述：\n请您尽可能详细地描述单车停放的具体位置和具体问题，以便我们的工作人员尽快找到问题单车。";
        self.ThirdLabel.hidden = YES;
    }
    
}



#pragma mark - caf文件转mp3
- (void)cafToMp3:(NSString*)cafFileName
{
    mp3FilePath = [documentPath stringByAppendingPathComponent:@"record.mp3"];
    if([fileManager removeItemAtPath:mp3FilePath error:nil]){
        NSLog(@"删除");
    }
    @try {
        int read, write;
        FILE *pcm = fopen([cafFileName cStringUsingEncoding:1], "rb");
        fseek(pcm, 4*1024, SEEK_CUR); 
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        //Detrming the size of mp3 file
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSData *data = [fileManger contentsAtPath:mp3FilePath];
        NSString* str = [NSString stringWithFormat:@"%lu K",[data length]/1024];
        NSLog(@"size of mp3=%@",str);
    }
}


#pragma mark - ReceiveMemoryWarning

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
