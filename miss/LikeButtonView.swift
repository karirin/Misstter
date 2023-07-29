//
//  LikeButtonVie.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/23.
//

import SwiftUI

class LikeButtonViewModel: ObservableObject {
    @Published var isLiked: Bool
    @Published var likesCount: Int
    var toggleLike: () -> Void

    init(isLiked: Bool, likesCount: Int, toggleLike: @escaping () -> Void) {
        self.isLiked = isLiked
        self.likesCount = likesCount
        self.toggleLike = toggleLike
    }
}

struct LikeButtonView: View {
    @ObservedObject var viewModel: LikeButtonViewModel
    
    var body: some View {
        HStack{
            Button(action: viewModel.toggleLike) {
                Image(viewModel.isLiked ? "ドンマイ" : "ドンマイ")
                    .resizable()
                    .scaledToFill()
                    .frame(width:30,height:30)
            }
            Text("\(viewModel.likesCount)")
                .fontWeight(.bold)
                .foregroundColor(viewModel.isLiked ? Color("blueline") : Color.black)
            Spacer()
        }
        //        .overlay(
        //            Ellipse()
        //                .fill(viewModel.isLiked ? Color("blue") : Color.clear)
        //                .frame(width: 60, height: 40)
        //                .overlay(
        //                    Ellipse()
        //                        .stroke(viewModel.isLiked ? Color("blueline") : Color.clear, lineWidth: 3)
        //                )
        //        )
    }
}

struct DetailLikeButtonView: View {
    @ObservedObject var viewModel: LikeButtonViewModel
    
    var body: some View {
        HStack{
            Button(action: viewModel.toggleLike) {
                Image(viewModel.isLiked ? "ドンマイ済み" : "ドンマイ")
                    .resizable()
                    .scaledToFill()
                    .frame(width:30,height:30)
            }
        }
        //        .overlay(
        //            Ellipse()
        //                .fill(viewModel.isLiked ? Color("blue") : Color.clear)
        //                .frame(width: 60, height: 40)
        //                .overlay(
        //                    Ellipse()
        //                        .stroke(viewModel.isLiked ? Color("blueline") : Color.clear, lineWidth: 3)
        //                )
        //        )
    }
}
