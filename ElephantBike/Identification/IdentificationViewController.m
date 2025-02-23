//
//  IdentificationViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "IdentificationViewController.h"
#import "UISize.h"
#import "MyURLConnection.h"
#import "AppDelegate.h"

// 保存本地图片
#import "UIImageView+WebCache.h"


#define SELECTBUTTON1_WIDTH  0.8*SAME_WIDTH
#define SELECTBUTTON1_HEIGHT 0.15*IDENTIFICATION_HEIGHT
#define SELECTBUTTON2_WIDTH  SELECTBUTTON1_WIDTH
#define SELECTBUTTON2_HEIGHT SELECTBUTTON1_HEIGHT
#define RESULTLABEL_WIDTH    SAME_WIDTH
#define RESULTLABEL_HEIGHT   COMMIT_HEIGHT

@interface IdentificationViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MyURLConnectionDelegate>
@property  (nonatomic, strong) NSString *IDCardName;
@end

@implementation IdentificationViewController {
    UIImageView *identificationFront;
    UIImageView *identificationBack;
    UIButton    *selectButton1;
    UIButton    *selectButton2;
    UIButton    *commitButton;
    UILabel     *resultLabel;
    
    NSData      *IDCard;
    NSData      *studentCard;
    
    NSString    *IDCardUrl;
    NSString    *studentCardUrl;
    
    BOOL        isButton1;
    int         pictureNumber;
    
    NSUserDefaults *userDefaults;
    UIView      *cover;
    AppDelegate *MyDelegate;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIInit];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%d", MyDelegate.isUpload);
    if (MyDelegate.isUpload) {
        selectButton1.hidden = YES;
        selectButton2.hidden = YES;
        resultLabel.text = @"信息审核中，结果将在2个工作日内通知您";
        resultLabel.font = [UIFont systemFontOfSize:14];
        [commitButton removeFromSuperview];
        [self.view addSubview:resultLabel];
        if (SCREEN_WIDTH == 320) {
            resultLabel.font = [UIFont systemFontOfSize:12];
        }
        UIImage *IDCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"身份证"];
        UIImage *studentCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"学生证"];
        if (!IDCardImage || !studentCardImage) {
            NSString *urlStr = [IP stringByAppendingString:@"/api/user/cardurl"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", [userDefaults objectForKey:@"phoneNumber"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getImageUrl"];
        }else {
            [identificationFront setImage:IDCardImage];
            [identificationBack setImage:studentCardImage];
        }
    }else if (MyDelegate.isIdentify) {
        selectButton1.hidden = YES;
        selectButton2.hidden = YES;
        resultLabel.text = @"您已通过审核，开始使用大象单车吧";
        resultLabel.font = [UIFont systemFontOfSize:14];
        [commitButton removeFromSuperview];
        [self.view addSubview:resultLabel];
        if (SCREEN_WIDTH == 320) {
            resultLabel.font = [UIFont systemFontOfSize:12];
        }
        UIImage *IDCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"身份证"];
        UIImage *studentCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"学生证"];
        if (!IDCardImage || !studentCardImage) {
            NSString *urlStr = [IP stringByAppendingString:@"/api/user/cardurl"];
            NSLog(@"请求图片ip:%@", urlStr);
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", [userDefaults objectForKey:@"phoneNumber"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getImageUrl"];
        }else {
            [identificationFront setImage:IDCardImage];
            [identificationBack setImage:studentCardImage];
        }
    }
}

#pragma mark - Private Method
- (void)UIInit {
    identificationFront = [[UIImageView alloc]init];
    identificationBack  = [[UIImageView alloc]init];
    selectButton1       = [[UIButton alloc] init];
    selectButton2       = [[UIButton alloc] init];
    commitButton        = [[UIButton alloc]init];
    resultLabel         = [[UILabel alloc] init];
    pictureNumber       = 0;
    IDCard              = [[NSData alloc] init];
    studentCard         = [[NSData alloc] init];
    
    userDefaults        = [NSUserDefaults standardUserDefaults];
    MyDelegate          = [[UIApplication sharedApplication] delegate];
    
    [self NavigationInit];
    [self UILayout];
}

