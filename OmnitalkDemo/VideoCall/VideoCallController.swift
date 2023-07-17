//
//  VideoCallController.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import OmnitalkSdk
import WebRTC

class VideoCallController: ObservableObject, OmniEventDelegate {
    var sdk: OmniTalk?
    var mySession: String?
    
    var localView = RTCMTLVideoView() // 자신의 영상 RTCMTLVideoView 객체
    var remoteView = RTCMTLVideoView() // 상대방의 영상 RTCMTLVideoView 객체
    
    @Published var ringingFlag = false // 전화 수신중인지 여부 (뷰 업데이트를 위함)
    @Published var connected: Bool = false // 연결 되었는지 여부 (뷰 업데이트를 위함)
    
    init() {
        self.sdk = OmniTalk.getInstance()
        self.sdk?.delegate = self
    }
    
    func onEvent(eventName: OmniEvent, message: Any) {
        print("onEvent - \(eventName), \(message)")
        switch eventName {
            case .LEAVE: // 다른 참가자가 퇴장했을때 발생하는 이벤트
                DispatchQueue.main.async {
                    self.ringingFlag = false
                    self.connected = false
                }
            case .CONNECTED_EVENT: // 상대방과 연결 되었을 때 발생하는 이벤트
                DispatchQueue.main.async {
                    self.connected = true
                }
            case .RINGING_EVENT: // 상대방에게서 전화가 걸려올때 발생하는 이벤트
                DispatchQueue.main.async {
                    self.ringingFlag = true
                }
            default:
                print("not implemented events")
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
    
    func leave() async {
        do {
            try await sdk?.leave(session: self.mySession) // default: 자기 자신 퇴장
        } catch {
            print("error on leave, \(error)")
        }
    }
    
    func videoOfferCall(calleeId: String) async throws {
        do {
            try await sdk?.offerCall(callType: .VIDEO_CALL, callee: calleeId, record: true, localView: self.localView, remoteView: self.remoteView)
        } catch {
            print("error on offerCall \(error)")
            throw error
        }
    }
    
    func videoAnswerCall() async throws {
        do {
            try await sdk?.answerCall(localView: localView, remoteView: remoteView)
        } catch {
            print("error on answerCall \(error)")
            throw error
        }
    }
    
    func setMute(type: TRACK_TYPE) async throws {
        do {
            try await sdk?.setMute(track: type)
        } catch {
            print("error on setMute \(error)")
            throw error
        }
    }
    
    func setUnmute(type: TRACK_TYPE) async throws {
        do {
            try await sdk?.setUnmute(track: type)
        } catch {
            print("error on setUnmute \(error)")
            throw error
        }
    }
    
    func setAudio(type: MIC_TYPE) async throws {
        do {
            try await sdk?.setAudioDevice(type: type)
        } catch {
            print("error on setAudioDevice \(error)")
        }
    }
    
    func setCamera(type: CAM_TYPE) async throws {
        do {
            try await sdk?.setVideoDevice(type: type)
        } catch {
            print("error on setVideoDevice \(error)")
        }
    }

    
}
