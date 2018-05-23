//
//  RestController.swift
//  ping
//
//  Created by Knut Valen on 23/05/2018.
//  Copyright © 2018 Knut Valen. All rights reserved.
//
import Foundation

class RestController {
    
    // MARK: - Properties
    
    static let shared = RestController()
    let ip = "http://123.456.7.89:3000"
    var backgroundUrlSession: URLSession?
    var pingConfiguration: URLSessionConfiguration?
    var onPing: (() -> ())?
    
    // MARK: - Initialization
    
    init() {
        pingConfiguration = URLSessionConfiguration.background(withIdentifier: "ping")
        pingConfiguration!.isDiscretionary = false
        pingConfiguration!.sessionSendsLaunchEvents = true
    }
    
    deinit {
        self.backgroundUrlSession?.finishTasksAndInvalidate()
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
    
    func pingBackground(login: Login, urlSessionDelegate: URLSessionDelegate) {
        guard let url = URL(string: ip + "/ping") else { return }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = login.serialize()
        
        if let backgroundUrlSession = backgroundUrlSession {
            backgroundUrlSession.invalidateAndCancel()
        }
        
        backgroundUrlSession = URLSession(configuration: RestController.shared.pingConfiguration!, delegate: urlSessionDelegate, delegateQueue: nil)
        
        if let backgroundUrlSession = backgroundUrlSession {
            backgroundUrlSession.dataTask(with: request).resume()
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