- (void)UILayout {
    identificationFront.frame = CGRectMake(0.1*SCREEN_WIDTH, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+COMMIT_HEIGHT, SAME_WIDTH, IDENTIFICATION_HEIGHT);
    identificationFront.image = [UIImage imageNamed:@"身份证正面"];
    identificationFront.contentMode = UIViewContentModeScaleToFill;
    identificationFront.userInteractionEnabled = YES;
    
    
    identificationBack.frame = CGRectMake(0.1*SCREEN_WIDTH, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+COMMIT_HEIGHT*2+IDENTIFICATION_HEIGHT, SAME_WIDTH, IDENTIFICATION_HEIGHT);
    identificationBack.image = [UIImage imageNamed:@"身份证正面"];
    identificationBack.contentMode = UIViewContentModeScaleToFill;
    identificationBack.userInteractionEnabled = YES;
    
    if (!(MyDelegate.isUpload || MyDelegate.isIdentify)) {
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] init];
        [tap1 addTarget:self action:@selector(chooseImage1)];
        [identificationFront addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
        [tap2 addTarget:self action:@selector(chooseImage2)];
        [identificationBack addGestureRecognizer:tap2];
    }
    
    selectButton1.frame = CGRectMake(0.1*SAME_WIDTH, (IDENTIFICATION_HEIGHT-SELECTBUTTON1_HEIGHT)/2, SELECTBUTTON1_WIDTH, SELECTBUTTON1_HEIGHT);
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc] initWithString:@"点击上传身份证正面照片"];
    NSRange title1Rnage = {0, [title1 length]};
    [title1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:title1Rnage];
    [selectButton1 setAttributedTitle:title1 forState:UIControlStateNormal];
    [selectButton1 addTarget:self action:@selector(chooseImage1) forControlEvents:UIControlEventTouchUpInside];
    
    selectButton2.frame = CGRectMake(0.1*SAME_WIDTH, (IDENTIFICATION_HEIGHT-SELECTBUTTON1_HEIGHT)/2, SELECTBUTTON1_WIDTH, SELECTBUTTON1_HEIGHT);
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"点击上传学生证正面照片"];
    NSRange titleRnage = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRnage];
    [selectButton2 setAttributedTitle:title forState:UIControlStateNormal];
    [selectButton2 addTarget:self action:@selector(chooseImage2) forControlEvents:UIControlEventTouchUpInside];
    
    commitButton.frame = CGRectMake((SCREEN_WIDTH-COMMIT_WIDTH)/2, SCREEN_HEIGHT-COMMIT_HEIGHT*2, COMMIT_WIDTH, COMMIT_HEIGHT);
    [commitButton setTitle:@"提交申请" forState:UIControlStateNormal];
    commitButton.backgroundColor = UICOLOR;
    commitButton.layer.cornerRadius = CORNERRADIUS;
    [commitButton addTarget:self action:@selector(commitImage) forControlEvents:UIControlEventTouchUpInside];
    
    // 结果label
    resultLabel.frame = CGRectMake((SCREEN_WIDTH-RESULTLABEL_WIDTH)/2, SCREEN_HEIGHT-RESULTLABEL_HEIGHT*2, RESULTLABEL_WIDTH, RESULTLABEL_HEIGHT);
    resultLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:identificationFront];
    [self.view addSubview:identificationBack];
    [identificationFront addSubview:selectButton1];
    [identificationBack addSubview:selectButton2];
    [self.view addSubview:commitButton];
}

- (void)NavigationInit {
    self.navigationItem.title = @"身份认证";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Button Event
- (void)back {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)chooseImage1 {
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册中选择", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", nil];
    }
    isButton1 = YES;
    [sheet showInView:self.view];
}

- (void)chooseImage2 {
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册中选择", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", nil];
    }
    isButton1 = NO;
    [sheet showInView:self.view];
}

