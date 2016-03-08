//
//  QuestionViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/19.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "QuestionViewController.h"
#import "UISize.h"
#import "PayViewController.h"
#import "MyTableViewCell.h"
#import "AppDelegate.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "MyURLConnection.h"

#define WIDTH           0.9*SCREEN_WIDTH
#define HEIGHT          0.04*SCREEN_HEIGHT

@interface QuestionViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, MyURLConnectionDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation QuestionViewController {
    UIView      *typeView;
    UITableView *questionTableView;
    UIView      *describeTFView;
    UITextField *describeTF;
    UIView      *positionTFView;
    UITextField *positionTF;
    UIImageView *pictureView;
    UIButton    *cameraButton;
    UILabel     *hintMes;
    
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    
    NSString    *imageView1Url;
    NSString    *imageView2Url;
    NSString    *imageView3Url;
    
    NSData      *imageView1Data;
    NSData      *imageView2Data;
    NSData      *imageView3Data;
    
    int         imageNumber;
    
    int         imageViewNumber;
    BOOL        firstDelete;
    BOOL        secondDelete;
    BOOL        thirdDelete;
    
    UILabel     *typeLabel;
    UILabel     *describeLabel;
    UILabel     *describeLabel1;
    UILabel     *positionLabel;
    
    UIButton    *commitButton;
    
    NSArray     *questionType;
    
    AppDelegate *myDelegate;
    
    CGFloat     keyboardHeight;
    
    BOOL        isBack;
    BOOL        isConnect;
    
    // 百度地图模块
    BMKLocationService  *_locSerview;
    BMKGeoCodeSearch    *_search;
    
    // 服务器通信模块
    NSString    *bikePosition;
    NSString    *imageUrl;
    
    //凭证图片
    NSUserDefaults *userDefaults;
    UIView      *cover;
    NSMutableArray *imageArray;
}


