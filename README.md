
# SocialLite

A simple social media app build with SwiftUI + Firebase service.


## Getting Started


### Prerequisites

1. XCode (This project created with SwiftUI 2 + XCode 12.4)
2. CocoaPods 

### Installing

1. Clone this project 

```
git clone https://github.com/piyatat/sociallite
```

2. There are 2 targets: 1 for dev, and another for production. Change BundleID of both target

3. Setup Firebase Project (Ideally 2 projects: 1 for dev target, 1 for production target)
- Enable Authentication with Email & Password
- Enable Realtime Database
- Edit Realtime Database rules with

```
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
      "Posts": {
        ".indexOn": "time"
      }
  }
}
```

4. In Firebase project setting, add iOS with the BundleID from (2)
5. Download / Replace "GoogleService-Info.plist" in the project folder

```
<PROJECT_DIR>/SocialList/config_dev
<PROJECT_DIR>/SocialList/config_production
```

6. Run pod install from project directory
```
pod install
```



## Running the tests

Before running test in XCode, you need to change some test parameters in
```
SocialLiteTests/FirebaseAuthTests.swift
SocialLiteTests/FirebaseDBTests.swift
```

UITest will be run on dummy object/environment, so you don't need to change anything.
But you have to disable "Connect Hardware Keyboard" in simulator, else it'll cause some issue when simulating typing text into TextField



## Author

* **Piyatat Chatvorawit** - [Github](https://github.com/piyatat)
