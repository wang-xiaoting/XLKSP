import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

/**
 * 隐私设置接口
 * 定义用户的隐私设置选项
 */
interface PrivacySettings {
  profileVisibility: boolean;
  showLikes: boolean;
  showCollections: boolean;
  showHistory: boolean;
  allowTagging: boolean;
  allowComments: boolean;
  allowMessages: boolean;
}

/**
 * 隐私设置页面组件
 * 用于管理用户的隐私设置
 */
@Entry
@Component
struct Privacy {
  @State settings: PrivacySettings = {
    profileVisibility: true,
    showLikes: true,
    showCollections: true,
    showHistory: true,
    allowTagging: true,
    allowComments: true,
    allowMessages: true
  }

  @State isSaving: boolean = false;
  private readonly STORE_NAME: string = 'privacySettings';
  private readonly SETTINGS_KEY: string = 'settings';

  aboutToAppear() {
    this.loadSettings();
  }

  async loadSettings() {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, this.STORE_NAME);
      const settingsStr = await prefs.get(this.SETTINGS_KEY, '') as string;
      if (settingsStr) {
        const loaded: PrivacySettings = JSON.parse(settingsStr);
        this.settings = loaded;
      }
      console.info('已加载隐私设置:', JSON.stringify(this.settings));
    } catch (err) {
      console.error('加载隐私设置失败:', err);
      promptAction.showToast({ message: '加载设置失败' });
    }
  }

  async saveSettings() {
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, this.STORE_NAME);
      await prefs.put(this.SETTINGS_KEY, JSON.stringify(this.settings));
      await prefs.flush();
      console.info('隐私设置已保存:', JSON.stringify(this.settings));
      promptAction.showToast({ message: '保存成功' });
      router.back();
    } catch (error) {
      console.error('保存隐私设置失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isSaving = false;
    }
  }

  private updateSetting(type: string, value: boolean) {
    // ArkTS 不支持对象扩展，手动拷贝
    const newSettings: PrivacySettings = {
      profileVisibility: this.settings.profileVisibility,
      showLikes: this.settings.showLikes,
      showCollections: this.settings.showCollections,
      showHistory: this.settings.showHistory,
      allowTagging: this.settings.allowTagging,
      allowComments: this.settings.allowComments,
      allowMessages: this.settings.allowMessages
    };
    switch (type) {
      case 'profileVisibility':
        newSettings.profileVisibility = value;
        break;
      case 'showLikes':
        newSettings.showLikes = value;
        break;
      case 'showCollections':
        newSettings.showCollections = value;
        break;
      case 'showHistory':
        newSettings.showHistory = value;
        break;
      case 'allowTagging':
        newSettings.allowTagging = value;
        break;
      case 'allowComments':
        newSettings.allowComments = value;
        break;
      case 'allowMessages':
        newSettings.allowMessages = value;
        break;
    }
    this.settings = newSettings;
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

      Button() {
        if (this.isSaving) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#FFFFFF')
        } else {
          Text('保存')
            .fontColor('#FFFFFF')
            .fontSize(16)
        }
      }
      .backgroundColor('#FF0050')
      .width(60)
      .height(40)
      .borderRadius(20)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.saveSettings();
      })
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#000000')
  }

  @Builder SettingItem(title: string, description: string, type: string, value: boolean) {
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

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor('#FF0050')
        .onChange((isOn: boolean) => {
          this.updateSetting(type, isOn);
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#1A1A1A')
    .borderRadius(8)
    .margin({ bottom: 10 })
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
          Text('账号隐私')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 20, bottom: 10, left: 15 })

          this.SettingItem(
            '公开个人主页',
            '允许其他用户查看你的个人主页',
            'profileVisibility',
            this.settings.profileVisibility
          )

          this.SettingItem(
            '显示点赞内容',
            '允许其他用户查看你点赞的内容',
            'showLikes',
            this.settings.showLikes
          )

          this.SettingItem(
            '显示收藏内容',
            '允许其他用户查看你收藏的内容',
            'showCollections',
            this.settings.showCollections
          )

          this.SettingItem(
            '显示观看历史',
            '允许其他用户查看你的观看历史',
            'showHistory',
            this.settings.showHistory
          )

          Text('互动隐私')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 20, bottom: 10, left: 15 })

          this.SettingItem(
            '允许标记',
            '允许其他用户在视频中标记你',
            'allowTagging',
            this.settings.allowTagging
          )

          this.SettingItem(
            '允许评论',
            '允许其他用户评论你的内容',
            'allowComments',
            this.settings.allowComments
          )

          this.SettingItem(
            '允许私信',
            '允许其他用户向你发送私信',
            'allowMessages',
            this.settings.allowMessages
          )
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