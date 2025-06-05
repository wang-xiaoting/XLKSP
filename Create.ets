import router from '@ohos.router'

/**
 * 模式选项接口
 * 定义创建内容时可选的模式选项
 */
interface ModeOption {
  key: string,    // 模式键值
  icon: string,   // 模式图标
  label: string   // 模式标签
}

/**
 * 滤镜类型
 * 定义可用的滤镜效果类型
 */
type FilterType = 'none' | 'warm' | 'cool' | 'vintage' | 'dramatic'

/**
 * 创建内容页面组件
 * 用于创建和发布新的内容
 */
@Entry
@Component
struct Create {
  @State currentMode: string = 'video'           // 当前选择的创建模式
  @State previewContent: string = ''             // 预览内容
  @State selectedFilter: FilterType = 'none'     // 当前选择的滤镜
  @State isPrivate: boolean = false              // 是否设为私密

  // 创建模式选项配置
  private modeOptions: ModeOption[] = [
    { key: 'video', icon: '🎥', label: '视频' },
    { key: 'photo', icon: '📷', label: '照片' },
    { key: 'music', icon: '🎵', label: '音乐' },
    { key: 'text', icon: '📝', label: '文字' }
  ]

  /**
   * 页面头部构建器
   * 包含取消按钮、标题和发布按钮
   */
  @Builder Header() {
    Row() {
      Button() {
        Text('取消')
          .fontColor('#FFFFFF')
          .fontSize(16)
      }
      .backgroundColor('transparent')
      .onClick(() => {
        router.back()
      })

      Text('创建内容')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Button() {
        Text('发布')
          .fontColor('#FF0050')
          .fontSize(16)
      }
      .backgroundColor('transparent')
      .enabled(this.previewContent.length > 0)
      .onClick(() => {
        // 处理发布逻辑
      })
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * 模式切换器构建器
   * 构建创建模式的切换选项
   */
  @Builder ModeSwitcher() {
    Row() {
      ForEach(this.modeOptions, (item: ModeOption) => {
        Column({ space: 5 }) {
          Text(item.icon)
            .fontSize(24)
          Text(item.label)
            .fontSize(12)
            .fontColor(this.currentMode === item.key ? '#FF0050' : '#FFFFFF')
        }
        .onClick(() => {
          this.currentMode = item.key
          this.previewContent = ''
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 15, bottom: 15 })
  }

  /**
   * 预览区域构建器
   * 根据当前模式构建不同的预览界面
   */
  @Builder PreviewArea() {
    Stack() {
      if (this.currentMode === 'video') {
        Column() {
          Text('点击录制视频')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.8)
          Text('或')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.6)
            .margin({ top: 10, bottom: 10 })
          Button('从相册选择')
            .backgroundColor('#FF0050')
            .height(40)
            .width(120)
            .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.currentMode === 'photo') {
        Column() {
          Text('点击拍摄照片')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.8)
          Text('或')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.6)
            .margin({ top: 10, bottom: 10 })
          Button('从相册选择')
            .backgroundColor('#FF0050')
            .height(40)
            .width(120)
            .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.currentMode === 'music') {
        Column() {
          Text('点击录制音频')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.8)
          Text('或')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.6)
            .margin({ top: 10, bottom: 10 })
          Button('从音乐库选择')
            .backgroundColor('#FF0050')
            .height(40)
            .width(120)
            .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        TextArea({ placeholder: '分享你的想法...' })
          .placeholderColor('rgba(255, 255, 255, 0.6)')
          .backgroundColor('transparent')
          .fontColor('#FFFFFF')
          .height('100%')
          .width('100%')
          .onChange((value: string) => {
            this.previewContent = value
          })
      }
    }
    .width('100%')
    .height('50%')
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(20)
  }

  /**
   * 工具栏构建器
   * 构建内容编辑工具栏，包含滤镜选择和隐私设置
   */
  @Builder ToolBar() {
    Column({ space: 15 }) {
      // 滤镜选择器（非文字模式时显示）
      if (this.currentMode !== 'text') {
        Row() {
          Text('滤镜')
            .fontSize(16)
            .fontColor('#FFFFFF')
          Scroll() {
            Row({ space: 10 }) {
              ForEach(['none', 'warm', 'cool', 'vintage', 'dramatic'], (filter: FilterType) => {
                Column() {
                  Text(filter)
                    .fontSize(14)
                    .fontColor(this.selectedFilter === filter ? '#FF0050' : '#FFFFFF')
                }
                .backgroundColor(this.selectedFilter === filter ? 'rgba(255, 0, 80, 0.2)' : 'transparent')
                .padding(10)
                .borderRadius(15)
                .onClick(() => {
                  this.selectedFilter = filter
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 15, right: 15 })
      }

      // 隐私设置
      Row() {
        Text('设为私密')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Toggle({ type: ToggleType.Switch, isOn: this.isPrivate })
          .selectedColor('#FF0050')
          .switchPointColor('#FFFFFF')
          .onChange((isOn: boolean) => {
            this.isPrivate = isOn
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 15, right: 15 })
    }
  }

  /**
   * 页面主体构建函数
   * 构建整个创建内容页面的UI结构
   */
  build() {
    Stack() {
      Column() {
        // 背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#121212')
          .position({ x: 0, y: 0 })

        // 内容
        Column() {
          this.Header()
          this.ModeSwitcher()
          this.PreviewArea()
          this.ToolBar()
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}