#pragma mark - UIInit
- (void)UIInit {
    typeView            = [[UIView alloc] init];
    questionTableView   = [[UITableView alloc] init];
    describeTFView      = [[UIView alloc] init];
    describeTF          = [[UITextField alloc] init];
    positionTFView      = [[UIView alloc] init];
    positionTF          = [[UITextField alloc] init];
    pictureView         = [[UIImageView alloc] init];
    cameraButton        = [[UIButton alloc] init];
    hintMes             = [[UILabel alloc] init];
    
    imageView1          = [[UIImageView alloc] init];
    imageView2          = [[UIImageView alloc] init];
    imageView3          = [[UIImageView alloc] init];
    firstDelete         = YES;
    secondDelete        = YES;
    thirdDelete         = YES;
    imageView1Data      = [NSData data];
    imageView2Data      = [NSData data];
    imageView3Data      = [NSData data];
    
    typeLabel           = [[UILabel alloc] init];
    describeLabel       = [[UILabel alloc] init];
    describeLabel1      = [[UILabel alloc] init];
    positionLabel       = [[UILabel alloc] init];
    
    commitButton        = [[UIButton alloc] init];
    
    imageNumber         = 0;
    
    questionType        = @[@"单车丢失", @"锁车后无法还车结账", @"车身损坏", @"车锁损坏", @"其他问题"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    isBack = true;
    isConnect = NO;
    
    [self NavigationInit];
    [self UILayout];
    
    // 百度地图模块
    _locSerview = [[BMKLocationService alloc] init];
    _locSerview.delegate = self;
    [_locSerview startUserLocationService];
    _search = [[BMKGeoCodeSearch alloc] init];
    _search.delegate = self;
    
    // 上传凭证模块
    imageArray = [[NSMutableArray alloc] init];
}

#pragma mark - NavigationInit
- (void)NavigationInit {
    self.navigationItem.title = @"遇到问题";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UILayout
- (void)UILayout {
    typeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT, WIDTH, HEIGHT);
    typeLabel.text = @"问题类型*";
    typeLabel.textAlignment = NSTextAlignmentLeft;
    
    typeView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*2, WIDTH, HEIGHT*5);
    typeView.layer.shadowColor = [UIColor blackColor].CGColor;
    typeView.layer.shadowOffset = CGSizeMake(3, 3);
    typeView.layer.shadowOpacity = 0.8;
    
    questionTableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT*5);
    questionTableView.delegate = self;
    questionTableView.dataSource = self;
    questionTableView.scrollEnabled = NO;
    
    describeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*8, WIDTH*0.21, HEIGHT);
    describeLabel.textAlignment = NSTextAlignmentLeft;
    describeLabel.text = @"问题描述";
    describeLabel.hidden = YES;
    
    describeLabel1.frame = CGRectMake(0.05*SCREEN_WIDTH+0.21*WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*8, WIDTH*0.59, HEIGHT);
    describeLabel1.textAlignment = NSTextAlignmentLeft;
    describeLabel1.font = [UIFont systemFontOfSize:10];
    describeLabel1.text = @"(可不填）";
    describeLabel1.hidden = YES;
    if (SCREEN_WIDTH == 320) {
        describeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*8, WIDTH*0.25, HEIGHT);
        describeLabel1.frame = CGRectMake(0.05*SCREEN_WIDTH+0.25*WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*8, WIDTH*0.59, HEIGHT);
    }
    
    describeTF.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    describeTF.placeholder = @"请输入问题描述";
    describeTF.borderStyle = UITextBorderStyleRoundedRect;
    describeTF.delegate = self;
    describeTF.tag = 1;

    describeTFView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*9, WIDTH, HEIGHT);
    describeTFView.layer.shadowColor = [UIColor blackColor].CGColor;
    describeTFView.layer.shadowOffset = CGSizeMake(3, 3);
    describeTFView.layer.shadowOpacity = 0.8;
    describeTFView.hidden = YES;
    
    positionLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*11, WIDTH, HEIGHT);
    positionLabel.textAlignment = NSTextAlignmentLeft;
    positionLabel.text = @"单车的位置*";
    positionLabel.hidden = YES;
    
    positionTF.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    positionTF.placeholder = @"请输入单车的位置";
    positionTF.borderStyle = UITextBorderStyleRoundedRect;
    positionTF.delegate = self;
    positionTF.enabled = false;
    positionTF.tag = 2;
    
    positionTFView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*12, WIDTH, HEIGHT);
    positionTFView.layer.shadowColor = [UIColor blackColor].CGColor;
    positionTFView.layer.shadowOffset = CGSizeMake(3, 3);
    positionTFView.layer.shadowOpacity = 0.8;
    positionTFView.hidden = YES;
    
    pictureView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*14, WIDTH, HEIGHT*1.3);
    [pictureView setImage:[UIImage imageNamed:@"上传照片边框"]];
    pictureView.contentMode = UIViewContentModeScaleAspectFill;
    pictureView.userInteractionEnabled = YES;
    pictureView.hidden = YES;
    
    cameraButton.frame = CGRectMake(0, 0, 0.15*WIDTH, HEIGHT);
    [cameraButton setImage:[UIImage imageNamed:@"照相机"] forState:UIControlStateNormal];
    cameraButton.contentMode = UIViewContentModeScaleAspectFit;
    [cameraButton addTarget:self action:@selector(selectPicture) forControlEvents:UIControlEventTouchUpInside];
    
    hintMes.frame = CGRectMake(0.5*WIDTH, 0, 0.45*WIDTH, HEIGHT);
    hintMes.text = @"上传凭证 最多3张";
    hintMes.textAlignment = NSTextAlignmentRight;
    hintMes.textColor = [UIColor grayColor];
    hintMes.hidden = NO;
    if (SCREEN_WIDTH == 320) {
        hintMes.font = [UIFont systemFontOfSize:12];
    }
    
    imageView1.hidden = YES;
    imageView2.hidden = YES;
    imageView3.hidden = YES;
    imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    imageView1.userInteractionEnabled = YES;
    imageView2.userInteractionEnabled = YES;
    imageView3.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delete)];
    [pictureView addGestureRecognizer:tap1];
    
    
    commitButton.frame = CGRectMake((SCREEN_WIDTH-COMMIT_WIDTH)/2, SCREEN_HEIGHT-2*HEIGHT-COMMIT_HEIGHT, COMMIT_WIDTH, COMMIT_HEIGHT);
    commitButton.backgroundColor = UICOLOR;
    [commitButton setTitle:@"提交" forState:UIControlStateNormal];
    commitButton.layer.cornerRadius = CORNERRADIUS;
    [commitButton addTarget:self action:@selector(commitQuestion) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:typeLabel];
    [self.view addSubview:typeView];
    [typeView addSubview:questionTableView];
    [self.view addSubview:describeLabel];
    [self.view addSubview:describeLabel1];
    [self.view addSubview:describeTFView];
    [describeTFView addSubview:describeTF];
    [self.view addSubview:positionLabel];
    [self.view addSubview:positionTFView];
    [positionTFView addSubview:positionTF];
    [pictureView addSubview:hintMes];
    [pictureView addSubview:cameraButton];
    [pictureView addSubview:imageView1];
    [pictureView addSubview:imageView2];
    [pictureView addSubview:imageView3];
    [self.view addSubview:pictureView];
    [self.view addSubview:commitButton];
}

