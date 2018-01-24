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

int hit;
- (void)hitInit{
    hit = 0;
}

- (int)hit{
    return hit;
}

int threshold = 150;

// ユークリッド距離
double calcEuclidDistance(CvPoint pt1, CvPoint pt2)
{
    return sqrt(pow((pt1.x-pt2.x), 2) + pow((pt1.y-pt2.y) ,2));
}

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

    IplImage *srcImage, *dstImage;
    
    srcImage       = [OpenCVUtil IplImageFromUIImage:image];
    dstImage       = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 1);
    
    cvCvtColor(srcImage, dstImage, CV_BGR2GRAY);
    
    
    //
    // 閾値で検出
    //
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
    cv::circle(mat, cvPoint(averageX, averageY), fireSize, cv::Scalar(255,0,0,255), -1);
    
    // ゴール
    CvPoint goalPoint;
    goalPoint = cvPoint(40, 450);
    
    // 当たり判定の円リスト
    std::list<CvPoint> collisionList;
    std::list<CvPoint>::iterator it;
    int collesionSize = 20;
    
    collisionList.clear();
    // sasa1
    collisionList.push_back(cvPoint(124, 50));
    collisionList.push_back(cvPoint(164, 50));
    collisionList.push_back(cvPoint(224, 50));
    collisionList.push_back(cvPoint(284, 50));
    collisionList.push_back(cvPoint(344, 50));
    
    // sasa2
    collisionList.push_back(cvPoint(30, 194));
    collisionList.push_back(cvPoint(70, 194));
    collisionList.push_back(cvPoint(110, 194));
    collisionList.push_back(cvPoint(150, 194));
    collisionList.push_back(cvPoint(190, 194));
    collisionList.push_back(cvPoint(230, 194));
    collisionList.push_back(cvPoint(270, 194));
    collisionList.push_back(cvPoint(290, 194));
    
    // cat1
    collisionList.push_back(cvPoint(217, 154));
    collisionList.push_back(cvPoint(217, 134));
    collisionList.push_back(cvPoint(190, 154));
    collisionList.push_back(cvPoint(190, 134));
    
    // sasa3
    collisionList.push_back(cvPoint(174, 270));
    collisionList.push_back(cvPoint(224, 270));
    collisionList.push_back(cvPoint(284, 270));
    collisionList.push_back(cvPoint(344, 270));
    
    // sasa4
    collisionList.push_back(cvPoint(340, 310));
    collisionList.push_back(cvPoint(340, 340));
    
    // sasa5
    collisionList.push_back(cvPoint(30, 360));
    collisionList.push_back(cvPoint(70, 360));
    collisionList.push_back(cvPoint(110, 360));
    collisionList.push_back(cvPoint(150, 360));
    collisionList.push_back(cvPoint(190, 360));
    collisionList.push_back(cvPoint(230, 360));
    collisionList.push_back(cvPoint(250, 360));
    
    // cat2
    collisionList.push_back(cvPoint(120, 440));
    collisionList.push_back(cvPoint(140, 440));
    collisionList.push_back(cvPoint(120, 460));
    collisionList.push_back(cvPoint(140, 460));
    
    
    // 当たり判定
    it = collisionList.begin();
    double distance = 0.0f;
    while (it != collisionList.end()) {
        distance = calcEuclidDistance(cvPoint(it->x, it->y), cvPoint(averageX, averageY));
        if (distance <= (fireSize + collesionSize)) {
            hit = 1;
            break;
        }
        it++;
    }
    distance = calcEuclidDistance(goalPoint, cvPoint(averageX, averageY));
    if (distance <= (fireSize + collesionSize)) {
        hit = 2;
    }

    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(mat);
    
    return resultImage;
}

- (UIImage *)setStartPosition:(UIImage *)image{
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
    
    IplImage *srcImage, *dstImage;
    
    srcImage       = [OpenCVUtil IplImageFromUIImage:image];
    dstImage       = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 1);
    
    cvCvtColor(srcImage, dstImage, CV_BGR2GRAY);
    
    
    //
    // 閾値で検出
    //
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
    cv::circle(mat, cvPoint(averageX, averageY), fireSize, cv::Scalar(0,0,255,255), -1);
    
    // スタート判定
    CvPoint startPoint;
    startPoint = cvPoint(23, 23);
    int collesionSize = 20;
    double distance = 0.0f;
    distance = calcEuclidDistance(startPoint, cvPoint(averageX, averageY));
    if (distance <= (fireSize + collesionSize)) {
        hit = 3;
    }
    
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(mat);
    
    return resultImage;
}

@end
