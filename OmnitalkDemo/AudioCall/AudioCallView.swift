//
//  AudioCallView.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import Foundation
import SwiftUI

struct AudioCallView: View {
    @StateObject private var controller = AudioCallController()
    
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
                                    try await self.controller.connect(userId: callerId)
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
                                    try await self.controller.audioOfferCall(calleeId: self.calleeId)
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
                                    try await self.controller.audioAnswerCall()
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
                    if !self.controller.connected {
                        Text("대기중...")
                    } else {
                        Text("통화중")
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

struct AudioCallPreviews: PreviewProvider {
    static var previews: some View {
        AudioCallView()
    }
}

