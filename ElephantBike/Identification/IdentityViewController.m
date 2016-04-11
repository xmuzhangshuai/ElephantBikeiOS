//
//  IdentityViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/17.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "IdentityViewController.h"
#import "UISize.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MyURLConnection.h"
#import "QRCodeScanViewController.h"

//#define X   0.0267*SCREEN_WIDTH
#define X   0.04*SCREEN_WIDTH
#define Y   0.0150*SCREEN_HEIGHT
//#define WIDTH   0.9467*SCREEN_WIDTH
#define WIDTH   0.91*SCREEN_WIDTH

//#define SIMAGEVIEW_HEIGHT   0.342*SCREEN_HEIGHT
#define SIMAGEVIEW_HEIGHT   0.322*SCREEN_HEIGHT
//#define SCHOOLBUTTON_HEIGHT 0.084*SCREEN_HEIGHT
#define SCHOOLBUTTON_HEIGHT 0.06*SCREEN_HEIGHT

//#define COMMITBUTTON_WIDTH  0.75*SCREEN_WIDTH
#define COMMITBUTTON_WIDTH  0.8*SCREEN_WIDTH

#define CAMERABUTTON_WIDTH  0.43*SIMAGEVIEW_HEIGHT
#define CAMERABUTTON_X      (WIDTH-CAMERABUTTON_WIDTH)/2
#define CAMERABUTTON_Y      0.2*SIMAGEVIEW_HEIGHT

#define HINTMES_Y           0.7*SIMAGEVIEW_HEIGHT

@interface IdentityViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MyURLConnectionDelegate>

@end

@implementation IdentityViewController {
    UIImageView *studentImageView;  // 学生卡imageview
    UIButton    *cameraButton;      // 相框button
    UILabel     *hintMes;           // 提示信息label
    UIButton    *schoolButton;      // 选择学校按钮
    UITextField *nameTF;            // 姓名输入栏
    UITextField *numberTF;          // 学号输入栏
    UIButton    *commitButton;      // 提交按钮
    UILabel     *resultLabel;       // 提示label
    
    //选择学校视图
    UIView *chooseSchoolView;
    //学校列表
    UITableView *SchoolTableView;
    //学校数据
    NSMutableArray *listArray;
    //键盘的高度
    int keyBoardHeight;

    AppDelegate *MyDelegate;
    
    NSUserDefaults *userDefaults;
    
    NSString *studentCardUrl;       // 存储学生证url
    UIView      *cover;             // 等待动画背景图层
    NSUInteger  picNumber;          // 图片数量
    NSData      *studentData;       // 存储学生证照片数据
    
    NSMutableArray *schoolArary;    // 存储学校列表
}

- (id)init {
    if (self = [super init]) {
        studentImageView = [[UIImageView alloc] init];
        cameraButton = [[UIButton alloc] init];
        hintMes = [[UILabel alloc] init];
        schoolButton = [[UIButton alloc] init];
        nameTF = [[UITextField alloc] init];
        numberTF = [[UITextField alloc] init];
        commitButton = [[UIButton alloc] init];
        chooseSchoolView = [[UIView alloc] init];
        SchoolTableView = [[UITableView alloc] init];
        resultLabel = [[UILabel alloc] init];
        keyBoardHeight = 252;
        MyDelegate = [[UIApplication sharedApplication] delegate];
        userDefaults = [NSUserDefaults standardUserDefaults];
        studentData         = [[NSData alloc] init];
        schoolArary = [[NSMutableArray alloc] init];
        picNumber = 0;
    }
    return self;
}

#pragma mark - 导航栏设置
- (void)NavigationInit {
    self.navigationItem.title = @"身份认证";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backButton setTintColor:[UIColor grayColor]];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

