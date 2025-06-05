import router from '@ohos.router';

/**
 * 隐私设置接口
 * 定义用户的隐私设置选项
 */
interface PrivacySettings {
  accountPrivate: boolean,      // 是否私密账号
  showActivity: boolean,        // 是否显示活动状态
  allowDirectMessage: boolean,  // 是否允许私信
  showLikes: boolean           // 是否显示喜欢
}

/**
 * 隐私设置项接口
 * 定义单个隐私设置项的结构
 */
interface PrivacyItem {
  label: string,       // 设置项标题
  description: string, // 设置项描述
  state: boolean,      // 设置项状态
  onChange: () => void // 状态改变回调
}

/**
 * 隐私设置分组接口
 * 定义隐私设置的分组结构
 */
interface PrivacySection {
  title: string,           // 分组标题
  items: PrivacyItem[]     // 分组内的设置项
}

/**
 * 隐私设置页面组件
 * 用于管理用户的隐私设置
 */
@Entry
@Component
struct Privacy {
  @State privacySettings: PrivacySettings = {
    accountPrivate: false,
    showActivity: true,
    allowDirectMessage: true,
    showLikes: true
  }

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

      Text('隐私设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 隐私设置分组构建器
   * 构建一个隐私设置分组，包含标题和设置项列表
   * @param section 隐私设置分组数据
   */
  @Builder PrivacySection(section: PrivacySection) {
    Column() {
      Text(section.title)
        .fontSize(14)
        .opacity(0.7)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .width('100%')
        .padding(15)

      List() {
        ForEach(section.items, (item: PrivacyItem) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.label)
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                Text(item.description)
                  .fontSize(12)
                  .fontColor('rgba(255, 255, 255, 0.6)')
                  .margin({ top: 5 })
              }
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: item.state })
                .selectedColor('#FF0050')
                .switchPointColor('#FFFFFF')
                .onChange(item.onChange)
            }
            .width('100%')
            .padding(15)
          }
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
   * 构建整个隐私设置页面的UI结构
   */
  build() {
    Column() {
      this.Header()

      Scroll() {
        Column() {
          // 账号隐私设置分组
          this.PrivacySection({
            title: '账号隐私',
            items: [
              {
                label: '私密账号',
                description: '开启后，只有关注你的人才能看到你的内容',
                state: this.privacySettings.accountPrivate,
                onChange: () => {
                  this.privacySettings.accountPrivate = !this.privacySettings.accountPrivate
                }
              },
              {
                label: '显示活动状态',
                description: '让其他人看到你的在线状态',
                state: this.privacySettings.showActivity,
                onChange: () => {
                  this.privacySettings.showActivity = !this.privacySettings.showActivity
                }
              }
            ]
          })

          // 互动设置分组
          this.PrivacySection({
            title: '互动设置',
            items: [
              {
                label: '允许私信',
                description: '是否允许其他用户向你发送私信',
                state: this.privacySettings.allowDirectMessage,
                onChange: () => {
                  this.privacySettings.allowDirectMessage = !this.privacySettings.allowDirectMessage
                }
              },
              {
                label: '显示喜欢',
                description: '让其他人看到你喜欢的内容',
                state: this.privacySettings.showLikes,
                onChange: () => {
                  this.privacySettings.showLikes = !this.privacySettings.showLikes
                }
              }
            ]
          })

          // 清除浏览记录按钮
          Button('清除浏览记录')
            .width('90%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('rgba(255, 0, 0, 0.2)')
            .fontColor('#FF5555')
            .margin(20)
            .onClick(() => {
              // 处理清除浏览记录
            })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}