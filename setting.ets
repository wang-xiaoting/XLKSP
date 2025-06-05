import router from '@ohos.router';

/**
 * 设置项接口
 * 定义设置页面的单个设置项结构
 */
interface SettingsItem {
  icon: string,         // 设置项图标
  label: string,        // 设置项标签
  type: 'link' | 'toggle',  // 设置项类型：链接或开关
  route?: string,       // 链接类型设置项的路由（可选）
  state?: boolean,      // 开关类型设置项的状态（可选）
  onToggle?: () => void // 开关状态改变回调（可选）
}

/**
 * 设置页面组件
 * 用于管理应用的各项设置
 */
@Entry
@Component
struct Settings {
  @State darkMode: boolean = true    // 深色模式状态
  @State autoPlay: boolean = true    // 自动播放状态

  /**
   * 页面头部构建器
   * 包含返回按钮和标题
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

      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 设置分组构建器
   * 构建一个设置分组，包含标题和设置项列表
   * @param title 分组标题
   * @param items 设置项列表
   */
  @Builder SettingsSection(title: string, items: SettingsItem[]) {
    Column() {
      Text(title)
        .fontSize(14)
        .opacity(0.7)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .width('100%')
        .padding(15)

      List() {
        ForEach(items, (item: SettingsItem) => {
          ListItem() {
            Row() {
              Row() {
                Text(item.icon)
                  .fontSize(20)
                  .opacity(0.8)
                  .width(24)
                  .textAlign(TextAlign.Center)
                Text(item.label)
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ left: 10 })
              }

              if (item.type === 'link') {
                Text('›')
                  .fontSize(14)
                  .opacity(0.5)
              } else if (item.type === 'toggle') {
                Toggle({ type: ToggleType.Switch, isOn: item.state })
                  .selectedColor('#FF0050')
                  .switchPointColor('#FFFFFF')
                  .onChange(item.onToggle)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(15)
          }
          .onClick(() => {
            if (item.type === 'link' && item.route) {
              router.pushUrl({ url: item.route })
            }
          })
        })
      }
      .divider({
        strokeWidth: 1,
        color: 'rgba(255, 255, 255, 0.1)'
      })
    }
    .margin({ bottom: 20 })
  }

  /**
   * 页面主体构建函数
   * 构建整个设置页面的UI结构
   */
  build() {
    Stack() {
      Column() {
        // 背景渐变
        Column()
          .width('100%')
          .height('100%')
          .backgroundImage($r('app.media.background1'))
          .backgroundImageSize(ImageSize.Cover)
          .blur(3)
          .opacity(0.8)

        Column() {
          this.Header()

          Scroll() {
            Column() {
              // 账号设置分组
              this.SettingsSection('账号设置', [
                {
                  icon: '👤',
                  label: '个人信息',
                  type: 'link',
                  route: 'pages/ProfileEdit'
                } as SettingsItem,
                {
                  icon: '🔒',
                  label: '隐私设置',
                  type: 'link',
                  route: 'pages/Privacy'
                } as SettingsItem,
                {
                  icon: '🔔',
                  label: '通知设置',
                  type: 'link',
                  route: 'pages/Notifications'
                } as SettingsItem
              ])

              // 内容与隐私设置分组
              this.SettingsSection('内容与隐私', [
                {
                  icon: '💾',
                  label: '离线下载设置',
                  type: 'link',
                  route: 'pages/Download'
                } as SettingsItem,
                {
                  icon: '🌙',
                  label: '深色模式',
                  type: 'toggle',
                  state: this.darkMode,
                  onToggle: () => {
                    this.darkMode = !this.darkMode
                  }
                } as SettingsItem,
                {
                  icon: '📱',
                  label: '自动播放',
                  type: 'toggle',
                  state: this.autoPlay,
                  onToggle: () => {
                    this.autoPlay = !this.autoPlay
                  }
                } as SettingsItem
              ])

              // 关于设置分组
              this.SettingsSection('关于', [
                {
                  icon: '❓',
                  label: '帮助中心',
                  type: 'link',
                  route: 'pages/Help'
                } as SettingsItem,
                {
                  icon: '📄',
                  label: '用户协议',
                  type: 'link',
                  route: 'pages/Agreement'
                } as SettingsItem,
                {
                  icon: '🔒',
                  label: '隐私政策',
                  type: 'link',
                  route: 'pages/Privacy'
                } as SettingsItem
              ])

              // 退出登录按钮
              Button('退出登录')
                .width('90%')
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .backgroundColor('rgba(255, 0, 0, 0.2)')
                .fontColor('#FF5555')
                .margin(20)
                .onClick(() => {
                  // 处理退出登录
                })

              // 版本信息
              Text('版本 1.0.0 (build 100)')
                .fontSize(12)
                .opacity(0.5)
                .textAlign(TextAlign.Center)
                .margin(20)
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
    }
    .width('100%')
    .height('100%')
  }
}