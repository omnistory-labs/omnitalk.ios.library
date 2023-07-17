//
//  ContentView.swift
//  OmnitalkDemo
//
//  Created by echo on 2023/06/07.
//

import SwiftUI
import OmnitalkSdk

struct ContentView: View {
    let SERVICE_ID =
    let SERVICE_KEY =
    
    var body: some View {
        NavigationView {
            VStack {
                Text("- Video -")
                // 화상회의, 자신의 영상 송출 및 다른 참가자들의 영상 구독 하는 예제
                NavigationLink(destination: VideoConferenceView()) {
                    Text("Video Conference")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }.padding(10)
                
                // 화상통화, 자신의 영상 송출 및 상대방의 영상 구독 하는 예제
                // 전화 걸기(offerCall), 전화 받기(answerCall) 예제
                // 장치(카메라, 오디오) 음소거 및 제어 예제 포함
                NavigationLink(destination: VideoCallView()) {
                    Text("Video Call")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }.padding(10)
                
                Spacer()
                    .frame(height: 50)
                
                // 음성회의(그룹콜), 자신의 음성 송출 및 다른 참가자들과의 음성 회의 예제
                // 간단한 채팅 예제 포함
                Text("- Audio -")
                NavigationLink(destination: AudioConferenceView()) {
                    Text("Audio Conference")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    
                }.padding(10)
                
                // 음성통화, 상대방과 음성 통화 하는 예제
                // 전화 걸기(offerCall), 전화 받기(answerCall) 예제
                NavigationLink(destination: AudioCallView()) {
                    Text("Audio Call")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }.padding(10)
                
            }
        }.onAppear(){
            do {
                try OmniTalk.sdkInit(serviceId: self.SERVICE_ID, serviceKey: self.SERVICE_KEY)
            } catch {
                print("failed to sdk init, \(error)")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
