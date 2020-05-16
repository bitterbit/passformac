// https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/
import SwiftUI

struct ProgressBar : View {
    @Binding var value: Float
    var body: some View {
        withAnimation {
            _ProgressBar(value: $value)
        }
    }
}

struct LoadingBar : View {
    let timer = Timer.publish(every: 0.1, on: .current, in: .common).autoconnect()
    @State var value: Float = 0
    
    var body: some View {
        _ProgressBar(value: $value).onReceive(timer) {_ in
            if self.value > 1.5 { self.value = -0.5 }
            withAnimation { self.value += 0.05 }
        }
    }
}

struct LoadingButton: View {
    @Binding var loading: Bool
    var text: String
    var action: () -> Void
    
    var body: some View {
        
        ZStack(alignment: .center) {
            Button(action: self.action) { Text(self.text).opacity(loading ? 0 : 1) }
            LoadingBar().frame(width: 30, height: 5).opacity(loading ? 1 : 0)
        }
    }
}

struct _ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(
                    width: geometry.size.width ,
                    height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(NSColor.systemTeal))
                
                Rectangle().frame(
                    width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width),
                    height: geometry.size.height)
                    .foregroundColor(Color(NSColor.systemTeal))
            }.cornerRadius(45.0)
        }
    }
}



struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(value: .constant(1)).frame(height: 5).padding(10)
            ProgressBar(value: .constant(0.10))
            LoadingBar()
            LoadingButton(loading: .constant(false), text: "Sync") { print("click") }
            LoadingButton(loading: .constant(true), text: "Sync") { print("click") }
        }
    }
}
