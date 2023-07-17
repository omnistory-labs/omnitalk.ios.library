//
//  VideoCallView.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import SwiftUI
import OmnitalkSdk
import WebRTC

struct VideoCallView: View {
    @StateObject private var controller = VideoCallController()
    
    @State private var joined: Bool = false
    @State private var isErrored: Bool = false
    @State private var errorMsg = ""
    
    @State private var isActiveCallerId = false
    
    @State private var callerId = ""
    @State private var calleeId = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if !joined {
                    HStack {
                        TextField("내 번호 등록", text: $callerId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isActiveCallerId)
                            .padding()
                        Button("번호 등록") {
                            Task {
                                do {
                                    try await self.controller.connect(userId: self.callerId)
                                    self.isActiveCallerId = true
                                } catch {
                                    isErrored = true
                                    errorMsg = "\(error)"
                                }
                            }
                        }
                        .disabled(isActiveCallerId)
                        .padding()
                    }
                    HStack {
                        TextField("상대 번호 등록", text: $calleeId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(!isActiveCallerId)
                            .padding()
                        Button("전화 걸기") {
                            Task {
                                do {
                                    self.joined = true
                                    try await self.controller.videoOfferCall(calleeId: self.calleeId)
                                } catch {
                                    isErrored = true
                                    errorMsg = "\(error)"
                                }
                            }
                        }
                        .disabled(!isActiveCallerId)
                        .padding()
                    }
                    if self.controller.ringingFlag {
                        Button("전화 받기") {
                            Task {
                                do {
                                    self.joined = true
                                    try await self.controller.videoAnswerCall()
                                } catch {
                                    isErrored = true
                                    errorMsg = "\(error)"
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 44)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    VStack {
                        
                        HStack {
                            if !self.controller.connected {
                                
                            } else {
                                OmnitalkSdk.WebRTCVideoView(view: self.controller.remoteView)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
//                        .frame(maxWidth: .infinity).frame(height: UIScreen.main.bounds.height * 0.6)
                        
                        HStack {
                            OmnitalkSdk.WebRTCVideoView(view: self.controller.localView)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        
                    }
                    .frame(maxWidth: .infinity).frame(height: UIScreen.main.bounds.height * 0.8)

                    VStack {
                        
                        HStack {
                            
                            Button("vMute") {
                                Task {
                                    try await self.controller.setMute(type: .VIDEO)
                                }
                            }
                            Button("vUnmute") {
                                Task {
                                    try await self.controller.setUnmute(type: .VIDEO)
                                }
                            }
                            Button("aMute") {
                                Task {
                                    try await self.controller.setMute(type: .AUDIO)
                                }
                            }
                            Button("aUnmute") {
                                Task {
                                    try await self.controller.setUnmute(type: .AUDIO)
                                }
                            }
                            
                        }
                        
                        HStack {
                            
                            Button("front") {
                                Task {
                                    try await self.controller.setCamera(type: .front)
                                }
                            }
                            Button("back") {
                                Task {
                                    try await self.controller.setCamera(type: .back)
                                }
                            }
                            Button("ear") {
                                Task {
                                    try await self.controller.setAudio(type: .defaultInEar)
                                }
                            }
                            Button("spearker") {
                                Task {
                                    try await self.controller.setAudio(type: .speaker)
                                }
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: UIScreen.main.bounds.height * 0.2)
                    
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

struct VideoCallPreviews: PreviewProvider {
    static var previews: some View {
        VideoCallView()
    }
}

