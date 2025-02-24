// TagManager.swift
import SwiftUI

class TagManager: ObservableObject {
    static let shared = TagManager()
    
    @Published var tags: [String] = ["专注"]
    @Published var currentTag: String = "专注"
    
    private let tagsKey = "tags"
    private let currentTagKey = "currentTag"
    
    init() {
        loadTags()
        loadCurrentTag()
    }
    
    func addTag(_ tag: String) {
        tags.append(tag)
        saveTags()
    }
    
    func removeTag(at index: Int) {
        tags.remove(at: index)
        saveTags()
    }
    
    func setCurrentTag(_ tag: String) {
        currentTag = tag
        saveCurrentTag()
    }
    
    private func saveTags() {
        UserDefaults.standard.set(tags, forKey: tagsKey)
    }
    
    private func loadTags() {
        if let savedTags = UserDefaults.standard.stringArray(forKey: tagsKey) {
            tags = savedTags
        }
    }
    
    private func saveCurrentTag() {
        UserDefaults.standard.set(currentTag, forKey: currentTagKey)
    }
    
    private func loadCurrentTag() {
        if let savedCurrentTag = UserDefaults.standard.string(forKey: currentTagKey) {
            currentTag = savedCurrentTag
        }
    }
}

