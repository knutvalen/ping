# ping

## Get started
* run these commands in your terminal:
  * `cd ping-server`
  * `npm install`
  * `npm start`
* go to https://documenter.getpostman.com/view/3932141/collection/RW89LpLo and open the requests in Postman
* run this command in a new terminal `open ping-ios/ping.xcodeproj/`
* open `RestController.swift` and update `let ip = "http://123.456.7.89:3000"` with your server ip address
* in Xcode, run the iOS app (cmd + R)
* copy the apn device token in the Xcode console and paste it in the `token` header in the Postman `push` request

You should now be running the iOS app and the server and you should be able to run requests on the server using Postman. When you run the `push` request the server will use APNs to send a notification to the iOS app. The app will then call `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` that in turn should send a `ping` request to the server. The server should respond and the request should return data. The data should then be parsed to an `OkResponse` (see `OkResponse.swift` in the iOS project files). The `RestController` should then call `onPing()` on its singleton and the `AppDelegate` should write `AppDelegate onPing` to the console in its `onPing` handler. 