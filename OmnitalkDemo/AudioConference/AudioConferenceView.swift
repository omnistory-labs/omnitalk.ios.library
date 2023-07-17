//
//  AudioConferenceView.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import SwiftUI
import OmnitalkSdk
import WebRTC

struct AudioConferenceView: View {
    @StateObject private var controller = AudioConferenceController()
    
    @State private var roomList: [Room] = []
    
    @State private var selectedRoom: Room? = nil
    @State private var secretInput: String = ""
    
    @State private var joined: Bool = false
    
    @State private var messageInput = ""
    
    @State private var isErrored: Bool = false
    @State private var errorMsg = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if !joined {
                    List(roomList, id: \.self, selection: $selectedRoom) { room in
                        Text("\(room.subject) \(room.count)")
                    }
                    
                    if let room = selectedRoom {
                        Text("Room Title: \(room.subject)")
                            .padding()
                        
                        TextField("Enter secret", text: $secretInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Join") {
                            Task {
                                do {
                                    if selectedRoom != nil {
                                        try await self.controller.joinRoom(roomId: self.selectedRoom!.roomId, secret: secretInput, userName: nil)
                                        self.joined = true
                                        try await self.controller.getPartiList()
                                    }
                                } catch {
                                    isErrored = true
                                    errorMsg = "\(error)"
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        List(self.controller.participantList, id: \.self) { parti in
                            Text(parti)
                        }.frame(height: UIScreen.main.bounds.height * 0.3)
                        
                        ScrollViewReader { scrollView in
                            List(self.controller.messageList, id: \.self) { message in
                                if message.whisper {
                                    Text("\(message.userId) \(message.message)")
                                        .foregroundColor(Color.red)
                                } else if message.userId == "me" {
                                    Text(message.message).frame(maxWidth: .infinity, alignment: .trailing)
                                } else {
                                    Text("\(message.userId) \(message.message)")
                                }
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.3)
                            .onChange(of: self.controller.messageList) { _ in
                                print("onChange")
                                print(self.controller.messageList)
                                print(self.controller.messageList.count)
//                                DispatchQueue.main.async {
                                    withAnimation {
                                        scrollView.scrollTo(self.controller.messageList.last, anchor: .bottom)
                                    }
//                                }
                            }
                        }


                        HStack {
                            TextField("메시지 입력...", text: $messageInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(15)
                            
                            Button("전송") {
                                Task {
                                    do {
                                        try await self.controller.sendMessage(message: messageInput)
                                        self.messageInput = ""
                                    } catch {
                                        isErrored = true
                                        errorMsg = "\(error)"
                                    }
                                }
                            }.padding(15)
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.2)
                        .padding(.bottom, 20)
                    }
                    
//                    .foregroundColor(Color.red)
                    
                }
            }.onAppear {
                Task {
                    do {
                        try await self.controller.connect(userId: nil)
                        self.roomList = try await self.controller.getRoomList()
                    } catch {
                        isErrored = true
                        errorMsg = "\(error)"
                    }
                    
                }
            }.onDisappear {
                Task {
                    await self.controller.leave()
                }
            }.alert(isPresented: $isErrored) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMsg),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct AudioConferencePreviews: PreviewProvider {
    static var previews: some View {
        AudioConferenceView()
    }
}

