//
//  AudioConferenceController.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import OmnitalkSdk

struct MessageData: Hashable {
    var session: String
    var userId: String
    var userName: String
    var message: String
    var whisper: Bool
}

class AudioConferenceController: ObservableObject, OmniEventDelegate {
    var sdk: OmniTalk?
    var mySession: String?
    
    @Published var participantList: [String] = [] // 참가자 목록 [session]
    @Published var messageList: [MessageData] = [] // 채팅 데이터 리스트
    
    init() {
        self.sdk = OmniTalk.getInstance()
        self.sdk?.delegate = self
    }
    
    func onEvent(eventName: OmnitalkSdk.OmniEvent, message: Any) {
        print("onEvent - \(eventName), \(message)")
        switch eventName {
            case .LEAVE: // 다른 참가자 퇴장시 발생하는 이벤트
                let leaveEventMsg = message as! EventLeave
                for (index, parti) in self.participantList.enumerated() {
                    if parti == leaveEventMsg.session {
                        DispatchQueue.main.async {
                            self.participantList.remove(at: index)
                        }
                    }
                }
            case .CONNECTED_EVENT: // 다른 참가자 참여시 발생하는 이벤트
                let connectedEventMsg = message as! EventConnected
                DispatchQueue.main.async {
                    self.participantList.append(connectedEventMsg.session)
                }
            case .MESSAGE_EVENT: // 채팅 메세지 수신시 발생하는 이벤트
                let messageEventMsg = message as! EventMessage
                if messageEventMsg.action == .SEND || messageEventMsg.action == .WHISPER {
                    let msg: MessageData = .init(session: messageEventMsg.session, userId: messageEventMsg.userId, userName: messageEventMsg.userName, message: messageEventMsg.message!, whisper: messageEventMsg.action == .WHISPER ? true : false)
                    DispatchQueue.main.async {
                        self.messageList.append(msg)
                    }
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
    
    // 해당 Demo에서는 room을 생성하고 있지 않습니다.
    func createRoom(subject: String, secret: String) async throws {
        do {
            _ = try await sdk?.createRoom(roomType: .AUDIO_ROOM, subject: subject, secret: secret, startDate: nil, endDate: nil)
        } catch {
            print("error on createRoom, \(error)")
            throw error
        }
    }
    
    func getRoomList() async throws -> Array<Room> {
        let roomListResult = try await sdk?.roomList(roomType: .AUDIO_ROOM, page: nil)
        if roomListResult == nil {
            return []
        }
        return roomListResult!.list
    }
    
    func joinRoom(roomId: String, secret: String?, userName: String?) async throws {
        do {
            _ = try await sdk?.joinRoom(roomId: roomId, secret: secret, userName: userName)
            let sendMsg: MessageData = .init(session: self.mySession!, userId: "", userName: "", message: "채팅방에 입장했습니다.", whisper: false)
            DispatchQueue.main.async {
                self.messageList.append(sendMsg)
            }
        } catch {
            print("error on joinRoom, \(error)")
            throw error
        }
    }
    
    func getPartiList() async throws {
        do {
            let partiList = try await sdk?.partiList(roomId: nil, page: nil) // default: 현재 참여중인 roomId
            for parti in partiList!.list {
                DispatchQueue.main.async {
                    self.participantList.append(parti.session)
                }
            }
        } catch {
            print("error on getPartiList, \(error)")
            throw error
        }
    }
    
    func sendMessage(message: String) async throws {
        do {
            try await sdk?.sendMessage(message: message)
            let sendMsg: MessageData = .init(session: self.mySession!, userId: "me", userName: "me", message: message, whisper: false)
            DispatchQueue.main.async {
                self.messageList.append(sendMsg)
            }
        } catch {
            print("error on sendMessage, \(error)")
            throw error
        }
    }
    
    func leave() async {
        do {
            try await sdk?.leave() // default: 자기 자신 퇴장
        } catch {
            print("error on leave, \(error)")
        }
    }
    

}
