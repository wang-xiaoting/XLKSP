import router from '@ohos.router';
import { dataManager, Message, ChatMessage } from '../utils/MangerData';

export interface ChatUser {
  id: number,
  name: string,
  avatar: Resource
}

export interface ChatParams {
  user: ChatUser,
  initialMessage?: string
}

@Entry
@Component
struct Chat {
  @State messages: ChatMessage[] = []
  @State inputText: string = ''
  @State chatUser: ChatUser = {
    id: 0,
    name: '',
    avatar: $r('app.media.wudaodaren')
  }

  async aboutToAppear() {
    await dataManager.init(); // 必须初始化
    const params: ChatParams = router.getParams() as ChatParams
    if (params && params.user) {
      this.chatUser = params.user;
      // 加载历史消息
      const stored: ChatMessage[] = await dataManager.getUserMessages(this.chatUser.id);
      if (Array.isArray(stored) && stored.length > 0) {
        this.messages = stored;
      } else if (params.initialMessage) {
        // 首次进入时显示初始消息
        this.messages = [{
          id: 1,
          content: params.initialMessage,
          isSelf: false,
          time: this.getNowTime()
        }];
        await dataManager.saveUserMessages(this.chatUser.id, this.messages);
      }
    }
  }

  private getNowTime(): string {
    const d = new Date();
    return d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
  }

  private async addMessage(msg: ChatMessage) {
    this.messages.push(msg);
    await dataManager.saveUserMessages(this.chatUser.id, this.messages);

    // 更新主摘要（会话列表）
    let allMsgs: Message[] = await dataManager.getPrivateMessages();
    let idx = allMsgs.findIndex(m => m.id === this.chatUser.id);
    let summary: Message = {
      id: this.chatUser.id,
      avatar: this.chatUser.avatar,
      name: this.chatUser.name,
      time: msg.time,
      content: msg.content,
      unreadCount: 0
    };
    if (idx > -1) {
      allMsgs.splice(idx, 1);
    }
    allMsgs = [summary, ...allMsgs];
    await dataManager.savePrivateMessages(allMsgs);
  }

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

      Row() {
        Image(this.chatUser.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 10 })
        Text(this.chatUser.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }

      Button() {
        Text('⋮')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#000000')
  }

  @Builder MessageItem(message: ChatMessage) {
    Row() {
      if (message.isSelf) {
        Blank()
      }
      Column() {
        Text(message.content)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor(message.isSelf ? '#FF0050' : 'rgba(255, 255, 255, 0.1)')
          .padding(10)
          .borderRadius(10)
        Text(message.time)
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.6)')
          .margin({ top: 5 })
      }
      .alignItems(message.isSelf ? HorizontalAlign.End : HorizontalAlign.Start)
      if (!message.isSelf) {
        Blank()
      }
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }

  @Builder InputBar() {
    Row() {
      TextInput({ text: this.inputText, placeholder: '输入消息...' })
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .margin({ right: 10 })
        .fontColor('#FFFFFF')
        .placeholderColor('rgba(255, 255, 255, 0.5)')
        .onChange((value: string) => {
          this.inputText = value
        })

      Button() {
        Text('发送')
          .fontColor('#FFFFFF')
      }
      .backgroundColor('#FF0050')
      .borderRadius(20)
      .height(40)
      .width(60)
      .onClick(async () => {
        if (this.inputText.trim()) {
          // 添加新消息
          const newMessage: ChatMessage = {
            id: Date.now(),
            content: this.inputText,
            isSelf: true,
            time: this.getNowTime()
          }
          await this.addMessage(newMessage)
          this.inputText = ''
        }
      })
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#000000')
  }

  build() {
    Column() {
      this.Header()

      List() {
        ForEach(this.messages, (message: ChatMessage) => {
          ListItem() {
            this.MessageItem(message)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')

      this.InputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}