/*
核心功能实现说明：
1. 数据管理：使用@State实现数据双向绑定，响应式更新UI
2. 路由导航：通过router模块实现页面跳转和参数传递
3. 布局系统：使用Stack/Column/Row等布局容器构建复杂界面
4. 列表渲染：ForEach循环渲染动态数据内容
5. 交互处理：实现点击事件、输入监听等用户交互
6. 样式控制：通过链式调用设置尺寸/颜色/边距等样式属性
7. 组件复用：通过@Builder构建可复用的UI组件
*/
import router from '@ohos.router';

/**
 * 应用卡片接口
 * 定义首页应用卡片的数据结构
 */
interface AppCard {
  id: number,           // 卡片ID
  title: string,        // 卡片标题
  description: string,  // 卡片描述
  background: Resource, // 卡片背景图
  route: string        // 卡片对应的路由
}

/**
 * 首页组件
 * 作为应用的主入口，展示主要功能卡片
 */
@Entry
@Component
struct Index {
  @State appCards: AppCard[] = [  // 应用卡片列表
    {
      id: 1,
      title: '视频播放',
      description: '畅享高清视频、精彩内容，支持多种格式和悬浮窗播放。',
      background: $r('app.media.background1'),
      route: 'pages/videoplayer'
    },
    {
      id: 2,
      title: '音频播放',
      description: '沉浸式音乐体验，动态音频可视化，让您的聆听更加震撼。',
      background: $r('app.media.thumbnail_cover1'),
      route: 'pages/Audioplayer'
    },
    {
      id: 3,
      title: '个人中心',
      description: '查看您的收藏、历史记录，管理您的音视频资源。',
      background: $r('app.media.profile2'),
      route: 'pages/ProfileCenter'
    }
  ]

  /**
   * 页面头部构建器
   * 构建页面标题
   */
  @Builder Header() {
    Text('HarmonyOS 音视频')
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .margin({ top: 20 })
  }

  /**
   * 应用卡片构建器
   * 构建单个应用卡片的UI
   * @param card 应用卡片数据
   */
  @Builder AppCard(card: AppCard) {
    Stack() {
      // 卡片背景图
      Image(card.background)
        .width('100%')
        .height('100%')
        .borderRadius(16)
        .objectFit(ImageFit.Cover)
        .opacity(0.7)

      // 卡片内容
      Column() {
        Text(card.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 8 })

        Text(card.description)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .margin({ bottom: 16 })

        Button('立即体验')
          .width(120)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF0050')
          .borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: card.route })
          })
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
      .backgroundImage($r('app.media.gradient'))
      .backgroundImageSize({ width: '100%', height: '100%' })
    }
    .width('100%')
    .height(400)
    .borderRadius(16)
    .animation({
      duration: 300,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal
    })
  }

  /**
   * 底部导航栏构建器
   * 构建应用底部导航菜单
   */
  @Builder BottomNav() {
    Row() {
      // 首页导航项
      Column() {
        Text('🏠')
          .fontSize(24)
        Text('首页')
          .fontSize(12)
          .fontColor('#FF0050')
      }
      .onClick(() => {
        router.pushUrl({ url: ''})
      })

      // 发现导航项
      Column() {
        Text('🔍')
          .fontSize(24)
        Text('发现')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/Discover' })
      })

      // 创建导航项
      Column() {
        Text('+')
          .fontSize(24)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .backgroundColor('#FF0050')
        Text('创建')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/Create' })
      })

      // 消息导航项
      Column() {
        Text('💬')
          .fontSize(24)
        Text('消息')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/Message' })
      })

      // 我的导航项
      Column() {
        Text('👤')
          .fontSize(24)
        Text('我')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/ProfileCenter' })
      })
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.8)')
    .borderColor('rgba(255, 255, 255, 0.1)')
    .borderWidth({ top: 1 })
  }

  /**
   * 页面主体构建函数
   * 构建整个首页的UI结构
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

          Scroll() {
            Column({ space: 20 }) {
              ForEach(this.appCards, (card: AppCard) => {
                this.AppCard(card)
              })
            }
            .width('100%')
            .padding(20)
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)

          this.BottomNav()
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