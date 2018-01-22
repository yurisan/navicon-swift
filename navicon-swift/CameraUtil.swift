//
//  CameraUtil.swift
//  navicon-swift
//
//  Created by Yuria Hiraga on 1/23/18.
//  Copyright © 2018 Yuria Hiraga. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraUtil{
    // sampleBufferからUIImageへ変換
    class func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // ベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像データの情報を取得
        let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        
        let bytesPerRow: UInt = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width: UInt = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height: UInt = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // RGB色空間を作成
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Bitmap graphic contextを作成
        let bitsPerCompornent: UInt = 8
        var bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            .union(.byteOrder32Little)
        let newContext: CGContext = CGContext(data: baseAddress, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue) as! CGContext
        
        // Quartz imageを作成
        let imageRef: CGImage = newContext.makeImage()!
        
        // UIImageを作成
        let resultImage: UIImage = UIImage(cgImage: imageRef)
        
        return resultImage
    }
    
}
