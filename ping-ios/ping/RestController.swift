//
//  RestController.swift
//  ping
//
//  Created by Knut Valen on 23/05/2018.
//  Copyright © 2018 Knut Valen. All rights reserved.
//
import Foundation
import os.log

class RestController: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    // MARK: - Properties
    
    static let shared = RestController()
    let identifier = "no.qassql.ping.background"
    let ip = "http://123.456.7.89:3000"
    var backgroundUrlSession: URLSession?
    var backgroundSessionCompletionHandler: (() -> Void)?
    var onPing: (() -> ())?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true
        backgroundUrlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Delegate functions
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let completionHandler = self.backgroundSessionCompletionHandler {
                self.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            os_log("RestController urlSession(_:task:didCompleteWithError:) error: %@", error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let respopnse = downloadTask.response
            let error = downloadTask.error
            
            self.completionHandler(data: data, response: respopnse, error: error)
        } catch {
            os_log("RestController urlSession(_:downloadTask:didFinishDownloadingTo:) error: %@", error.localizedDescription)
        }
    }
    
    // MARK: - Private functions
    
    private func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard let data = data else { return }
        
        if let okResponse = OkResponse.deSerialize(data: data) {
            if okResponse.message == ("ping_" + Login.shared.username) {
                RestController.shared.onPing?()
            }
        }
    }
    
    // MARK: - Public functions
    
    func pingBackground(login: Login) {
        guard let url = URL(string: ip + "/ping") else { return }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = login.serialize()
        
        if let backgroundUrlSession = backgroundUrlSession {
            backgroundUrlSession.downloadTask(with: request).resume()
        }
    }
    
    func pingForeground(login: Login) {
        guard let url = URL(string: ip + "/ping") else { return }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = login.serialize()
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            return self.completionHandler(data: data, response: response, error: error)
        }.resume()
    }
}
