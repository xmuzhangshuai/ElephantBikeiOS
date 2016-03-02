//
//  IdentificationViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "IdentificationViewController.h"
#import "UISize.h"

#define SELECTBUTTON1_WIDTH  0.8*SAME_WIDTH
#define SELECTBUTTON1_HEIGHT 0.15*IDENTIFICATION_HEIGHT
#define SELECTBUTTON2_WIDTH  SELECTBUTTON1_WIDTH
#define SELECTBUTTON2_HEIGHT SELECTBUTTON1_HEIGHT
#define RESULTLABEL_WIDTH    SAME_WIDTH
#define RESULTLABEL_HEIGHT   COMMIT_HEIGHT

@interface IdentificationViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation IdentificationViewController {
    UIImageView *identificationFront;
    UIImageView *identificationBack;
    UIButton    *selectButton1;
    UIButton    *selectButton2;
    UIButton    *commitButton;
    UILabel     *resultLabel;
    
    BOOL        isButton1;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIInit];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Private Method
- (void)UIInit {
    identificationFront = [[UIImageView alloc]init];
    identificationBack  = [[UIImageView alloc]init];
    selectButton1       = [[UIButton alloc] init];
    selectButton2       = [[UIButton alloc] init];
    commitButton        = [[UIButton alloc]init];
    resultLabel         = [[UILabel alloc] init];
    
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
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] init];
    [tap1 addTarget:self action:@selector(chooseImage1)];
    [identificationFront addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
    [tap2 addTarget:self action:@selector(chooseImage2)];
    [identificationBack addGestureRecognizer:tap2];
    
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
    [self.navigationController popViewControllerAnimated:YES];
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
    // 少一个 菊花图
    resultLabel.text = @"信息审核中，结果将在2个工作日内通知您";
    resultLabel.font = [UIFont systemFontOfSize:14];
    [commitButton removeFromSuperview];
    [self.view addSubview:resultLabel];
    if (SCREEN_WIDTH == 320) {
        resultLabel.font = [UIFont systemFontOfSize:12];
    }
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
}

#pragma mark - ImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *savedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    [self saveImage:image withName:@"currentImage.png"];
//    
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
//    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    if (isButton1) {
        [identificationFront setImage:savedImage];
        [selectButton1 removeFromSuperview];
    }else {
        [identificationBack setImage:savedImage];
        [selectButton2 removeFromSuperview];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
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