- (void)commitImage {
    if (pictureNumber == 2) {
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
        
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"正在提交";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
        [self.view addSubview:cover];
        NSLog(@"提交照片");
        NSString *urlStr = [IP stringByAppendingString:@"/api/file/upload"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // 设置字典信息
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:IDCard forKey:@"imageData"];
        [self setRequest:request andValue:param];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"IDCard"];
        // 使用http的post上传图片
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择图片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)setRequest:(NSMutableURLRequest *)request andValue:(NSDictionary *)valueDictionary {
    // 分界线标识符
    NSString *boundary = @"AaB03x";
    NSString *MPboundary = [NSString stringWithFormat:@"--%@", boundary];
    NSString *endMPboundary = [NSString stringWithFormat:@"%@--", MPboundary];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    
    [body appendString:[NSString stringWithFormat:@"%@\r\n", MPboundary]];
    [body appendFormat:@"Content-Disposition: form-data; name=\"ImageField\"; filename=\"x1234.png\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:[valueDictionary objectForKey:@"imageData"]];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@",boundary];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"IDCard"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"第一张上传成功");
            IDCardUrl = url;
            NSString *urlStr = [IP stringByAppendingString:@"/api/file/upload"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            // 设置字典信息
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:studentCard forKey:@"imageData"];
            [self setRequest:request andValue:param];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"studentCard"];
        }else {
            // 图片上传失败
            [cover removeFromSuperview];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"studentCard"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        if ([status isEqualToString:@"success"]) {
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            studentCardUrl = url;
            // 将url上传服务器
            NSString *urlStr = [IP stringByAppendingString:@"/api/user/authentication"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&idcard=%@&stucard=%@&access_token=%@", phoneNumber, IDCardUrl, studentCardUrl, accessToken];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"uploadUrl"];
        }else {
            // 图片上传失败
            [cover removeFromSuperview];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"uploadUrl"]) {
        NSString *status = receiveJson[@"status"];
        if ([status isEqualToString:@"success"]) {
            // 将这两张图片缓存在本地
            [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:IDCard] forKey:@"身份证" toDisk:YES];
            [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:studentCard] forKey:@"学生证" toDisk:YES];
            MyDelegate.isUpload = YES;
            
            NSLog(@"图片上传成功");
            [cover removeFromSuperview];
            // 上传成功
            resultLabel.text = @"信息审核中，结果将在2个工作日内通知您";
            resultLabel.font = [UIFont systemFontOfSize:14];
            [commitButton removeFromSuperview];
            [self.view addSubview:resultLabel];
            if (SCREEN_WIDTH == 320) {
                resultLabel.font = [UIFont systemFontOfSize:12];
            }
            // 集成api  此处是膜
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            
            UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes1.text = @"提交成功";
            hintMes1.textColor = [UIColor whiteColor];
            hintMes1.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes1];
            
            [self.view addSubview:cover];
            // 显示时间
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }else {
            // 图片上传失败
            [cover removeFromSuperview];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"getImageUrl"]) {
        NSString *status = receiveJson[@"status"];
        NSString *IDCardImageurl = receiveJson[@"idcard"];
        NSString *studentImageurl = receiveJson[@"stucard"];
        NSString *IDCardimageurl = [IP stringByAppendingString:@"/"];
        NSString *studentimageurl = [IP stringByAppendingString:@"/"];
        if ([status isEqualToString:@"success"]) {
            NSString *IDCardImageUrl = [IDCardimageurl stringByAppendingString:IDCardImageurl];
            NSString *studentImageUrl = [studentimageurl stringByAppendingString:studentImageurl];
            __block UIActivityIndicatorView *activityIndicator;
            [identificationFront sd_setImageWithURL:[NSURL URLWithString:IDCardImageUrl] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                if (!activityIndicator)
                {
                    [identificationFront addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                    activityIndicator.center = identificationFront.center;
                    [activityIndicator startAnimating];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
                // 将这两张图片缓存在本地
                [[SDImageCache sharedImageCache] storeImage:image forKey:@"身份证" toDisk:YES];
                
            }];
            [identificationBack sd_setImageWithURL:[NSURL URLWithString:studentImageUrl] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                if (!activityIndicator)
                {
                    [identificationBack addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                    activityIndicator.center = identificationBack.center;
                    [activityIndicator startAnimating];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
                [[SDImageCache sharedImageCache] storeImage:image forKey:@"学生证" toDisk:YES];
            }];
        }
    }
}

- (void)removeView {
    [cover removeFromSuperview];
}

- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
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
    hintMes.text = @"无法连接网络";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    [self.view addSubview:cover];
}

#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUInteger sourceType = 0;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 2:
                return;
                break;
            case 0:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            default:
                break;
        }
    } else {
        if (buttonIndex == 1) {
            return  ;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
//    [self.navigationController pushViewController:imagePickerController animated:YES];
}

#pragma mark - ImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
//    [self.navigationController popViewControllerAnimated:YES];
    UIImage *savedImage1 = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *savedImage;
    NSData *imageData = UIImageJPEGRepresentation(savedImage1, 1);
    if (([[self typeForImageData:imageData] isEqualToString:@"jpg"] || [[self typeForImageData:imageData] isEqualToString:@"png"] || [[self typeForImageData:imageData] isEqualToString:@"gif"])) {
        // 图片不符合格式
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择jpg/png/gif格式" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        // 图片压缩
        for (int i = 9; i > 0; i--) {
            CGFloat scale = i*0.1;
            imageData = UIImageJPEGRepresentation(savedImage1, scale);
            savedImage = [[UIImage alloc] initWithData:imageData];
            if (imageData.length/1024 < 1000) {
                break;
            }
        }
        if (isButton1) {
            [identificationFront setImage:savedImage];
            IDCard = imageData;
            pictureNumber++;
            [selectButton1 removeFromSuperview];
        }else {
            [identificationBack setImage:savedImage];
            studentCard = imageData;
            pictureNumber++;
            [selectButton2 removeFromSuperview];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"picker 撤销");
    }];
//    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"哈哈哈");
}

- (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
    }
    return nil;
}


#pragma mark - 保存图片到沙盒
//- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
//    // 高保真压缩图片方法
//    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
//    // 沙盒目录
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
//    [imageData writeToFile:fullPath atomically:NO];
//}

#pragma mark - 点击图片预览，滑动放大缩小，带动画
/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    isFullScreen = !isFullScreen;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGPoint imagePoint = identificationFront.frame.origin;
    if (imagePoint.x <= touchPoint.x && imagePoint.x + identificationFront.frame.size.width >= touchPoint.x && imagePoint.y <= touchPoint.y && imagePoint.y + identificationFront.frame.size.height >= touchPoint.y) {
        // 图片放大
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        CGRect originFrame = identificationFront.frame;
        if (isFullScreen) {
            identificationFront.frame = [[UIScreen mainScreen] bounds];
        } else {
            identificationFront.frame = originFrame;
        }
        [UIView commitAnimations];
    }
}
*/
@end
