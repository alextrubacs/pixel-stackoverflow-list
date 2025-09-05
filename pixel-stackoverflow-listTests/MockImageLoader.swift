//
//  MockImageLoader.swift
//  pixel-stackoverflow-listTests
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation
import UIKit
@testable import pixel_stackoverflow_list

/// Mock implementation of ImageLoader for testing
final class MockImageLoader: ImageLoader {
    var mockImageData: Data?
    var mockError: Error?
    var downloadImageDataCalled = false
    var lastDownloadedURL: URL?

    convenience init() {
        self.init(mockImageData: nil, mockError: nil)
    }

    init(mockImageData: Data? = nil, mockError: Error? = nil) {
        self.mockImageData = mockImageData
        self.mockError = mockError
    }

    func downloadImageData(from url: URL) async throws -> Data {
        downloadImageDataCalled = true
        lastDownloadedURL = url

        if let error = mockError {
            throw error
        }

        return mockImageData ?? Data()
    }
}