#pragma mark - 控件布局
- (void)UILayout {
    studentImageView.frame = CGRectMake(X, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y, WIDTH, SIMAGEVIEW_HEIGHT);
    studentImageView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    CALayer *layer = [studentImageView layer];
    layer.borderColor = [UIColor colorWithRed:207.0/255 green:229.0/255 blue:187.0/255 alpha:1].CGColor;
    layer.borderWidth = 2;
    layer.masksToBounds = YES;
    layer.cornerRadius = 15;
    studentImageView.userInteractionEnabled = YES;
    
    cameraButton.frame = CGRectMake(CAMERABUTTON_X, CAMERABUTTON_Y, CAMERABUTTON_WIDTH, CAMERABUTTON_WIDTH);
    cameraButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];;
    [cameraButton setImage:[UIImage imageNamed:@"相机"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(choosePicture) forControlEvents:UIControlEventTouchUpInside];
    [studentImageView addSubview:cameraButton];

    
    hintMes.frame = CGRectMake(0, HINTMES_Y, WIDTH, SCHOOLBUTTON_HEIGHT);
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"请拍摄 学生卡有信息的一面 的照片"]];
    /** 更改label的字体大小及颜色*/
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:15] range:NSMakeRange(0, [content length]-3)];
    [content addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, [content length]-3)];
    [content addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(3, [content length]-3)];
    NSRange contentRange = {3,[content length]-3};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    hintMes.attributedText = content;
    hintMes.textAlignment = NSTextAlignmentCenter;
    [studentImageView addSubview:hintMes];
    
    schoolButton.frame = CGRectMake(X, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y*2+SIMAGEVIEW_HEIGHT, WIDTH, SCHOOLBUTTON_HEIGHT);
    schoolButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    schoolButton.layer.borderColor = [UIColor colorWithRed:207.0/255 green:229.0/255 blue:187.0/255 alpha:1].CGColor;
    schoolButton.layer.borderWidth = 2;
    schoolButton.layer.masksToBounds = YES;
    schoolButton.layer.cornerRadius = 6;
    [schoolButton setTitle:@"请选择学校" forState:UIControlStateNormal];
    [schoolButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    schoolButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    schoolButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [schoolButton addTarget:self action:@selector(getSchoolList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:schoolButton];
    
    nameTF.frame = CGRectMake(X, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y*3+SIMAGEVIEW_HEIGHT+SCHOOLBUTTON_HEIGHT, WIDTH, SCHOOLBUTTON_HEIGHT);
    nameTF.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    nameTF.layer.borderColor = [UIColor colorWithRed:207.0/255 green:229.0/255 blue:187.0/255 alpha:1].CGColor;
    nameTF.layer.borderWidth = 2;
    nameTF.layer.masksToBounds = YES;
    nameTF.layer.cornerRadius = 6;
    nameTF.placeholder = @"请输入姓名";
    /** 修改placeholder的字体颜色和大小*/
    [nameTF setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [nameTF setValue:[UIFont fontWithName:@"QingYuanMono" size:15] forKeyPath:@"_placeholderLabel.font"];
    nameTF.textAlignment = NSTextAlignmentCenter;
    /** 设置名字textfield的代理*/
    nameTF.delegate = self;
    [self.view addSubview:nameTF];
    
    numberTF.frame = CGRectMake(X, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y*4+SIMAGEVIEW_HEIGHT+SCHOOLBUTTON_HEIGHT*2, WIDTH, SCHOOLBUTTON_HEIGHT);
    numberTF.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    numberTF.layer.borderColor = [UIColor colorWithRed:207.0/255 green:229.0/255 blue:187.0/255 alpha:1].CGColor;
    numberTF.layer.borderWidth = 2;
    numberTF.layer.masksToBounds = YES;
    numberTF.layer.cornerRadius = 6;
    numberTF.placeholder = @"请输入学号";
    [numberTF setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [numberTF setValue:[UIFont fontWithName:@"QingYuanMono" size:15] forKeyPath:@"_placeholderLabel.font"];
    numberTF.textAlignment = NSTextAlignmentCenter;
    /** 设置代理*/
    numberTF.delegate = self;
    [self.view addSubview:numberTF];
    
    commitButton.frame = CGRectMake(X*2.5, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y*5+SIMAGEVIEW_HEIGHT+SCHOOLBUTTON_HEIGHT*3, COMMITBUTTON_WIDTH, SCHOOLBUTTON_HEIGHT);
    commitButton.backgroundColor = UICOLOR;
    commitButton.layer.cornerRadius = CORNERRADIUS;
    [commitButton setTitle:@"提交申请" forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    [commitButton addTarget:self action:@selector(commitImage) forControlEvents:UIControlEventTouchUpInside];
    
    resultLabel.frame = CGRectMake(X*2.5, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+Y*5+SIMAGEVIEW_HEIGHT+SCHOOLBUTTON_HEIGHT*3, COMMITBUTTON_WIDTH, SCHOOLBUTTON_HEIGHT);
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.hidden = YES;
    
    /** 选择学校的view*/
    chooseSchoolView.frame = CGRectMake(2.6*X, 0, commitButton.bounds.size.width, 0.54*SCREEN_HEIGHT);
    chooseSchoolView.center = CGPointMake(0.50*SCREEN_WIDTH, 0.50*SCREEN_HEIGHT);
    chooseSchoolView.layer.borderColor = [UIColor colorWithRed:207.0/255 green:229.0/255 blue:187.0/255 alpha:1].CGColor;
    chooseSchoolView.layer.borderWidth = 2;
    chooseSchoolView.layer.masksToBounds = YES;
    chooseSchoolView.layer.cornerRadius = 6;
    SchoolTableView.frame = chooseSchoolView.bounds;
    [chooseSchoolView addSubview:SchoolTableView];
    chooseSchoolView.hidden = YES;
    
    [self.view addSubview:resultLabel];
    [self.view addSubview:commitButton];
    [self.view addSubview:studentImageView];
    [self.view addSubview:chooseSchoolView];
    
    [self NavigationInit];
}

#pragma 按键点击选择学校
-(void)getSchoolList:(UIButton *)button{
    chooseSchoolView.hidden = NO;
}

#pragma  UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return schoolArary.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.textLabel.text = [schoolArary objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    chooseSchoolView.hidden = YES;
    //获得选择的学校名称
    //    NSString *string = listArray[indexPath.row];
    [schoolButton setTitle:[schoolArary objectAtIndex:indexPath.row] forState:UIControlStateNormal];
}


#pragma UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frame = textField.frame;
    
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - keyBoardHeight);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    // 上传学生证 后传url 姓名等信息
    if ([connection.name isEqualToString:@"studentCard"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        NSLog(@"图片url:%@", url);
        if ([status isEqualToString:@"success"]) {
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSLog(@"%@, %@, %@, %@", schoolButton.titleLabel.text, numberTF.text, nameTF.text, phoneNumber);
            studentCardUrl = url;
            // 将url上传服务器
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/authentication"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&stucard=%@&college=%@&stunum=%@&name=%@&access_token=%@", phoneNumber, studentCardUrl, schoolButton.titleLabel.text, numberTF.text, nameTF.text, accessToken];
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
            // 将图片缓存在本地
            [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:studentData] forKey:@"学生证" toDisk:YES];
            MyDelegate.isUpload = YES;
            
            NSLog(@"图片上传成功");
            [cover removeFromSuperview];
            // 上传成功
            resultLabel.text = @"信息审核中，结果将在2个工作日内通知您";
            resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
            cameraButton.hidden = YES;
            hintMes.hidden = YES;
            resultLabel.hidden = NO;
            if (SCREEN_WIDTH == 320) {
                resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
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
        NSString *studentImageurl = receiveJson[@"stucard"];
        NSString *name = receiveJson[@"name"];
        NSString *college = receiveJson[@"college"];
        NSString *stunum = receiveJson[@"stunum"];
        NSLog(@"获取身份认证信息：%@\n%@\n%@\n%@\n", studentImageurl, name, college, stunum);
        NSString *studentimageurl = [IP stringByAppendingString:@"/"];
        if ([status isEqualToString:@"success"]) {
            // 将信息缓存到本地
            [userDefaults setObject:name forKey:@"name"];
            [userDefaults setObject:college forKey:@"college"];
            [userDefaults setObject:stunum forKey:@"stunum"];
            nameTF.text = name;
            numberTF.text = stunum;
            [schoolButton setTitle:college forState:UIControlStateNormal];
            NSString *studentImageUrl = [studentimageurl stringByAppendingString:studentImageurl];
            __block UIActivityIndicatorView *activityIndicator;
            [studentImageView sd_setImageWithURL:[NSURL URLWithString:studentImageUrl] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                if (!activityIndicator)
                {
                    [studentImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                    activityIndicator.center = studentImageView.center;
                    [activityIndicator startAnimating];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
                if (image != nil) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:@"学生证" toDisk:YES];
                }else {
                    studentImageView.image = [UIImage imageNamed:@"黑色背景"];
                }
            }];
        }
    }else if ([connection.name isEqualToString:@"getAllCollege"]) {
        NSString *status = receiveJson[@"status"];
        NSLog(@"status:%@", status);
        if ([status isEqualToString:@"success"]) {
            NSArray *array = receiveJson[@"college"];
            NSLog(@"学校：%@", array);
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *schoolName = obj[@"name"];
                [schoolArary addObject:schoolName];
            }];
            SchoolTableView.delegate = self;
            SchoolTableView.dataSource = self;
            [SchoolTableView reloadData];
        }
    }
}

