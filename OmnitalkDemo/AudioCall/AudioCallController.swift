//
//  AudioCallController.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import OmnitalkSdk

class AudioCallController: ObservableObject, OmniEventDelegate {
    var sdk: OmniTalk?
    var mySession: String?
    
    @Published var ringingFlag = false // 전화 수신중인지 여부 (뷰 업데이트를 위함)
    @Published var connected: Bool = false // 연결 되었는지 여부 (뷰 업데이트를 위함)
    
    init() {
        self.sdk = OmniTalk.getInstance()
        self.sdk?.delegate = self
    }
    
    func onEvent(eventName: OmnitalkSdk.OmniEvent, message: Any) {
        print("onEvent - \(eventName), \(message)")
        switch eventName {
            case .LEAVE: // 다른 참가자 퇴장시 발생하는 이벤트
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
    
    func leave() async {
        do {
            try await sdk?.leave(session: self.mySession) // default: 자기 자신 퇴장
        } catch {
            print("error on leave, \(error)")
        }
    }
    
    func audioOfferCall(calleeId: String) async throws {
        do {
            _ = try await sdk?.offerCall(callType: .AUDIO_CALL, callee: calleeId, record: true, localView: nil, remoteView: nil)
        } catch {
            print("error on offerCall \(error)")
            throw error
        }
    }
    
    func audioAnswerCall() async throws {
        do {
            _ = try await sdk?.answerCall(localView: nil, remoteView: nil)
        } catch {
            print("error on answerCall \(error)")
            throw error
        }
    }
    
}

