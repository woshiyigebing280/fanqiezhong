// TagView.swift
import SwiftUI

struct TagView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var tagManager = TagManager.shared
    @State private var newTag = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("当前标签")) {
                    Picker("选择标签", selection: $tagManager.currentTag) {
                        ForEach(tagManager.tags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("新建标签")) {
                    TextField("标签名", text: $newTag)
                    Button("添加标签") {
                        guard !newTag.isEmpty else { return }
                        tagManager.addTag(newTag)
                        newTag = ""
                    }
                }
                
                Section(header: Text("管理标签")) {
                    ForEach(tagManager.tags.indices, id: \.self) { index in
                        HStack {
                            Text(tagManager.tags[index])
                            Spacer()
                            if tagManager.tags[index] != "专注" {
                                Button(action: {
                                    tagManager.removeTag(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("标签管理", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
