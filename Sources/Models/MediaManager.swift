import Foundation
import AVFoundation
import UIKit

class MediaManager: ObservableObject {
    static let shared = MediaManager()
    
    private let fileManager = FileManager.default
    
    private var mediaDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaPath = documentsPath.appendingPathComponent("media", isDirectory: true)
        
        if !fileManager.fileExists(atPath: mediaPath.path) {
            try? fileManager.createDirectory(at: mediaPath, withIntermediateDirectories: true)
        }
        
        return mediaPath
    }
    
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    
    private init() {}
    
    func cardMediaDirectory(for cardId: UUID) -> URL {
        let cardPath = mediaDirectory.appendingPathComponent(cardId.uuidString, isDirectory: true)
        
        if !fileManager.fileExists(atPath: cardPath.path) {
            try? fileManager.createDirectory(at: cardPath, withIntermediateDirectories: true)
        }
        
        return cardPath
    }
    
    func saveImage(_ image: UIImage, for cardId: UUID, isFront: Bool) -> String? {
        let prefix = isFront ? "front" : "back"
        let filename = "\(prefix)_\(UUID().uuidString).jpg"
        let cardDir = cardMediaDirectory(for: cardId)
        let fileURL = cardDir.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func saveAudio(from url: URL, for cardId: UUID, isFront: Bool) -> String? {
        let prefix = isFront ? "front" : "back"
        let ext = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
        let filename = "\(prefix)_\(UUID().uuidString).\(ext)"
        let cardDir = cardMediaDirectory(for: cardId)
        let fileURL = cardDir.appendingPathComponent(filename)
        
        do {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                try fileManager.copyItem(at: url, to: fileURL)
            }
            return fileURL.path
        } catch {
            print("Error saving audio: \(error)")
            return nil
        }
    }
    
    func saveAudioData(_ data: Data, for cardId: UUID, isFront: Bool) -> String? {
        let prefix = isFront ? "front" : "back"
        let filename = "\(prefix)_\(UUID().uuidString).m4a"
        let cardDir = cardMediaDirectory(for: cardId)
        let fileURL = cardDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving audio data: \(error)")
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        guard fileManager.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    func getImageURL(from path: String) -> URL? {
        guard fileManager.fileExists(atPath: path) else { return nil }
        return URL(fileURLWithPath: path)
    }
    
    func playAudio(from path: String) {
        guard fileManager.fileExists(atPath: path) else { return }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func toggleAudio(from path: String) {
        if isPlaying {
            stopAudio()
        } else {
            playAudio(from: path)
        }
    }
    
    func deleteMedia(for cardId: UUID) {
        let cardDir = cardMediaDirectory(for: cardId)
        try? fileManager.removeItem(at: cardDir)
    }
    
    func getMediaSize(for cardId: UUID) -> Int64 {
        let cardDir = cardMediaDirectory(for: cardId)
        
        guard let files = try? fileManager.contentsOfDirectory(at: cardDir, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for file in files {
            if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        
        return totalSize
    }
    
    func copyMediaFromAPKG(mediaPath: URL, cardId: UUID) -> [String: String] {
        var paths: [String: String] = [:]
        
        let cardDir = cardMediaDirectory(for: cardId)
        
        guard let contents = try? fileManager.contentsOfDirectory(at: mediaPath, includingPropertiesForKeys: nil) else {
            return paths
        }
        
        for file in contents {
            let filename = file.lastPathComponent
            let destURL = cardDir.appendingPathComponent(filename)
            
            do {
                try fileManager.copyItem(at: file, to: destURL)
                paths[filename] = destURL.path
            } catch {
                print("Error copying media file: \(error)")
            }
        }
        
        return paths
    }
}
