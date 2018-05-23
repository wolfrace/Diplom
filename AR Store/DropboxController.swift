//
//  DropboxController.swift
//  AR Store
//
//  Created by Admin on 23.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import SwiftyDropbox

class DropboxController {
  private var client = DropboxClient(accessToken: "b2ons7g1loIAAAAAAAAAvRJhr1JUj37VsGRiwx_qC_a3zRpaTZ-FYVxAqaqQQ77E")
  private var currentUploadRequest: UploadRequest<Files.FileMetadataSerializer, Files.UploadErrorSerializer>?
  
  func uploadData(data: Data, completion: (() -> Void)? = nil) {
    let request = client.files.upload(path: "/attributes.bin", input: data)
      .response { response, error in
        self.currentUploadRequest = nil
        if let response = response {
          print(response)
        } else if let error = error {
          print(error)
        }
        completion?()
      }
      .progress { progressData in
        print(progressData)
    }
    currentUploadRequest = request
  }
  
  func downloadData(completion: @escaping ((_ data: Data?) -> Void)) {
    client.files.download(path: "/attributes.bin")
      .response { response, error in
        if let response = response {
          let responseMetadata = response.0
          print(responseMetadata)
          let fileContents = response.1
          print(fileContents)
          completion(fileContents)
        } else if let error = error {
          print(error)
          completion(nil)
        }
      }
      .progress { progressData in
        print(progressData)
    }
  }
  
  func deleteData(completion: (() -> Void)? = nil) {
    client.files.deleteV2(path: "/attributes.bin").response { response, error in
      if let response = response {
        print(response)
      } else if let error = error {
        print(error.description)
      }
      completion?()
    }
  }
  
  func cancelUpload() {
    if currentUploadRequest != nil {
      currentUploadRequest?.cancel()
    }
  }
}
