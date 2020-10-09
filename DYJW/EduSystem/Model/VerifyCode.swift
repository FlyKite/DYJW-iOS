//
//  VerifyCode.swift
//  DYJW
//
//  Created by 风筝 on 2017/12/6.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit
import Alamofire

class VerifyCode: NSObject {
    
    static func loadVerifycodeImage(_ completion: @escaping (VerifyCode?) -> Void) {
        let url = "http://jwgl.nepu.edu.cn/verifycode.servlet"
        let request = AF.request(url)
        request.responseData { (response) in
            switch response.result {
            case let .success(data):
                let image = UIImage(data: data)
                let model = VerifyCode()
                model.verifycodeImage = image
                completion(model)
            case let .failure(error):
                print(error)
                completion(nil)
            }
        }
    }
    
    private(set) var recognizedCode: String?
    private(set) var verifycodeImage: UIImage? {
        didSet {
            guard let image = self.verifycodeImage else {
                self.recognizedCode = nil
                return
            }
            self.recognizedCode = self.recognizeVerifycode(image)
        }
    }
    
    private func recognizeVerifycode(_ image: UIImage) -> String? {
        let letters = ["b", "c", "m", "n", "v", "x", "z", "1", "2", "3"]
        // 该二维数组中的每一个一维数组是letters数组中相应字母的点阵表示按照二进制转换为十进制的数值
        // 如b的第一列是01111111即十进制的4095
        let nums = [
            [4095, 4095, 1584, 3096, 3096, 3640, 2032, 992],
            [992, 2032, 3640, 3096, 3096, 3640, 560],
            [4088, 4088, 48, 24, 24, 4088, 4080, 48, 24, 24, 4088, 4080],
            [4088, 4088, 48, 24, 24, 24, 4088, 4080],
            [56, 504, 4032, 3584, 4032, 504, 56],
            [3096, 3640, 2032, 448, 2032, 3640, 3096],
            [3096, 3864, 3992, 3544, 3320, 3192, 3096],
            [24, 12, 6, 4095, 4095],
            [3084, 3598, 3847, 3459, 3523, 3299, 3198, 3100],
            [772, 1798, 3587, 3123, 3123, 3699, 2047, 974]
        ]
        
        let imageWidth = 45
        let imageHeight = 12
        
        guard let cgImage = image.cgImage?.cropping(to: CGRect(x: 3, y: 4, width: 45, height: 12)) else {
            return nil
        }
        
        // 遍历像素
        guard let pixelData = cgImage.dataProvider?.data else {
            return nil
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var colors: [[Bool]] = []
        var colorLine: [Bool] = []
        let pixelCount = imageWidth * imageHeight
        for index in 0 ..< pixelCount {
            let r = Int32(data[index * 4])
            let g = Int32(data[index * 4 + 1])
            let b = Int32(data[index * 4 + 2])
            // 套用公式转灰度
            let gray = (r * 299 + g * 587 + b * 114 + 500) / 1000
            colorLine.append(gray < 0x99)
            if index % 45 == 44 {
                colors.append(colorLine)
                colorLine = []
            }
        }
        
        var verifycode = ""
        for lineIndex in 0 ..< 45 {
            // 从每一列开始往后比较
            for letterIndex in 0 ..< 10 {
                // 与已知各个字符进行比较
                if self.compare(colors: colors, position: lineIndex, dest: nums[letterIndex]) {
                    verifycode.append(letters[letterIndex])
                    break
                }
            }
        }
        return verifycode
    }
    
    // 对每一列进行与运算以消除图片中干扰线的影响
    private func compare(colors: [[Bool]], position: Int, dest: [Int]) -> Bool {
        for x in position ..< position + dest.count - 1 {
            guard x < 45 else {
                break
            }
            // 计算图片当前列的像素点的比特值
            var lineValue = 0
            var binBit = 1
            for y in 0 ..< 12 {
                lineValue += colors[y][x] ? binBit : 0
                binBit *= 2
            }
            if lineValue & dest[x - position] != dest[x - position] {
                return false
            }
        }
        return true
    }
    
}
