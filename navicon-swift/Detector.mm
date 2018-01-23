//
//  Detector.m
//  navicon-swift
//
//  Created by Yuria Hiraga on 1/23/18.
//  Copyright © 2018 Yuria Hiraga. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "navicon-swift-Bridging-Header.h"
#include "OpenCVUtil.h"

@interface Detector()
{
    cv::CascadeClassifier cascade;
}
@end

@implementation Detector: NSObject

- (id)init {
    self = [super init];
    
    // 分類器の読み込み
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    std::string cascadeName = (char *)[path UTF8String];
    
    if(!cascade.load(cascadeName)) {
        return nil;
    }
    
    return self;
}

int hit = 0;
- (int)hit{
    return hit;
}

//- (UIImage *)recognizeFace:(UIImage *)image{
- (UIImage *)recognizeFace:(UIImage *)image{
    // UIImage -> cv::Mat変換
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat mat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(mat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    mat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    // // 顔検出
    // std::vector<cv::Rect> faces;
    // cascade.detectMultiScale(mat, faces,
    //                          1.1, 2,
    //                          CV_HAAR_SCALE_IMAGE,
    //                          cv::Size(30, 30));
    // 
    // // 顔の位置に丸を描く
    // std::vector<cv::Rect>::const_iterator r = faces.begin();
    // for(; r != faces.end(); ++r) {
    //     cv::Point center;
    //     int radius;
    //     center.x = cv::saturate_cast<int>((r->x + r->width*0.5));
    //     center.y = cv::saturate_cast<int>((r->y + r->height*0.5));
    //     radius = cv::saturate_cast<int>((r->width + r->height));
    //     cv::circle(mat, center, radius, cv::Scalar(80,80,255), 3, 8, 0 );
    // }

    IplImage *srcImage, *dstImage;
    
    srcImage       = [OpenCVUtil IplImageFromUIImage:image];
    dstImage       = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 1);
    
    cvCvtColor(srcImage, dstImage, CV_BGR2GRAY);
    
    
    //
    // 閾値で検出
    //
    int threshold = 200;
    for (int y=0 ; y<dstImage->height; y++) {
        for (int x=0 ; x<dstImage->width; x++) {
            if ((uchar)(dstImage->imageData[y*dstImage->width + x]) < threshold ) {
                dstImage->imageData[y*dstImage->width + x] = (uchar)0;
            }
            else {
                dstImage->imageData[y*dstImage->width + x] = (uchar)255;
            }
        }
    }
    
    // 検出点の中心を計算
    int numCount = 0;
    double averageX = 0.0f;
    double averageY = 0.0f;
    
    for (int y=0 ; y<dstImage->height; y++) {
        for (int x=0 ; x<dstImage->width; x++) {
            if ((uchar)dstImage->imageData[y*dstImage->width + x] == (uchar)255) {
                numCount++;
                averageX += x;
                averageY += y;
            }
            else {
                
            }
        }
    }
    
    averageX /= numCount * 1.0f;
    averageY /= numCount * 1.0f;
    
    // 当たり判定を表示
    int fireSize = 10;
    cv::circle(mat, cvPoint(averageX, averageY), fireSize, cv::Scalar(80,80,255), 3, 8, 0 );
    
    if(averageY < 500 && averageX < 500){
        hit = dstImage->height;
    }else{
        hit = 0;
    }
    
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(mat);
    
    return resultImage;
}

@end
