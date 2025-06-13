import router from '@ohos.router';
import { dataManager, Message, ChatMessage } from '../utils/MangerData';

interface Notification {
  id: number,
  avatar: Resource,
  name: string,
  time: string,
  type: string,
  content?: string
}

interface NavItem {
  icon: string,
  label: string,
  route: string,
  active?: boolean
}

type TabType = 'private' | 'notification' | 'mention' | 'comment';

@Entry
@Component
struct Messages {
  @State currentTab: TabType = 'private'
  @State messages: Message[] = []
  @State notifications: Notification[] = []
  @State searchText: string = ''
  @State filteredMessages: Message[] = []
  @State showSendDialog: boolean = false
  @State sendMessageText: string = ''
  @State chatTarget: Message | null = null
  @State sendTargetName: string = ''

  private readonly tabNames: Record<TabType, string> = {
    'private': '私信',
    'notification': '通知',
    'mention': '@我',
    'comment': '评论'
  }

  private readonly notificationTypes: Record<string, string> = {
    'comment': '评论了你的视频',
    'like': '点赞了你的视频'
  }

  private readonly navItems: NavItem[] = [
    { icon: '🏠', label: '首页', route: 'Index', active: false },
    { icon: '🔍', label: '发现', route: 'Discover', active: false },
    { icon: '+', label: '创建', route: 'Create', active: false },
    { icon: '💬', label: '消息', route: 'Messages', active: true },
    { icon: '👤', label: '我', route: 'Profile', active: false }
  ]

