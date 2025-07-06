//
//  VideoThumbnail.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct VideoThumbnail: View {
    let video: VideoItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(video.backgroundColor)
                .frame(width: 240, height: 160)
            
            Image(systemName: "play.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}
