# ping
Proof of concept for doing RESTful requests in the background of an iOS device, initialized by a server using the Apple Push Notification service. 
## Get started
* run these commands in the root directory:
  * `cd ping-server`
  * `npm install`
  * `npm start`
* go to https://documenter.getpostman.com/view/3932141/collection/RW89LpLo and open the requests in Postman
* run this command using a new terminal in the root directory: 
    * `open ping-ios/ping.xcodeproj/`
* open `RestController.swift` and update `let ip = "http://123.456.7.89:3000"` with your server ip address
> Note: You can get your IP in the MacOS menu: Wi-Fi -> 'Open Network Preferences' -> 'Advanced' -> 'TCP/IP' -> 'IPv4 Address'
* in Xcode, run the iOS app on a physical device (cmd + R)
* copy the apn device token in the Xcode console and paste it in the `token` header in the Postman `push` request

You should now be running the iOS app and the server and you should be able to run requests on the server using Postman. When you run the `push` request the server will use APNs to send a notification to the iOS app. The app will then call `pushRegistry(_:didReceiveIncomingPushWith:for:completion:)` that in turn should send a `ping` request to the server. The server should respond and the request will return data that can be parsed to an `OkResponse` (see `OkResponse.swift` in the iOS project files). The `RestController` should then call `onPing()` on its singleton and the `AppDelegate` should write `AppDelegate pushRegistry(_:didReceiveIncomingPushWith:for:completion:) onPing` to the console in its `onPing` handler. 