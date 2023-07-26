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
                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
            }
            Text("\(viewModel.likesCount)")
        }
    }
}





