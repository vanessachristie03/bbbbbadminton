import SwiftUI
import AVKit

struct TrainClassifierView: View {
    @ObservedObject var predictionVM = PredictionViewModel()
    @State private var isShowingRecordedVideos = false
    @State var isRecording = false
    
    var predictionLabels: some View {
        VStack {
            Spacer()
            Text("Prediction: \(predictionVM.predicted)").foregroundStyle(Color.white).fontWeight(.bold)
            Text("Confidence: \(predictionVM.confidence)").foregroundStyle(Color.white).fontWeight(.bold)
        }
        .padding(.bottom, 32)
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    Image(uiImage: predictionVM.currentFrame ?? UIImage())
                        .resizable()
                        .frame(width: gr.size.width, height: gr.size.height)
                        .padding(.zero)
                        .scaledToFit()
                    
                    isRecording ? Rectangle()
                        .frame(width: 300, height: gr.size.height)
                        .border(predictionVM.isCentered ? Color.green : Color.red, width: 2)
                        .foregroundStyle(Color.white.opacity(0))
                        .backgroundStyle(Color.white.opacity(0)) : nil
                    
                    Button {
                        isRecording = !isRecording
                        
                        if isRecording {
                            predictionVM.startRecording()
                        }
                        else {
                            predictionVM.stopRecording()
                            isShowingRecordedVideos = true
                        }
                    } label: {
                        Image(systemName: isRecording ? "stop.fill" : "play.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.white)
                    }
                    
                    predictionLabels
                }
                .onAppear {
                    predictionVM.updateUILabels(with: .startingPrediction)
                }
                .onReceive(
                    NotificationCenter
                        .default
                        .publisher(for: UIDevice.orientationDidChangeNotification)) {
                            _ in
                            predictionVM.videoCapture.updateDeviceOrientation()
                        }
                        .navigationDestination(isPresented: $isShowingRecordedVideos) {
                            RecordedVideosView(predictionVM: predictionVM)
                        }
            }
            .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TrainClassifierView()
}
