import router from '@ohos.router';

/**
 * 私信消息接口
 * 定义私信消息的数据结构
 */
interface Message {
  id: number,           // 消息ID
  avatar: Resource,     // 发送者头像
  name: string,         // 发送者名称
  time: string,         // 发送时间
  content: string,      // 消息内容
  unreadCount?: number  // 未读消息数（可选）
}

/**
 * 系统通知接口
 * 定义系统通知的数据结构
 */
interface Notification {
  id: number,           // 通知ID
  avatar: Resource,     // 相关用户头像
  name: string,         // 相关用户名称
  time: string,         // 通知时间
  type: string,         // 通知类型
  content?: string      // 通知内容（可选）
}

/**
 * 导航项接口
 * 定义底部导航栏项的数据结构
 */
interface NavItem {
  icon: string,         // 导航图标
  label: string,        // 导航标签
  route: string,        // 导航路由
  active?: boolean      // 是否激活（可选）
}

/**
 * 标签类型
 * 定义消息页面的标签类型
 */
type TabType = 'private' | 'notification' | 'mention' | 'comment';

/**
 * 消息页面组件
 * 用于显示用户的私信和系统通知
 */
@Entry
@Component
struct Messages {
  @State currentTab: TabType = 'private'  // 当前选中的标签
  @State messages: Message[] = [           // 私信消息列表
    {
      id: 1,
      avatar: $r('app.media.profile1'),
      name: '舞蹈达人',
      time: '12:30',
      content: '你好，请问你对最新的舞蹈视频有什么建议吗？我觉得你的动作编排很专业！',
      unreadCount: 2
    },
    {
      id: 2,
      avatar: $r('app.media.profile2'),
      name: '音乐制作人',
      time: '昨天',
      content: '我刚上传了新的音乐，希望你能听听看，给点建议！'
    }
  ]

  @State notifications: Notification[] = [  // 系统通知列表
    {
      id: 1,
      avatar: $r('app.media.profile1'),
      name: '舞蹈达人',
      time: '30分钟前',
      type: 'comment',
      content: '这个动作编排真不错，我很喜欢！'
    },
    {
      id: 2,
      avatar: $r('app.media.profile2'),
      name: '音乐制作人',
      time: '2小时前',
      type: 'like'
    }
  ]

  // 标签名称映射
  private readonly tabNames: Record<TabType, string> = {
    'private': '私信',
    'notification': '通知',
    'mention': '@我',
    'comment': '评论'
  }

  // 通知类型文本映射
  private readonly notificationTypes: Record<string, string> = {
    'comment': '评论了你的视频',
    'like': '点赞了你的视频'
  }

  // 底部导航项配置
  private readonly navItems: NavItem[] = [
    { icon: '🏠', label: '首页', route: 'Index', active: false },
    { icon: '🔍', label: '发现', route: 'Discover', active: false },
    { icon: '+', label: '创建', route: 'Create', active: false },
    { icon: '💬', label: '消息', route: 'Messages', active: true },
    { icon: '👤', label: '我', route: 'Profile', active: false }
  ]

  /**
   * 页面头部构建器
   * 包含返回按钮、标题和搜索按钮
   */
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

      Text('消息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')


