//
//  OpenCVUtil.h
//  navicon-swift
//
//  Created by Yuria Hiraga on 1/23/18.
//  Copyright © 2018 Yuria Hiraga. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVUtil : NSObject


// UIImageインスタンスをOpenCV画像データに変換
+ (IplImage *)IplImageFromUIImage:(UIImage *)image;


// OpenCV画像データをUIImageインスタンスに変換
+ (UIImage *)UIImageFromIplImage:(IplImage *)image;

@end

