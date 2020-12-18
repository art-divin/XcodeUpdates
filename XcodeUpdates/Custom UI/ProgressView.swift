//
//  CircularProgressView.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 01.12.2020.
//

import SwiftUI

struct CircularProgressView: View {
    
    @State var progress : Progress
    
    var body: some View {
        
        VStack {
        
            
            GeometryReader {
                
                
                ZStack {
                    
                    GeometryReader {
                        Rectangle()
                            .foregroundColor(Color(.green))
                            .frame(width: $0.size.width, height: $0.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                        Rectangle()
//                            .foregroundColor(Color(.red))
//                            .frame(width: $0.size.width * 0.3, height: $0.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                        Circle()
                            .path(in: CGRect(origin: CGPoint(x: 0, y: 0), size: $0.size))
                            .stroke(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/, style: StrokeStyle())
                    
                    }
                }.frame(width: $0.size.width, height: $0.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                
            }
            
            
        }
        .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
        
            
    }
}

#if DEBUG
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: Progress(totalUnitCount: 100))
    }
}
#endif
