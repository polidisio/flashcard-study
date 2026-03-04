import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    var front: String
    var back: String
    var imageFront: String?
    var imageBack: String?
    var audioFront: String?
    var audioBack: String?
    
    init(
        id: UUID = UUID(),
        front: String,
        back: String,
        imageFront: String? = nil,
        imageBack: String? = nil,
        audioFront: String? = nil,
        audioBack: String? = nil
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.imageFront = imageFront
        self.imageBack = imageBack
        self.audioFront = audioFront
        self.audioBack = audioBack
    }
    
    var hasFrontMedia: Bool {
        imageFront != nil || audioFront != nil
    }
    
    var hasBackMedia: Bool {
        imageBack != nil || audioBack != nil
    }
    
    var hasAnyMedia: Bool {
        hasFrontMedia || hasBackMedia
    }
}
