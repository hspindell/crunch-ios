//
//  EventCard.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct EventCard: View {
    var event: Event
    var selected = false
    
    let height: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // TODO - this background image messes up selection from the list
            
//            GeometryReader { geo in
//                AsyncImage(url: event.coverImageURL) { result in
//                    result.image?
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: geo.size.width, height: geo.size.height)
//                }
//                .frame(width: geo.size.width, height: geo.size.height)
//                .fixedSize()
//            }

            
//            if selected == false {
//                Color.backgroundCream.opacity(0.7)
//            }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .background(Color.crunchYellow.mask {
                            Highlighter()
                                .opacity(selected ? 1 : 0)
                        })
                    Text(event.starts_at.formatted(.dateTime.month().day()))
                        .font(.system(size: 12))
                        .foregroundStyle(selected ? Color.white : Color.black)
                    Spacer()
                }
                
                Spacer()
                AsyncImage(url: event.logoURL) { result in
                    result.image?
                        .resizable()
                        .scaledToFit()
                        .frame(width: height * 0.75, height: height * 0.75)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.black)
                        )
                }
            }
            .padding(15)
        }
        .frame(height: height)
        .background(selected ? Color(red: 0.25, green: 0.25, blue: 0.25) : Color.backgroundCream)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 2)
        )
        .solidShadow(cornerRadius: 10, offset: (2, 3))
        .frame(height: height)
    }
}

#Preview {
    VStack {
        EventCard(event: .sample)
        EventCard(event: .sample, selected: true)
    }.frame(width: 300)
}