#pragma mark - 私有方法
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma 通知方法
-(void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary *info = [note userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //获取当前键盘的高度
    keyBoardHeight = keyboardSize.height;
    
}


#pragma 选择相片的方法
-(void)choosePicture{
    //判断当前是否支持相机拍照
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册中选择", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", nil];
    }
    [sheet showInView:self.view];
    
}

#pragma ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUInteger sourceType = 0;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
                //取消
            case 2:
                return;
                break;
                //相机
            case 0:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
                //相册
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
    //必须同时遵守UINavigationControllerDelgate协议和UIImagePickerControllerDelegate协议
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
#pragma imagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        [studentImageView setImage:savedImage];
        picNumber = 0;
        picNumber ++;
        [cameraButton removeFromSuperview];
        [hintMes removeFromSuperview];
        studentData = imageData;
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)commitImage {
    BOOL result = (![nameTF.text isEqualToString:@""] && ![numberTF.text isEqualToString:@""] && ![schoolButton.titleLabel.text isEqualToString:@"请选择学校"] && picNumber == 1);
    if (result) {
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
        NSLog(@"提交照片");
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/upload"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // 设置字典信息
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:studentData forKey:@"imageData"];
        [self setRequest:request andValue:param];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"studentCard"];
        // 使用http的post上传图片
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请完善信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)removeView {
    [cover removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 包装图片上传格式

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
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    // Do any additional setup after loading the view.
    [self UILayout];
    /** 获取键盘的高度 添加通知*/
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%d", MyDelegate.isUpload);
    if (MyDelegate.isUpload) {
        // 限制控件不能使用
        schoolButton.enabled = NO;
        nameTF.enabled = NO;
        numberTF.enabled = NO;
        
        cameraButton.hidden = YES;
        hintMes.hidden = YES;
        commitButton.hidden = YES;
        resultLabel.hidden = NO;
        resultLabel.text = @"信息审核中，结果将在2个工作日内通知您";
        resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
        if (SCREEN_WIDTH == 320) {
            resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
        }
        UIImage *studentCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"学生证"];
        if (studentCardImage == nil || [[userDefaults objectForKey:@"stunum"] isEqualToString:@""]) {
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/cardurl"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", [userDefaults objectForKey:@"phoneNumber"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getImageUrl"];
        }else {
            [studentImageView setImage:studentCardImage];
            nameTF.text = [userDefaults objectForKey:@"name"];
            numberTF.text = [userDefaults objectForKey:@"stunum"];
            [schoolButton setTitle:[userDefaults objectForKey:@"college"] forState:UIControlStateNormal];
        }
    }else if (MyDelegate.isIdentify) {
        // 限制控件不能使用
        schoolButton.enabled = NO;
        nameTF.enabled = NO;
        numberTF.enabled = NO;
        
        cameraButton.hidden = YES;
        hintMes.hidden = YES;
        commitButton.hidden = YES;
        resultLabel.hidden = NO;
        resultLabel.text = @"您已通过审核，开始使用大象单车吧";
        resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
        if (SCREEN_WIDTH == 320) {
            resultLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
        }
        UIImage *studentCardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"学生证"];
        if (studentCardImage == nil || [[userDefaults objectForKey:@"stunum"] isEqualToString:@""]) {
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/cardurl"];
            NSLog(@"请求图片ip:%@", urlStr);
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", [userDefaults objectForKey:@"phoneNumber"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getImageUrl"];
        }else {
            [studentImageView setImage:studentCardImage];
            nameTF.text = [userDefaults objectForKey:@"name"];
            numberTF.text = [userDefaults objectForKey:@"stunum"];
            [schoolButton setTitle:[userDefaults objectForKey:@"college"] forState:UIControlStateNormal];
        }
    }else {
        NSLog(@"请求学校列表");
        // 没有认证也没有上传，请求学校列表
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/allcollege"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getAllCollege"];
    }
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
