import router from '@ohos.router';

interface UserInfo {
  avatar: Resource,
  nickname: string,
  bio: string,
  gender: string
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

  @State nickname: string = this.userInfo.nickname
  @State bio: string = this.userInfo.bio
  @State gender: string = this.userInfo.gender

  // 构建顶部导航栏
  @Builder Header() {
    Row() {
      Button() {
        Text('取消')  // 返回按钮
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
        Text('保存')
          .fontColor('#FF0050')
          .fontSize(16)
      }
      .backgroundColor('transparent')
      .width(60)
      .height(40)
      .onClick(() => {
        console.info('保存按钮被点击')
        // 更新 userInfo
        this.userInfo.nickname = this.nickname
        this.userInfo.bio = this.bio
        this.userInfo.gender = this.gender
        console.info('用户信息已更新:', JSON.stringify(this.userInfo))

        // 使用 pushUrl 替代 back
        try {
          router.pushUrl({ // 带参数返回个人中心
            url: 'pages/Profile',
            params: {
              userInfo: this.userInfo
            }
          })
          console.info('路由跳转已执行')
        } catch (error) {
          console.error('路由跳转失败:', error)
        }
      })
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#000000')
  }

  // 主构建函数
  build() {
    Column() {
      this.Header()// 顶部导航

      Scroll() {  // 可滚动内容区
        Column() {
          // 头像设置
          Column() {
            Image(this.userInfo.avatar)
              .width(100)
              .height(100)
              .borderRadius(50)
              .margin({ top: 20, bottom: 10 })

            Text('点击更换头像')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.6)')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            // 处理头像更新
          })

          // 基本信息
          List() {  // 表单列表
            ListItem() {
              Row() {
                Text('昵称')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                TextInput({ text: this.nickname })
                  .backgroundColor('transparent')
                  .textAlign(TextAlign.End)
                  .fontColor('#FFFFFF')
                  .onChange((value: string) => {
                    this.nickname = value
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(15)
            }

            ListItem() {
              Row() {
                Text('简介')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                TextInput({ text: this.bio })
                  .backgroundColor('transparent')
                  .textAlign(TextAlign.End)
                  .fontColor('#FFFFFF')
                  .onChange((value: string) => {
                    this.bio = value
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(15)
            }

            ListItem() {
              Row() {
                Text('性别')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                Text(this.gender)
                  .fontSize(16)
                  .fontColor('rgba(255, 255, 255, 0.6)')
                  .onClick(() => {
                    this.gender = this.gender === '保密' ? '男' :
                      this.gender === '男' ? '女' : '保密'
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}