import router from '@ohos.router';
import picker from '@ohos.file.picker';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';

interface UserInfo {
  avatar: Resource | string,
  nickname: string,
  bio: string,
  gender: string
}

interface RouteParams {
  userInfo?: UserInfo
}

@Entry
@Component
struct ProfileEdit {
  @State userInfo: UserInfo = {
    avatar: $r('app.media.profile2'),
    nickname: '用户昵称',
    bio: '这是个人简介，分享你的生活态度和个性',
    gender: '保密'
  }

  @State nickname: string = ''
  @State bio: string = ''
  @State gender: string = ''
  @State avatarPath: string = ''

  @State isSaving: boolean = false;
  @State isImageLoading: boolean = false;
  @State showGenderPicker: boolean = false;
  @State genderOptions: string[] = ['保密', '男', '女'];

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouteParams
    console.info('获取到的路由参数:', JSON.stringify(params))

    if (params?.userInfo) {
      this.userInfo = params.userInfo
      this.nickname = params.userInfo.nickname
      this.bio = params.userInfo.bio
      this.gender = params.userInfo.gender
      if (typeof params.userInfo.avatar === 'string') {
        this.avatarPath = params.userInfo.avatar
      }
      console.info('用户信息已更新:', JSON.stringify(this.userInfo))
    }
  }

  // 选择图片
  async selectImage() {
    try {
      this.isImageLoading = true;
      let photoPicker = new picker.PhotoViewPicker();
      let result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result && result.photoUris && result.photoUris.length > 0) {
        const selectedImageUri = result.photoUris[0];
        console.info('选择的图片路径:', selectedImageUri);
        this.avatarPath = selectedImageUri;
        this.userInfo.avatar = selectedImageUri;
      }
    } catch (err) {
      console.error('选择图片失败:', err);
      promptAction.showToast({ message: '选择图片失败，请重试' });
    } finally {
      this.isImageLoading = false;
    }
  }

  // 优化数据验证
  private validateInput(): boolean {
    if (!this.nickname.trim()) {
      promptAction.showToast({ message: '昵称不能为空' });
      return false;
    }
    if (this.nickname.length > 20) {
      promptAction.showToast({ message: '昵称不能超过20个字符' });
      return false;
    }
    if (this.bio.length > 100) {
      promptAction.showToast({ message: '简介不能超过100个字符' });
      return false;
    }
    return true;
  }

  // 优化保存功能
  private async saveUserInfo() {
    if (!this.validateInput()) {
      return;
    }

    this.isSaving = true;
    try {
      const updatedUserInfo: UserInfo = {
        avatar: this.avatarPath || this.userInfo.avatar,
        nickname: this.nickname.trim(),
        bio: this.bio.trim(),
        gender: this.gender
      };

      // 保存到本地存储
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, 'userInfoPrefs');
      await prefs.put('userInfo', JSON.stringify(updatedUserInfo));
      await prefs.flush();

      // 返回上一页并传递更新后的用户信息
      router.replaceUrl({
        url: 'pages/ProfileCenter',
        params: {
          userInfo: updatedUserInfo
        }
      });
      promptAction.showToast({ message: '保存成功' });
    } catch (error) {
      console.error('保存失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isSaving = false;
    }
  }

  @Builder Header() {
    Row() {
      Button() {
        Text('取消')
          .fontColor('#FFFFFF')
          .fontSize(16)
      }
      .backgroundColor('transparent')
      .width(60)
      .height(40)
      .onClick(() => {
        router.back()
      })

      Text('编辑资料')
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
        this.saveUserInfo();
      })
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#000000')
  }

  build() {
    Column() {
      this.Header()

      // 新增设置入口（跳转到setting页面）
      Button('设置')
        .width('90%')
        .height(40)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#222222')
        .borderRadius(20)
        .margin({ top: 20, bottom: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/setting', params: { showPrivacy: true } });
        })

      Scroll() {
        Column() {
          // 头像设置
          Column() {
            Stack() {
              Image(this.avatarPath ? this.avatarPath : this.userInfo.avatar)
                .width(100)
                .height(100)
                .borderRadius(50)
                .margin({ top: 20, bottom: 10 })

              if (this.isImageLoading) {
                LoadingProgress()
                  .width(30)
                  .height(30)
                  .color('#FFFFFF')
                  .position({ x: '50%', y: '50%' })
              }
            }

            Text('点击更换头像')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.6)')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectImage()
          })

          // 基本信息
          List() {
            ListItem() {
              Column() {
                Text('昵称')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 6 })
                TextInput({ text: this.nickname, placeholder: '请输入昵称' })
                  .backgroundColor('transparent')
                  .textAlign(TextAlign.Start)
                  .fontColor('#FFFFFF')
                  .fontSize(16)
                  .maxLength(20)
                  .onChange((value: string) => {
                    this.nickname = value
                  })
                  .borderWidth(0)
                  .padding({ bottom: 6 })
                Blank().height(1).backgroundColor(this.nickname ? '#FF0050' : 'rgba(255,255,255,0.2)')
              }
              .width('100%')
              .padding({ left: 15, right: 15, top: 10, bottom: 10 })
            }

            ListItem() {
              Column() {
                Text('个人简介')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 6 })
                TextInput({ text: this.bio, placeholder: '填写你的个性签名，最多100字' })
                  .backgroundColor('transparent')
                  .textAlign(TextAlign.Start)
                  .fontColor('#FFFFFF')
                  .fontSize(16)
                  .maxLength(100)
                  .height(80)
                  .onChange((value: string) => {
                    this.bio = value
                  })
                  .borderWidth(0)
                  .padding({ bottom: 6 })
                Blank().height(1).backgroundColor(this.bio ? '#FF0050' : 'rgba(255,255,255,0.2)')
              }
              .width('100%')
              .padding({ left: 15, right: 15, top: 10, bottom: 10 })
            }

            ListItem() {
              Row() {
                Text('性别')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                Row() {
                  Text(this.gender)
                    .fontSize(16)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                  Image($r('app.media.sex'))
                    .width(16)
                    .height(16)
                    .margin({ left: 8 })
                }
                .onClick(() => {
                  this.showGenderPicker = true;
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(15)
            }
          }
          .divider({
            strokeWidth: 1,
            color: 'rgba(255, 255, 255, 0.1)'
          })
          .margin({ top: 20 })
        }
      }
      .layoutWeight(1)

      // 性别选择器
      if (this.showGenderPicker) {
        Column() {
          ForEach(this.genderOptions, (option: string) => {
            Text(option)
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .backgroundColor(option === this.gender ? 'rgba(255, 0, 80, 0.1)' : 'transparent')
              .onClick(() => {
                this.gender = option;
                this.showGenderPicker = false;
              })
          })
        }
        .width('100%')
        .backgroundColor('#1A1A1A')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}