/*
音频播放器核心功能：包含播放状态管理、进度控制、时间计算
动态音频可视化：通过定时器生成随机高度柱状图模拟音频波形
完整的播放器UI：包含专辑封面旋转动画、模糊背景、操作按钮组
交互功能：支持播放/暂停、进度拖动、点赞等操作
生命周期管理：组件销毁时自动清理定时器
响应式设计：通过@State实现数据变化自动触发UI更新
关键API/组件：
setInterval：用于创建定时器
Slider：进度条组件
@Builder：自定义构建函数
Stack/Column/Row：布局容器
Image/Text：基础显示组件
router：鸿蒙路由模块
*/
import router from '@ohos.router'

@Entry //自定义入口组件
@Component
struct AudioPlayer {
  @State currentProgress: number = 0
  //状态管理区域
  @State isPlaying: boolean = false //当前进度播放百分比
  @State currentTime: string = '00:00' //播放状态控制
  @State totalTime: string = '03:45' //格式化的当前播放时间
  @State audioBarHeights: number[] = Array(30).fill(20) //音频可视化柱状图的30个随机高度值
  @State isLiked: boolean = false // 点赞按钮状态
  @State likeCount: string = '5.7w' //点赞数
  @State commentCount: string = '3208' //评论数量

  private intervalID: number = -1//存储定时器id用于清除

  aboutToAppear() {
    // 启动音频条动画
    this.intervalID = setInterval(() => {
      this.audioBarHeights = this.audioBarHeights.map(() => Math.floor(Math.random() * 40) + 10)
    }, 200)

    // 模拟进度更新
    setInterval(() => {
      if (this.isPlaying) {
        this.currentProgress = (this.currentProgress + 0.1) % 100
        this.updateCurrentTime() // 调用时间格式化方法
      }
    }, 100)
  }

  aboutToDisappear() {
    if (this.intervalID !== -1) {
      clearInterval(this.intervalID)
    }
  }

  // 根据进度百分比计算当前播放时间
  updateCurrentTime() {
    const totalSeconds = 225 // 3:45 in seconds
    const currentSeconds = Math.floor(totalSeconds * (this.currentProgress / 100))
    const minutes = Math.floor(currentSeconds / 60)
    const seconds = currentSeconds % 60
    this.currentTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }// 格式化为两位数字（如 03:15）

  // 构建顶部导航栏（包含返回按钮和标题）/* 使用Row/Image/Text等组件实现导航栏布局 */
  @Builder Header() {
    Row() {
      Button() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => {
        router.back()
      })

      Text('正在播放')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(20)
  }

  // 构建旋转专辑封面（播放时添加旋转动画）/* 使用Image组件和动画属性实现 */
  @Builder AlbumCover() {
    Stack() {
      Image($r('app.media.album_cover1'))
        .width(250)
        .height(250)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          angle: this.isPlaying ? this.currentProgress * 3.6 : 0,
          centerX: '50%',
          centerY: '50%'
        })
    }
    .margin({ top: 50 })
  }

  // 构建音频可视化效果（动态高度的柱状图）// 根据audioBarHeights数组生成多个柱状条
  @Builder AudioVisualizer() {
    Row({ space: 3 }) {
      ForEach(this.audioBarHeights, (height: number) => {
        Column()
          .width(4)
          .height(height)
          .backgroundColor('#FFFFFF')
          .borderRadius(2)
          .opacity(this.isPlaying ? 1 : 0.3)
      })
    }
    .width('80%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Bottom)
    .margin({ top: 30 })
  }

  // 构建右侧操作按钮组（点赞/评论/分享等） /* 使用Column布局垂直排列图标按钮 */
  @Builder SideActions() {
    Column({ space: 20 }) {
      Column({ space: 5 }) {
        Button() {
          Text(this.isLiked ? '❤️' : '🤍')
            .fontSize(24)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        .onClick(() => {
          this.isLiked = !this.isLiked
          this.likeCount = this.isLiked ? '5.8w' : '5.7w'
        })
        Text(this.likeCount)
          .fontSize(12)
          .fontColor('#FFFFFF')
      }

      Column({ space: 5 }) {
        Button() {
          Text('💬')
            .fontSize(24)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        Text(this.commentCount)
          .fontSize(12)
          .fontColor('#FFFFFF')
      }

      Column({ space: 5 }) {
        Button() {
          Text('⤴️')
            .fontSize(24)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        Text('分享')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }

      Column({ space: 5 }) {
        Button() {
          Text('♫')
            .fontSize(24)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        Text('收藏')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
    }
    .position({ x: '85%', y: '40%' })
  }

  // 主构建函数：定义整体UI结构
  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.background1'))
        .backgroundImageSize(ImageSize.Cover)
        .blur(3) //添加模糊效果
        .opacity(0.8)

      Column() {
        // 顶部导航
        this.Header()

        // 专辑封面
        this.AlbumCover()

        // 音频可视化
        this.AudioVisualizer()

        // 侧边操作按钮
        this.SideActions()

        // 音乐控制
        // 播放控制按钮行（上一曲/播放暂停/下一曲）
        Row({ space: 20 }) {
          Button() {
            Text('⏮️')
              .fontSize(24)
          }
          .width(50)
          .height(50)
          .borderRadius(25)
          .backgroundColor('rgba(255, 255, 255, 0.2)')

          Button() {
            Text(this.isPlaying ? '⏸️' : '▶️')
              .fontSize(24)
          }
          .width(60)
          .height(60)
          .borderRadius(30)
          .backgroundColor('rgba(255, 255, 255, 0.3)')
          .onClick(() => {
            this.isPlaying = !this.isPlaying
          })

          Button() {
            Text('⏭️')
              .fontSize(24)
          }
          .width(50)
          .height(50)
          .borderRadius(25)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
        }
        .margin({ top: 50 })

        // 音乐信息
        Column({ space: 5 }) {
          Text('晚风轻抚')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('轻音乐大师 - 心灵治愈系列')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
        .margin({ top: 20 })

        // 进度条
        Slider({
          value: this.currentProgress,
          min: 0,
          max: 100,
          style: SliderStyle.OutSet
        })
          .width('80%')
          .margin({ top: 20 })
          .selectedColor('#FFFFFF')
          .trackColor('rgba(255, 255, 255, 0.3)')
          .onChange((value: number) => {  //滑动更新进度
            this.currentProgress = value
            this.updateCurrentTime()
          })

        // 时间信息
        Row() {
          Text(this.currentTime) // 当前时间
            .fontSize(12)
            .fontColor('#FFFFFF')
            .opacity(0.8)
          Text(this.totalTime) //总时长
            .fontSize(12)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
        .width('80%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000') //整体背景黑色
  }
}