import SwiftUI
import AVFoundation

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var totalMinutes: Int = 10
    @State private var remaining: Int = 600
    @State private var running = false
    @State private var timer: Timer?
    @State private var showAlarm = false
    @State private var player: AVAudioPlayer?

    private let tasks = [
        "床の物を五つ拾う",
        "シンクの水滴を切る",
        "テーブルを一周拭く",
        "靴を揃える",
        "ゴミ箱を空にする",
        "鏡を一枚磨く",
        "枕元を整える",
        "窓を一枚拭く",
        "洗面台を拭く",
        "本を三冊並べる",
    ]

    @State private var currentTask: String = ""

    var progress: Double {
        let total = Double(totalMinutes * 60)
        guard total > 0 else { return 0 }
        return 1.0 - Double(remaining) / total
    }

    var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("ホウキ針タイマー")
                    .font(.headline)

                ZStack {
                    Circle()
                        .stroke(.green.opacity(0.15), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                        Text("\(totalMinutes)分")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 200, height: 200)

                HStack(spacing: 12) {
                    ForEach([3, 5, 10, 15, 30], id: \.self) { m in
                        Button("\(m)") {
                            guard !running else { return }
                            totalMinutes = m
                            remaining = m * 60
                        }
                        .buttonStyle(.bordered)
                        .tint(totalMinutes == m ? .green : .gray)
                    }
                }

                HStack(spacing: 16) {
                    Button(running ? "一時停止" : "開始") {
                        if running {
                            pause()
                        } else {
                            start()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button("リセット") {
                        reset()
                    }
                    .buttonStyle(.bordered)
                }

                VStack(spacing: 4) {
                    Text("今の一手")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(currentTask)
                        .font(.subheadline.bold())
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .onAppear {
                currentTask = tasks.randomElement() ?? tasks[0]
                remaining = totalMinutes * 60
            }
            .alert("掃除完了！", isPresented: $showAlarm) {
                Button("止める") {
                    player?.stop()
                }
            } message: {
                Text("ホウキを置いて、仕上がりを一度見てみましょう。")
            }
        }
    }

    private func start() {
        running = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
            } else {
                pause()
                playAlarm()
                showAlarm = true
            }
        }
    }

    private func pause() {
        running = false
        timer?.invalidate()
        timer = nil
    }

    private func reset() {
        pause()
        remaining = totalMinutes * 60
        currentTask = tasks.randomElement() ?? tasks[0]
    }

    private func playAlarm() {
        AudioServicesPlayAlertSound(SystemSoundID(1005))
    }
}