#pragma mark - Button Event
- (void)commitQuestion {
    NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
    // Event
    switch (indexPath.row) {
        case 0:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"如果在使用期间丢失车辆，您需要赔偿200元，请再次确认单车已经丢失" delegate:self cancelButtonTitle:@"确认丢失" otherButtonTitles:@"我再找找", nil];
            alert.tag = 1;
            [alert show];
            describeLabel.hidden = NO;
            describeLabel1.hidden = NO;
            describeTFView.hidden = NO;
            pictureView.hidden = NO;
        }
            break;
        case 1:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"非常抱歉，大象单车没能带给你最完美的出行体验，大象单车将会立即进行维修，并在核实后给予您本次车费金额5倍的赔偿。在此期间，您的账户将会被临时冻结，请您谅解！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
            [self visible];
        }
            break;
        case 2:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"提交成功！大象单车将会立即前往维修车辆,您可以使用其他单车出行。" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
            alert.tag = 3;
            [self visible];
        }
            break;
        // 车锁损坏和其他问题不给予提示，所以不用跳出直接提交问题类型 然后回到计费页面
        default: {
            // 有图片才上传
            if (imageViewNumber > 0) {
                // 先上传图片 获取到url 再提交问题，然后回到计费页面
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/upload"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                // 设置字典信息
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:imageView1Data forKey:@"imageData"];
                [self setRequest:request andValue:param];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"imageView1"];
            }else {
                userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
                
                // 选中问题类型
                NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
                
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, /*访问凭证*/@"", accessToken];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
            }
        }
            break;
    }
}

#pragma mark - 上传图片部分
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


- (void)visible {
    describeLabel.hidden = NO;
    describeLabel1.hidden = NO;
    describeTFView.hidden = NO;
    pictureView.hidden = NO;
    positionLabel.hidden = NO;
    positionTFView.hidden = NO;
}

- (void)selectPicture {
    if (imageViewNumber == 3) {
        
    }else {
        UIActionSheet *sheet;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册中选择", nil];
        } else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", nil];
        }
        [sheet showInView:self.view];
    }
}

- (void)delete {
    if (imageViewNumber > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要删除吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 4;
        [alertView show];
    }
}

