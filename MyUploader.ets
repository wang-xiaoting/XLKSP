import picker from '@ohos.file.picker';

@Entry
@Component
struct MyUploader {
  @State selectedImages: Resource[] = []
  @State selectedVideos: Resource[] = []
  @State selectedAudios: Resource[] = []
  @State textValue: string = ''

  build() {
    Column() {
      // 选择图片
      Button('选择图片').onClick(() => {
        // 假设 picker.FilePicker 存在
        picker.FilePicker.pick({ type: 'image/*' }).then(files => {
          this.selectedImages = files
        })
      })
      // 选择视频
      Button('选择视频').onClick(() => {
        picker.FilePicker.pick({ type: 'video/*' }).then(files => {
          this.selectedVideos = files
        })
      })
      // 选择音频
      Button('选择音频').onClick(() => {
        picker.FilePicker.pick({ type: 'audio/*' }).then(files => {
          this.selectedAudios = files
        })
      })
      // 输入文字
      TextInput({ placeholder: '请输入文字', onChange: val => this.textValue = val })

      // 发布
      Button('发布').onClick(() => {
        this.publishContent()
      })
    }
  }

  publishContent() {
    // 这里整合 selectedImages、selectedVideos、selectedAudios、textValue 发送到后端
    // 可以用fetch或者项目内的网络请求模块
  }
}