      Button() {
        Text('✍️')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/setting'})
          })
      }
      .backgroundColor('transparent')
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * 消息标签切换栏构建器
   * 构建消息类型的切换标签
   */
  @Builder MessageTabs() {
    Row() {
      ForEach(['private', 'notification', 'mention', 'comment'] as TabType[], (tab: TabType) => {
        Text(this.tabNames[tab])
          .fontSize(16)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.6)')
          .fontWeight(this.currentTab === tab ? FontWeight.Bold : FontWeight.Normal)
          .padding(10)
          .onClick(() => {
            this.currentTab = tab
          })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .borderWidth({ bottom: 1 })
    .borderColor('rgba(255, 255, 255, 0.1)')
  }

  /**
   * 搜索栏构建器
   * 构建消息搜索输入框
   */
  @Builder SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .opacity(0.7)
      TextInput({ placeholder: '搜索联系人或消息' })
        .backgroundColor('transparent')
        .placeholderColor('rgba(255, 255, 255, 0.5)')
        .fontSize(14)
        .width('90%')
        .margin({ left: 10 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(20)
    .margin(15)
  }

  /**
   * 私信列表构建器
   * 构建私信消息列表
   */
  @Builder MessageList() {
    List() {
      ForEach(this.messages, (message: Message) => {
        ListItem() {
          Row() {
            Image(message.avatar)
              .width(50)
              .height(50)
              .borderRadius(25)
              .margin({ right: 15 })

            Column() {
              Row() {
                Text(message.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(message.time)
                  .fontSize(12)
                  .fontColor('rgba(255, 255, 255, 0.6)')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              Text(message.content)
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.8)')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)

            if (message.unreadCount) {
              Text(message.unreadCount.toString())
                .width(18)
                .height(18)
                .fontSize(12)
                .textAlign(TextAlign.Center)
                .borderRadius(9)
                .backgroundColor('#FF0050')
                .fontColor('#FFFFFF')
            }
          }
          .width('100%')
          .padding(15)
        }
        .onClick(() => {
          // 处理消息点击
        })
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 通知列表构建器
   * 构建系统通知列表
   */
  @Builder NotificationList() {
    List() {
      ForEach(this.notifications, (notification: Notification) => {
        ListItem() {
          Row() {
            Image(notification.avatar)
              .width(50)
              .height(50)
              .borderRadius(25)
              .margin({ right: 15 })

            Column() {
              Row() {
                Text(notification.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(notification.time)
                  .fontSize(12)
                  .fontColor('rgba(255, 255, 255, 0.6)')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              Text(this.notificationTypes[notification.type] || '')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.8)')

              if (notification.content) {
                Text(notification.content)
                  .fontSize(14)
                  .backgroundColor('rgba(255, 255, 255, 0.1)')
                  .padding(10)
                  .borderRadius(8)
                  .margin({ top: 5 })
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(15)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 底部导航栏构建器
   * 构建应用底部导航菜单
   */
  @Builder BottomNav() {
    Row() {
      ForEach(this.navItems, (item: NavItem) => {
        Column() {
          Text(item.icon)
            .fontSize(24)
          Text(item.label)
            .fontSize(12)
            .fontColor(item.active ? '#FF0050' : '#FFFFFF')
        }
        .onClick(() => {
          if (!item.active) {
            router.pushUrl({ url: `pages/${item.route}` })
          }
        })
      })
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor('rgba(0, 0, 0, 0.8)')
    .borderWidth({ top: 1 })
    .borderColor('rgba(255, 255, 255, 0.1)')
  }

  /**
   * 获取标签显示名称
   * @param tab 标签类型
   * @returns 标签的显示名称
   */
  getTabName(tab: TabType): string {
    return this.tabNames[tab] || ''
  }

  /**
   * 获取通知显示文本
   * @param notification 通知对象
   * @returns 通知的显示文本
   */
  getNotificationText(notification: Notification): string {
    return this.notificationTypes[notification.type] || ''
  }

  /**
   * 页面主体构建函数
   * 构建整个消息页面的UI结构
   */
  build() {
    Stack() {
      Column() {
        this.Header()
        this.MessageTabs()
        this.SearchBar()

        if (this.currentTab === 'private') {
          this.MessageList()
        } else if (this.currentTab === 'notification') {
          this.NotificationList()
        } else {
          // 空状态显示
          Column() {
            Text(this.currentTab === 'mention' ? '@' : '💬')
              .fontSize(60)
              .margin({ bottom: 20 })
            Text(this.currentTab === 'mention' ? '暂无@提及' : '暂无评论')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(this.currentTab === 'mention' ? '当有人@你时，会显示在这里' : '当有人评论你时，会显示在这里')
              .fontSize(14)
              .opacity(0.7)
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        this.BottomNav()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
    }
    .width('100%')
    .height('100%')
  }
}