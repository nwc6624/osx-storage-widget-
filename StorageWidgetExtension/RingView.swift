import SwiftUI

struct RingView: View {
    let progress: Double
    let isInternal: Bool
    @State private var animatedProgress: Double = 0
    
    private let strokeWidth: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background circle (white, semi-transparent)
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: strokeWidth)
                
                // Progress circle (white)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // SF Symbol in center
                Image(systemName: isInternal ? "internaldrive" : "externaldrive")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .aspectRatio(1, contentMode: .fit)
            
            // Percentage text below
            Text("\(Int(progress * 100))%")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            RingView(progress: 0.7, isInternal: true)
                .frame(width: 80, height: 100)
            
            RingView(progress: 0.45, isInternal: false)
                .frame(width: 80, height: 100)
        }
        .padding()
        .background(Color.black)
    }
}

