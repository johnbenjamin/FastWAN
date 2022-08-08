//
//  QNImageUper.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/1.
//

import Foundation
import UIKit
import QiniuSDK

struct QNImageUper {
    fileprivate init() { }

    static func imageUpload(image: UIImage, token: String, complete:(@escaping(Bool, String?) -> ())) {
        let data = image.pngData()
        let uploadManager: QNUploadManager = QNUploadManager()
        uploadManager.put(data, key: "", token: token, complete: { info, key, resp in
            if info?.isOK ?? false {
                complete(true, resp?["hash"] as? String ?? "")
            }
            complete(false, nil)
        }, option: QNUploadOption.defaultOptions())
    }
}
