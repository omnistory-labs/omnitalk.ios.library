//
//  VideoConferenceController.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import OmnitalkSdk
import WebRTC

class VideoConferenceController: ObservableObject, OmniEventDelegate {
    let sdk: OmniTalk?
    var mySession: String?

    var publisherView = RTCMTLVideoView() // 자신의 영상 RTCMTLVideoView 객체
    @Published var subscriberViews: [SubscriberData] = [] // // 다른 참가자의 영상 RTCMTLVideoView 객체 배열

    init() {
        self.sdk = OmniTalk.getInstance()
        self.sdk?.delegate = self
    }
    
    func onEvent(eventName: OmnitalkSdk.OmniEvent, message: Any) {
        print("onEvent - \(eventName), \(message)")
        switch eventName {
            case .LEAVE: // 다른 참가자 퇴장시 발생하는 이벤트
                let leaveEventMsg = message as! EventLeave
                for (index, subscriberInfo) in self.subscriberViews.enumerated() {
                    if subscriberInfo.session == leaveEventMsg.session {
                        DispatchQueue.main.async {
                            self.subscriberViews.remove(at: index)
                        }
                    }
                }
            case .BROADCASTING_EVENT: // 다른 참가자 영상 송출시 발생하는 이벤트
                Task {
                    do {
                        // 이벤트 메세지 발생시 해당 참가자의 영상을 구독하는 예시
                        let broadcastEventMsg = message as! EventBroadcast
                        let view = await RTCMTLVideoView()
                        _  = try await sdk?.subscribe(publisherSession: broadcastEventMsg.session, view: view)
                        let subscriberInfo: SubscriberData = .init(session: broadcastEventMsg.session , view: view)
                        DispatchQueue.main.async {
                            self.subscriberViews.append(subscriberInfo)
                        }
                    } catch {
                        print("error on BROADCASTING_EVENT, \(error)")
                    }
                }
            case .CONNECTED_EVENT: // 다른 참가자 참여시 발생하는 이벤트
                return
            default:
                print("Unimplemented events")
        }
    }
    
    func onClose() {
        print("onClose Event!!!")
    }
    
    func connect(userId: String?) async throws {
        do {
            let createSessionResult = try await sdk?.createSession(userId: userId)
            self.mySession = createSessionResult?.session
        } catch {
            print("error on connect, \(error)")
            throw error
        }
    }

    // 해당 Demo에서는 room을 생성하고 있지 않습니다.
    func createRoom(subject: String, secret: String) async throws {
        do {
            _ = try await sdk?.createRoom(roomType: .VIDEO_ROOM, subject: subject, secret: secret, startDate: nil, endDate: nil)
        } catch {
            print("error on createRoom, \(error)")
            throw error
        }
    }

    func getRoomList() async throws -> Array<Room> {
        do {
            let roomListResult = try await sdk?.roomList(roomType: .VIDEO_ROOM, page: nil)
            if roomListResult == nil {
                return []
            }
            return roomListResult!.list
        } catch {
            print("error on getRoomList, \(error)")
            throw error
        }
    }

    func joinRoom(roomId: String, secret: String?, userName: String?) async throws {
        do {
            _ = try await sdk?.joinRoom(roomId: roomId, secret: secret, userName: userName)
        } catch {
            print("error on joinRoom, \(error)")
            throw error
        }
    }

    func leave() async {
        do {
            try await sdk?.leave(session: self.mySession!)
        } catch {
            print("error on leave, \(error)")
        }
    }

    func publish() async throws {
        do {
            _ = try await self.sdk?.publish(view: publisherView)
        } catch {
            print("error on publish \(error)")
            throw error
        }
    }

    func subscribeAll() async throws {
        do {
            // 송출중인 영상 목록 리스트를 조회하여 구독 하는 예시
            let publishListResult = try await sdk?.publishList(roomId: nil, page: nil)
            for publisher in publishListResult!.list {
                let subscribeView = await RTCMTLVideoView()
                _ = try await sdk?.subscribe(publisherSession: publisher.session, view: subscribeView)
                let subscriberInfo: SubscriberData = .init(session: publisher.session , view: subscribeView)
                DispatchQueue.main.async {
                    self.subscriberViews.append(subscriberInfo)
                }
            }
        } catch {
            print("error on subscribe \(error)")
            throw error
        }
    }

    func setDefaultAudio() async throws {
        do {
            try await sdk?.setAudioDevice(type: .defaultInEar)
        } catch {
            print("error on setAudioDevice \(error)")
        }
    }

    func setSpeakerAudio() async throws {
        do {
            try await sdk?.setAudioDevice(type: .speaker)
        } catch {
            print("error on setAudioDevice \(error)")
        }
    }

    func setBackCamera() async throws {
        do {
            try await sdk?.setVideoDevice(type: .back)
        } catch {
            print("error on setVideoDevice \(error)")
        }
    }

    func setFrontCamera() async throws {
        do {
            try await sdk?.setVideoDevice(type: .front)
        } catch {
            print("error on setVideoDevice \(error)")
        }
    }
}

struct SubscriberData: Hashable {
    var session: String
    var view: RTCMTLVideoView
}
