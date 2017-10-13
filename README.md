# WorldTweets

This project is written in Swift4 and Xcode9, but depends on iOS10 versions of the Social and Accounts frameworks.
In order to build and run the project you therefore need to: 
1. Go to the project navigator and select your project
2. Select your app target
3. Select Build Phases tab
4. Expand 'Link Binary With Libraries'
5. Add the two frameworks included in this repo in the "iOS10.3.1 frameworks" folder

Every once in a while Xcode9 will mess something up so you will have to remove the frameworks and re-add them. 
This always happens if you have accidentally asked Xcode to run the app on an iOS11 simulator or device.