import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

interface RouteParams {
  showPrivacy?: boolean
}

@Entry
@Component
struct Settings {
  @State currentTab: string = 'general'

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params?.showPrivacy) {
      this.currentTab = 'privacy';
    }
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

      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#000000')
  }

  @Builder TabBar() {
    Row() {
      ForEach(['general', 'privacy', 'notification', 'about'], (tab: string) => {
        Text(this.getTabName(tab))
          .fontSize(16)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.7)')
          .padding({ top: 15, bottom: 15 })
          .borderWidth({ bottom: this.currentTab === tab ? 2 : 0 })
          .borderColor('#FF0050')
          .onClick(() => {
            this.currentTab = tab;
          })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .borderWidth({ bottom: 1 })
    .borderColor('rgba(255, 255, 255, 0.1)')
  }

  @Builder SettingItem(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(description)
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.6)')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(20)
        .fontColor('rgba(255, 255, 255, 0.6)')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#1A1A1A')
    .borderRadius(8)
    .margin({ bottom: 10 })
    .onClick(onClick)
  }

  getTabName(tab: string): string {
    const tabNames = {
      'general': '通用',
      'privacy': '隐私',
      'notification': '通知',
      'about': '关于'
    };
    return tabNames[tab] || tab;
  }

  build() {
    Column() {
      this.Header()
      this.TabBar()

      Scroll() {
        Column() {
          if (this.currentTab === 'general') {
            this.SettingItem(
              '账号安全',
              '修改密码、绑定手机号等',
              () => {
                router.pushUrl({ url: 'pages/AccountSecurity' });
              }
            )

            this.SettingItem(
              '清除缓存',
              '清除应用缓存数据',
              () => {
                promptAction.showToast({ message: '缓存已清除' });
              }
            )
          } else if (this.currentTab === 'privacy') {
            this.SettingItem(
              '隐私设置',
              '管理账号隐私和互动权限',
              () => {
                router.pushUrl({ url: 'pages/Privacy' });
              }
            )

            this.SettingItem(
              '黑名单管理',
              '管理已屏蔽的用户',
              () => {
                router.pushUrl({ url: 'pages/BlockList' });
              }
            )
          } else if (this.currentTab === 'notification') {
            this.SettingItem(
              '推送通知',
              '管理应用通知设置',
              () => {
                router.pushUrl({ url: 'pages/NotificationSettings' });
              }
            )
          } else if (this.currentTab === 'about') {
            this.SettingItem(
              '关于我们',
              '了解应用信息和版本',
              () => {
                router.pushUrl({ url: 'pages/About' });
              }
            )

            this.SettingItem(
              '用户协议',
              '查看用户协议和隐私政策',
              () => {
                router.pushUrl({ url: 'pages/Terms' });
              }
            )
          }
        }
        .padding(15)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
} 