  async aboutToAppear() {
    await dataManager.init(); // 必须初始化
    // 加载本地消息列表
    const msgs = await dataManager.getPrivateMessages()
    if (Array.isArray(msgs) && msgs.length > 0) {
      this.messages = msgs
    } else {
      this.messages = [
        {
          id: 1,
          avatar: $r('app.media.wudaodaren'),
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
      await dataManager.savePrivateMessages(this.messages)
    }
    this.filteredMessages = this.messages

    // 加载系统通知
    const notis = await dataManager.getNotifications()
    this.notifications = Array.isArray(notis) ? notis : []
  }

  private searchMessages(text: string) {
    this.searchText = text
    this.filteredMessages = text.trim() === ''
      ? this.messages
      : this.messages.filter(message =>
    message.name.toLowerCase().includes(text.toLowerCase()) ||
    message.content.toLowerCase().includes(text.toLowerCase())
    )
  }

  // 发送消息，并保存到聊天历史和摘要
  private async sendMessageNew() {
    let targetName = this.chatTarget ? this.chatTarget.name : this.sendTargetName.trim()
    if (!this.sendMessageText.trim() || !targetName) {
      this.showSendDialog = false
      return
    }

    let userId = this.chatTarget ? this.chatTarget.id : Date.now(); // 新用户用时间戳
    let avatar = this.chatTarget ? this.chatTarget.avatar : $r('app.media.wudaodaren');
    let nowTime = this.formatTime(new Date());
    let content = this.sendMessageText;

    // 1. 获取历史
    let history = await dataManager.getUserMessages(userId);
    if (!Array.isArray(history)) history = [];
    // 2. 新增一条“我发的”
    history.push({
      id: Date.now(),
      content: content,
      isSelf: true,
      time: nowTime
    });
    await dataManager.saveUserMessages(userId, history);

    // 3. 更新主摘要（会话列表）
    let idx = this.messages.findIndex(msg => msg.id === userId);
    let msg: Message = {
      id: userId,
      avatar: avatar,
      name: targetName,
      time: nowTime,
      content: content,
      unreadCount: 0
    };
    if (idx > -1) {
      this.messages.splice(idx, 1);
    }
    this.messages = [msg, ...this.messages];
    await dataManager.savePrivateMessages(this.messages);
    this.filteredMessages = this.messages;

    this.sendMessageText = '';
    this.sendTargetName = '';
    this.showSendDialog = false;
  }

  // 关闭聊天框时也保存数据
  private async closeSendDialog() {
    await dataManager.savePrivateMessages(this.messages)
    this.showSendDialog = false
    this.sendMessageText = ''
    this.sendTargetName = ''
    this.chatTarget = null
  }

  private formatTime(date: Date): string {
    let h = date.getHours().toString().padStart(2, '0');
    let m = date.getMinutes().toString().padStart(2, '0');
    return `${h}:${m}`;
  }

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(24).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => router.back())

      Text('消息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Row() {
        Button() {
          Text('✍️').fontSize(24).fontColor('#FFFFFF')
        }
        .backgroundColor('transparent')

        Button() {
          Text('➕').fontSize(24).fontColor('#FFFFFF')
        }
        .backgroundColor('transparent')
        .onClick(() => {
          this.chatTarget = null
          this.sendMessageText = ''
          this.sendTargetName = ''
          this.showSendDialog = true
        })
      }
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder MessageTabs() {
    Row() {
      ForEach(['private', 'notification', 'mention', 'comment'] as TabType[], (tab: TabType) => {
        Text(this.tabNames[tab])
          .fontSize(16)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.6)')
          .fontWeight(this.currentTab === tab ? FontWeight.Bold : FontWeight.Normal)
          .padding(10)
          .onClick(() => this.currentTab = tab)
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .borderWidth({ bottom: 1 })
    .borderColor('rgba(255, 255, 255, 0.1)')
  }

  @Builder SearchBar() {
    Row() {
      Text('🔍').fontSize(16).opacity(0.7)
      TextInput({ placeholder: '搜索联系人或消息' })
        .backgroundColor('transparent')
        .placeholderColor('rgba(255, 255, 255, 0.5)')
        .fontSize(14)
        .width('90%')
        .margin({ left: 10 })
        .onChange((value: string) => this.searchMessages(value))
    }
    .width('100%')
    .padding(10)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(20)
    .margin(15)
  }

  @Builder MessageUnreadCount(message: Message) {
    if (message.unreadCount !== undefined && message.unreadCount > 0) {
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

  @Builder MessageList() {
    List() {
      ForEach(this.filteredMessages, (message: Message) => {
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

            this.MessageUnreadCount(message)

            Button() {
              Text('发送').fontSize(12).fontColor('#FF0050')
            }
            .backgroundColor('rgba(255,255,255,0.08)')
            .borderRadius(8)
            .onClick(() => {
              this.chatTarget = message
              this.sendMessageText = ''
              this.sendTargetName = ''
              this.showSendDialog = true
            })
          }
          .width('100%')
          .padding(15)
        }
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Chat',
            params: {
              user: {
                id: message.id,
                name: message.name,
                avatar: message.avatar
              }
            }
          })
        })
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder NotificationContent(notification: Notification) {
    if (notification.content) {
      Text(notification.content as string)
        .fontSize(14)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .padding(10)
        .borderRadius(8)
        .margin({ top: 5 })
        .onClick(() => {
          if (notification.type === 'comment' && notification.content) {
            dataManager.addComment(1, {
              id: Date.now(),
              userId: notification.id,
              userName: notification.name,
              content: notification.content,
              time: notification.time
            })
          }
        })
    }
  }

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

              this.NotificationContent(notification)
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

  @Builder SendDialog() {
    Stack() {
      Column() {
        Blank()
          .backgroundColor('rgba(0,0,0,0.4)')
          .width('100%')
          .height('100%')
      }
      Column() {
        // 显示“发送给xxx”或昵称输入框
        Text(`发送给 ${this.chatTarget ? this.chatTarget.name : ''}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })
          .visibility(this.chatTarget ? Visibility.Visible : Visibility.None)

        TextInput({ placeholder: '请输入联系人昵称' })
          .width('100%')
          .padding(10)
          .backgroundColor('rgba(255,255,255,0.1)')
          .fontColor('#222')
          .placeholderColor('#aaa')
          .onChange((v: string) => { this.sendTargetName = v })
          .margin({ bottom: 10 })
          .visibility(this.chatTarget ? Visibility.None : Visibility.Visible)

        TextInput({ placeholder: '请输入消息内容' })
          .width('100%')
          .padding(10)
          .backgroundColor('rgba(255,255,255,0.1)')
          .fontColor('#222')
          .placeholderColor('#aaa')
          .onChange((v: string) => { this.sendMessageText = v })
          .margin({ bottom: 12 })

        Row() {
          Button() {
            Text('取消').fontColor('#888')
          }
          .backgroundColor('rgba(0,0,0,0.06)')
          .onClick(() => { this.closeSendDialog() })
          Button() {
            Text('发送').fontColor('#FF0050')
          }
          .backgroundColor('rgba(0,0,0,0.06)')
          .margin({ left: 20 })
          .onClick(() => { this.sendMessageNew() })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('80%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(16)
      .alignItems(HorizontalAlign.Center)
      .position({ x: '10%', y: '30%' })
    }
  }

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

  @Builder EmptyState() {
    Column() {
      Text(this.currentTab === 'mention' ? '@' : '💬')
        .fontSize(60)
        .margin({ bottom: 20 })
      Text(this.currentTab === 'mention' ? '暂无@提及' : '暂无评论')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(this.currentTab === 'mention'
        ? '当有人@你时，会显示在这里'
        : '当有人评论你时，会显示在这里')
        .fontSize(14)
        .opacity(0.7)
      Button() {
        Text('➕发起聊天').fontSize(16).fontColor('#FF0050')
      }
      .margin({ top: 20 })
      .onClick(() => {
        this.chatTarget = null
        this.sendMessageText = ''
        this.sendTargetName = ''
        this.showSendDialog = true
      })
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

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
          this.EmptyState()
        }

        this.BottomNav()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')

      if (this.showSendDialog) {
        this.SendDialog()
      }
    }
    .width('100%')
    .height('100%')
  }
}