#pragma mark - actionSheetDelegate
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

}
// 选好照片后
#pragma mark - ImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
        [self setImageViewPosition];
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
            if (imageData.length/1024 < 300) {
                break;
            }
        }
        if (firstDelete) {
            [imageView1 setImage:savedImage];
            imageView1Data = imageData;
            imageViewNumber++;
            firstDelete = NO;
        }else if(secondDelete) {
            [imageView2 setImage:savedImage];
            imageView2Data = imageData;
            imageViewNumber++;
            secondDelete = NO;
        }else if (thirdDelete) {
            [imageView3 setImage:savedImage];
            imageView3Data = imageData;
            imageViewNumber++;
            thirdDelete = NO;
        }
    }
    [self setImageViewPosition];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setImageViewPosition {
    if (imageViewNumber == 0) {
        hintMes.hidden = NO;
    }else if (imageViewNumber == 1) {
        imageView1.frame = CGRectMake(0.95*WIDTH-HEIGHT, 0, HEIGHT, HEIGHT);
        imageView2.frame = CGRectMake(0, 0, 0, 0);
        imageView3.frame = CGRectMake(0, 0, 0, 0);
        imageView1.hidden = NO;
        imageView2.hidden = YES;
        imageView3.hidden = YES;
        hintMes.hidden = YES;
    }else if (imageViewNumber == 2) {
        // 设置view1和view2的位置
        imageView2.frame = CGRectMake(0.95*WIDTH-HEIGHT, 0, HEIGHT, HEIGHT);
        imageView1.frame = CGRectMake(0.9*WIDTH-2*HEIGHT, 0, HEIGHT, HEIGHT);
        imageView3.frame = CGRectMake(0,0,0,0);
        imageView1.hidden = NO;
        imageView2.hidden = NO;
        imageView3.hidden = YES;
        hintMes.hidden = YES;
    }else if (imageViewNumber ==3 ) {
        // 设置
        imageView3.frame = CGRectMake(0.95*WIDTH-HEIGHT, 0, HEIGHT, HEIGHT);
        imageView2.frame = CGRectMake(0.9*WIDTH-2*HEIGHT, 0, HEIGHT, HEIGHT);
        imageView1.frame = CGRectMake(0.85*WIDTH-3*HEIGHT, 0, HEIGHT, HEIGHT);
        imageView1.hidden = NO;
        imageView2.hidden = NO;
        imageView3.hidden = NO;
        hintMes.hidden = YES;
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [questionType objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
// 改变cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // UI
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *array = [tableView visibleCells];
    for (UITableViewCell *cell in array) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.textLabel.textColor=[UIColor grayColor];
    }
    cell.textLabel.textColor = [UIColor redColor];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    // Event
    switch (indexPath.row) {
        case 0:{
            pictureView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*11, WIDTH, HEIGHT);
            describeLabel.hidden = NO;
            describeLabel1.hidden = NO;
            describeTFView.hidden = NO;
            pictureView.hidden = NO;
            positionLabel.hidden = YES;
            positionTFView.hidden = YES;
        }
            break;
        default: {
            pictureView.frame = CGRectMake(0.05*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+HEIGHT*14, WIDTH, HEIGHT*1.3);
            [self visible];
        }
            break;
    }

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        // 单车丢失，点击确定丢失后，先提交问题类型，然后再获取数据
        // 单车丢失api 赔偿金额从服务器获取
        if (buttonIndex == 0) {
            isBack = NO;
            myDelegate.isMissing = YES;
            userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            
            // 选中问题类型
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, /*访问凭证*/@"", accessToken];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
        }
        //验证等待动画
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"请稍后...";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:cover];
        
        if (alertView.tag == 1) {
            bikePosition = @"";
        }

    }else if (alertView.tag == 2) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        myDelegate.isFreeze = true;
        // 获取缓存
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
        // 用户冻结向服务器提交冻结数据 然后再跳转支付页面
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/frozen"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@",phoneNumber, accessToken];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"frozen"];
        
        //验证等待动画
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"请稍后...";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:cover];
        
        if (alertView.tag == 1) {
            bikePosition = @"";
        }

    }else if (alertView.tag == 3) {
        isBack = YES;
        
        if (imageViewNumber > 0) {
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/upload"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            // 设置字典信息
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:imageView1Data forKey:@"imageData"];
            [self setRequest:request andValue:param];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"imageView1"];
        }else {
            userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            
            // 选中问题类型
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, /*访问凭证*/@"", accessToken];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
        }
        
        
        //验证等待动画
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"请稍后...";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:cover];
        
        if (alertView.tag == 1) {
            bikePosition = @"";
        }
    }else if (alertView.tag == 4) {
        if (buttonIndex == 0) {
            NSLog(@"确认删除");
            NSLog(@"%d", imageViewNumber);
            if (imageViewNumber == 1) {
                imageView1.hidden = YES;
                firstDelete = YES;
                hintMes.hidden = NO;
                imageViewNumber--;
            }else if (imageViewNumber == 2) {
                imageView2.hidden = YES;
                secondDelete = YES;
                imageViewNumber--;
            }else if (imageViewNumber == 3) {
                imageView3.hidden = YES;
                thirdDelete = YES;
                imageViewNumber--;
            }
            [self setImageViewPosition];
        }
    }
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data  {
    // 提交问题成功后执行
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"frozen"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            // 冻结成功 提交问题类型 然后获取数据
            isBack = NO;
            
            userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            
            // 选中问题类型
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, /*访问凭证*/@"", accessToken];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
            
            
        }
    }else if ([connection.name isEqualToString:@"getMoney"]) {
        // 解析数据
        // 需要根据time来判断是丢车还是无法还车
        NSString *status = receiveJson[@"status"];
        NSString *fee = receiveJson[@"fee"];
        NSString *time = receiveJson[@"time"];
        if (status) {
            isConnect = YES;
            [cover removeFromSuperview];
            PayViewController *payViewController = [[PayViewController alloc] init];
            self.delegate = payViewController;
            if ([time isEqualToString:@""]) {
                [self.delegate getMoney:fee/*服务器获取*/ andTime:time/*服务器获取*/ andIsLose:YES];
            }else {
                [self.delegate getMoney:fee/*服务器获取*/ andTime:time/*服务器获取*/ andIsLose:NO];
            }
            [self.navigationController pushViewController:payViewController animated:YES];
        }
    }else if ([connection.name isEqualToString:@"commitQuestion"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            if (isBack) {
                // 下面三个问题类型
                // 如果有照片，上传照片
                [cover removeFromSuperview];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                // 上面两个问题类型
                // 获取使用时长 金额
                // 请求服务器 异步post
                NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@", phoneNumber, bikeNo, accessToken];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMoney"];
            }
        }
    }else if ([connection.name isEqualToString:@"imageView1"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"第一张上传成功");
            imageView1Url = url;
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            NSString    *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString    *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString    *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:imageView1Url, @"imageurl", nil];
            [imageArray addObject:dictionary];
            NSData      *urlData = [NSJSONSerialization dataWithJSONObject:imageArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString    *urlsStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", urlsStr);
            if (imageViewNumber == 1) {
                // 提交问题
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, urlsStr, accessToken];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
            }else {
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/upload"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                // 设置字典信息
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:imageView2Data forKey:@"imageData"];
                [self setRequest:request andValue:param];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"imageView2"];
            }
        }else {
            // 图片上传失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"imageView2"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"第二张上传成功");
            imageView2Url = url;
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            NSString    *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString    *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString    *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:imageView2Url, @"imageurl", nil];
            [imageArray addObject:dictionary];
            NSData      *urlData = [NSJSONSerialization dataWithJSONObject:imageArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString    *urlsStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", urlsStr);
            if (imageViewNumber == 2) {
                // 提交问题
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, urlsStr, accessToken];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
            }else {
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/file/upload"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                // 设置字典信息
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:imageView3Data forKey:@"imageData"];
                [self setRequest:request andValue:param];
                MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"imageView3"];
            }
        }else {
            // 图片上传失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"imageView3"]) {
        NSString *status = receiveJson[@"status"];
        NSString *url = receiveJson[@"url"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"第三张上传成功");
            imageView3Url = url;
            NSIndexPath *indexPath = [questionTableView indexPathForSelectedRow];
            NSString    *bikeNo = [userDefaults objectForKey:@"bikeNo"];
            NSString    *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString    *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:imageView3Url, @"imageurl", nil];
            [imageArray addObject:dictionary];
            NSData      *urlData = [NSJSONSerialization dataWithJSONObject:imageArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString    *urlsStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", urlsStr);
            // 提交问题
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/question/ques"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&type=%@&description=%@&addr=%@&evidence=%@&access_token=%@", bikeNo, phoneNumber, [questionType objectAtIndex:indexPath.row], describeLabel.text, bikePosition, urlsStr, accessToken];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"commitQuestion"];
        }else {
            // 图片上传失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

#pragma mark - 服务器超时
- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error    {
    isConnect = YES;
    [cover removeFromSuperview];
    // 收到验证码  进行提示
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.6;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"无法连接网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:cover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

- (void)removeView {
    [cover removeFromSuperview];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect frame;
    if (textField.tag == 1) {
        frame = describeTFView.frame;
    }else {
        frame = positionTFView.frame;
    }
    int offset = frame.origin.y + HEIGHT - (self.view.frame.size.height-253);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.5f];
    
    if (offset > 0) {
        self.view.frame = CGRectMake(0, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"didend");
}

- (void)keyboardWillShow:(NSNotification *)aNotifacation {
    NSDictionary *userInfo = [aNotifacation userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    keyboardHeight = keyboardRect.size.height;
    NSLog(@"keyboardheight%f",keyboardHeight);
}

#pragma mark - TouchesBegin
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([describeTF isFirstResponder]) {
        [describeTF resignFirstResponder];
    }else if([positionTF isFirstResponder]) {
        [positionTF resignFirstResponder];
    }
}

#pragma mark - 百度地图模块代理方法
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CGFloat latitude = userLocation.location.coordinate.latitude;
    CGFloat longitude = userLocation.location.coordinate.longitude;
    // 反地理编码出地理位置
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0,0};
    pt = (CLLocationCoordinate2D){latitude, longitude};
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];//初始化反编码请求
    reverseGeocodeSearchOption.reverseGeoPoint = pt;//设置反编码的店为pt
    // 封装地理位置的两个数据
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f", userLocation.location.coordinate.longitude], @"lng", [NSString stringWithFormat:@"%f", userLocation.location.coordinate.latitude], @"lat", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    bikePosition = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    BOOL flag = [_search reverseGeoCode:reverseGeocodeSearchOption];//发送反编码请求.并返回是否成功
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
        [_locSerview stopUserLocationService];
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        NSString* showmeg;
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        NSLog(@"地址是：%@", showmeg);
        positionTF.text = showmeg;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self UIInit];
}

- (void)viewWillDisappear:(BOOL)animated {
    _search.delegate = nil;
    _locSerview.delegate = nil;
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
