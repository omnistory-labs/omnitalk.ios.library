//
//  VideoConferenceView.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import SwiftUI
import Foundation
import OmnitalkSdk
import WebRTC

struct VideoConferenceView: View {
    @StateObject private var controller = VideoConferenceController()
    
    @State private var roomList: [Room] = []
    
    @State private var selectedRoom: Room? = nil
    @State private var secretInput: String = ""
    
    @State private var joined: Bool = false
    
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
                                        try await self.controller.publish()
                                        try await self.controller.subscribeAll()
                                    }
                                } catch {
                                    isErrored = true
                                    errorMsg = "\(error)"
                                }
                            }
                        }
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyHStack() {
                            ForEach(Array(self.controller.subscriberViews.enumerated()), id: \.offset) { index, subInfo in
                                OmnitalkSdk.WebRTCVideoView(view: subInfo.view)
                                    .frame(width: 250, height: 200)
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    }.frame(height: UIScreen.main.bounds.height * 0.5)
                        .frame(maxWidth: 2400)
                    HStack {
                        OmnitalkSdk.WebRTCVideoView(view: self.controller.publisherView).frame(maxWidth: .infinity).frame(height: UIScreen.main.bounds.height * 0.5)
                    }
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

struct VideoConferencePreviews: PreviewProvider {
    static var previews: some View {
        VideoConferenceView()
    }
}
