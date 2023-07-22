//
//  ContentView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = TweetViewModel()
    @State var showAnotherView_post: Bool = false
    @State private var inputText: String = ""

    var body: some View {
        NavigationView {
            VStack{
                ScrollView {
                    VStack {
                        ForEach(viewModel.tweets, id: \.self) { tweet in
                            HStack{
                                    Image("アイコン")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:80,height:80)
                                        .cornerRadius(75)
//                                        .padding()
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 30)
//                                                .fill(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
//                                        )
                                VStack (alignment: .leading){
                                    Text("りょうや")
                                    .fontWeight(.bold)
                                    Text(tweet.text)
                                    Spacer()
                                }
                                .padding(.top,5)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear() {
                self.viewModel.fetchData()
            }
        }
            .overlay(
                ZStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack{
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.showAnotherView_post = true
                                }, label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24)) // --- 4
                                }).frame(width: 60, height: 60)
                                    .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
                                    .cornerRadius(30.0)
                                    .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                                    .fullScreenCover(isPresented: $showAnotherView_post, content: {
                                        NavigationView {
                                            VStack {
                                                TextField("口頭で頼まれていたことを忘れてしまった…", text: $inputText)
                                                    .frame(maxWidth: .infinity)
                                                    .border(Color.clear, width: 0)
                                                Spacer()
                                            }
                                            .padding()
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button("キャンセル") {
                                                        self.showAnotherView_post = false
                                                        inputText = ""
                                                    }
                                                    .foregroundColor(.black)
                                                }
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("送信") {
                                                        viewModel.sendTweet(text: inputText)
                                                        inputText = ""
                                                        self.showAnotherView_post = false
                                                    }
                                                    .padding(.vertical,5)
                                                    .padding(.horizontal,25)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0)))
                                                }
                                            }
                                        }
                                    })
                            }.padding()
                        }
                    }
                }
            )
        }
    }
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
