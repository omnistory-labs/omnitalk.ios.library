<p align="center">
  <img src="https://github.com/Luna-omni/readmdtest/assets/125844802/a910cb80-de3b-44d8-9f37-0ccd08b9dd19" width="500" height="100">
</p><br/>

# Omnitalk iOS WebRTC SDK 

옴니톡은 WebRTC 기반의 CPaaS 플랫폼 서비스입니다. 옴니톡 SDK를 통해 Web/App에서 간단하게 실시간 통신을 구현할 수 있습니다.


## Feature Overview

| feature |  implemented |
|---|:---:|
|  Audio/Video |  ✔️ |
|  Device Setting |  ✔️ |
|  Audio & Video Mute |  ✔️ |
|  Audio & Video Unmute |  ✔️ |
|  Chatting |  ✔️ |
|  SIP call |  ✔️ |

## Pre-Requisite

- 옴니톡 서비스키 & 서비스 아이디
  - [옴니톡 홈페이지](https://omnitalk.io) 를 방문하여 서비스 키와 아이디를 발급 받아주세요.
  - 혹은 [이곳](https://omnitalk.io/demo/audio) 에서 1시간 동안 무료로 사용할 수 있는 키를 받아주세요.

## Getting Started

Omnitalk iOS SDK는 SPM(Swift Package Manager) 방식만 지원합니다.
다음 방법을 통해 SDK Package 설치를 진행 합니다.

```
1. File - Add Packages... - "https://github.com/omnistory-labs/omnitalk.ios.sdk" search - Add Package
2. Add Package를 선택하면 Xcode에서 패키지 다운로드를 시작합니다.
```

Omnitalk SDK를 사용하기 위해서는 카메라와 마이크 권한이 필요합니다. 앱 info에 아래 두 권한이 필요합니다.
```
Privacy - Camera Usage Description
Privacy - Microphone Usage Description
```

## Documentation

쉽고 자세한 [문서](https://docs.omnitalk.io/ios)를 제공하고 있습니다. 


## Issue 

옴니톡을 사용하면서 발생하는 이슈나 궁금점은  [issue](https://github.com/omnistory-labs/omnitalk.ios.sdk/issues) 페이지를 확인해 주세요.

## Example Projects

옴니톡 SDK로 구현된 간단한 데모를 확인해 보세요.
- [ios 데모](https://github.com/omnistory-labs/omnitalk.ios.sdk/tree/demo) 
