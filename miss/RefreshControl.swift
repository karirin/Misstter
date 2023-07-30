//
//  RefreshControl.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/30.
//

import SwiftUI

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
