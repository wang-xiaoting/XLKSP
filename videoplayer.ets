/*路由管理：
router.back() 返回上一页
router.pushUrl() 跳转页面并传参
router.getParams() 获取路由参数
状态管理：
@State 装饰器实现响应式状态
通过状态驱动UI更新（如开关状态、输入框内容）
组件复用：
使用@Builder创建可复用组件（如Header）
通过参数化配置实现组件灵活性（如PrivacySection）
交互功能：
Toggle组件实现开关控制
TextInput实现表单输入
Slider实现进度控制
VideoController实现视频播放控制
数据展示：
ForEach动态渲染列表
Grid布局实现瀑布流展示
条件渲染不同内容区块*/
import router from '@ohos.router';

/**
 * 视频更新事件接口
 * 用于处理视频播放进度更新事件
 */
interface VideoUpdateEvent {
  time: number;  // 当前播放时间（秒）
}

/**
 * 视频播放器组件
 * 用于播放视频内容，包含播放控制、全屏切换等功能
 */
@Entry
@Component
struct VideoPlayer {
  @State isPlaying: boolean = false       // 是否正在播放
  @State currentTime: number = 0          // 当前播放时间（秒）
  @State duration: number = 0             // 视频总时长（秒）
  @State videoUrl: string = 'https://media.w3.org/2010/05/sintel/video.mp4'  // 视频源地址
  @State isFullscreen: boolean = false    // 是否全屏播放
  private videoController: VideoController = new VideoController()  // 视频控制器
  private controller: VideoController = new VideoController()       // 备用视频控制器

  /**
   * 页面主体构建函数
   * 构建整个视频播放器的UI结构
   */
  build() {
    Stack() {
      // 视频播放器
      Video({
        src: this.videoUrl,
        controller: this.videoController
      })
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .onStart(() => { this.isPlaying = true })           // 开始播放时更新状态
        .onPause(() => { this.isPlaying = false })          // 暂停播放时更新状态
        .onFinish(() => { this.isPlaying = false; this.currentTime = 0 })  // 播放结束时重置状态
        .onUpdate((event: VideoUpdateEvent) => { this.currentTime = event.time })  // 更新播放进度

      // 控制栏
      Column() {
        // 顶部控制栏
        Row() {
          Button() {
            Text('←').fontSize(24).fontColor('#FFF')
          }
          .backgroundColor('transparent')
          .onClick(() => { router.back() })  // 返回上一页
        }
        .width('100%').height(50)
        .padding({ left: 15, right: 15 })
        .backgroundColor('rgba(0,0,0,0.5)')

        // 底部控制栏
        Column() {
          // 进度条
          Slider({
            value: this.currentTime,
            min: 0,
            max: this.duration,
            step: 1
          })
            .width('100%')
            .height(2)
            .onChange((value: number) => {
              this.videoController.setCurrentTime(value)  // 设置播放进度
            })

          // 控制按钮和时间显示
          Row() {
            Text(this.formatTime(this.currentTime)).fontSize(12).fontColor('#FFF')  // 当前时间
            Row() {
              // 播放/暂停按钮
              Button() {
                Text(this.isPlaying ? '暂停' : '播放').fontSize(14).fontColor('#FFF')
              }
              .backgroundColor('transparent')
              .onClick(() => {
                if (this.isPlaying) {
                  this.videoController.pause()  // 暂停播放
                } else {
                  this.videoController.start()  // 开始播放
                }
              })

              // 全屏切换按钮
              Button() {
                Text(this.isFullscreen ? '退出全屏' : '全屏').fontSize(14).fontColor('#FFF')
              }
              .backgroundColor('transparent')
              .onClick(() => {
                this.isFullscreen = !this.isFullscreen
                this.videoController.requestFullscreen(this.isFullscreen)  // 切换全屏状态
              })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            Text(this.formatTime(this.duration)).fontSize(12).fontColor('#FFF')  // 总时长
          }
          .width('100%')
          .padding({ left: 15, right: 15 })
        }
        .width('100%')
        .padding({ bottom: 15 })
        .backgroundColor('rgba(0,0,0,0.5)')
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%').backgroundColor('#000')
  }

  /**
   * 格式化时间
   * 将秒数转换为分:秒格式
   * @param seconds 秒数
   * @returns 格式化后的时间字符串
   */
  private formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = Math.floor(seconds % 60)
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
  }
}