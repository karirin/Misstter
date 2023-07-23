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
    
    struct RefreshControl: View {
        
        @State private var isRefreshing = false
        var coordinateSpaceName: String
        var onRefresh: () -> Void
        
        var body: some View {
            GeometryReader { geometry in
                if geometry.frame(in: .named(coordinateSpaceName)).midY > 50 {
                    Spacer()
                        .onAppear() {
                            isRefreshing = true
                        }
                } else if geometry.frame(in: .named(coordinateSpaceName)).maxY < 10 {
                    Spacer()
                        .onAppear() {
                            if isRefreshing {
                                isRefreshing = false
                                onRefresh()
                            }
                        }
                }
                HStack {
                    Spacer()
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Text("⬇︎")
                            .font(.system(size: 28))
                    }
                    Spacer()
                }
            }.padding(.top, -50)
        }
    }

    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    Text("")
                    Spacer()
                    Text("目標")
                        .fontWeight(.bold) // <- Change this line
                    Spacer()
                    Text("")
                }
                .padding()
                .background(Color("green"))
                .foregroundColor(.white)
                .frame(height:50)
                .font(.system(size: 20))
                ScrollView {
                    RefreshControl(coordinateSpaceName: "RefreshControl", onRefresh: {
                        print("doRefresh()")
                    })
                    VStack {
                        ForEach(viewModel.tweets, id: \.self) { tweet in
                            HStack{
                                    Image("アイコン")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:80,height:80)
                                        .cornerRadius(75)
                                VStack (alignment: .leading){
                                    Text("りょうや")
                                    .fontWeight(.bold)
                                    Text(tweet.text)
                                    HStack{
                                        Button(action: {
                                            viewModel.toggleLike(tweet: tweet)
                                        }) {
                                            Image(systemName: tweet.isLiked ? "heart.fill" : "heart")
                                        }
                                        Text("\(tweet.likes)") // <- Add this line
                                    }
                                    .padding(.top,5)
                                    Spacer()
                                }
                                .padding(.top,5)
                                Spacer()
                            }
                            .frame(maxWidth:.infinity)
                            .padding(5)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .padding(.horizontal, -16)
                                    .foregroundColor(Color("gray")),
                                alignment: .bottom
                            )
                        }
                        .refreshable {
                            await Task.sleep(1000000000)
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
                                    .background(Color("green"))
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
                                                    .background(Color("green"))
                                                    .cornerRadius(30.0)
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
