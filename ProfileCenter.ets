/*
UserStats - 用户统计数据接口
Work - 作品信息接口
NavItem - 导航项接口
UserInfo - 用户信息接口
Header() - 页面头部构建器
ContentTabs() - 内容标签页构建器
ContentGrid() - 内容网格构建器
BottomNav() - 底部导航栏构建器
MenuItem() - 菜单项构建器
getTabName() - 获取标签页名称
build() - 页面主体构建函数
*/
import router from '@ohos.router';

interface UserStats {
  following: number, //关注数
  followers: number, //粉丝数
  likes: number // 点赞数
}

interface Work {
  id: number,// 作品ID
  image: string,// 作品图片URL
  likes: number // 作品点赞数
}

interface NavItem {
  icon: string, // 导航图标
  label: string,// 导航标签
  route: string,// 路由路径
  active?: boolean// 是否激活状态
}

interface UserInfo {
  avatar: Resource,
  nickname: string,
  bio: string,
  gender: string
}

interface RouteParams {
  userInfo?: UserInfo
}

type TabType = 'collections' | 'works' | 'likes' | 'history';

@Entry
@Component
struct Profile {
  @State username: string = '舞蹈小王子'
  @State followers: number = 12580
  @State following: number = 256
  @State likes: number = 125800
  @State userInfo: UserInfo = {
    avatar: $r('app.media.profile2'),
    nickname: '用户昵称',
    bio: '这是个人简介，分享你的生活态度和个性',
    gender: '保密'
  }

  @State currentTab: TabType = 'works'
  @State userStats: UserStats = { // 当前选中的内容标签
    following: 168,
    followers: 286,
    likes: 42
  }

  @State works: Work[] = [
    {
      id: 1,
      image: 'https://picsum.photos/200/200',
      likes: 42
    },
    {
      id: 2,
      image: 'https://picsum.photos/200/201',
      likes: 18
    }
  ]

  private readonly tabNames: Record<TabType, string> = {
    'collections': '收藏',
    'works': '作品',
    'likes': '喜欢',
    'history': '历史'
  }

  private readonly navItems: NavItem[] = [
    { icon: '🏠', label: '首页', route: 'Index', active: false },
    { icon: '🔍', label: '发现', route: 'Discover', active: false },
    { icon: '+', label: '创建', route: 'Create', active: false },
    { icon: '💬', label: '消息', route: 'Messages', active: false },
    { icon: '👤', label: '我', route: 'Profile', active: true }
  ]

  aboutToAppear() {
    console.info('Profile页面即将显示')
    // 获取路由参数
    const params = router.getParams() as RouteParams
    console.info('获取到的路由参数:', JSON.stringify(params))

    if (params?.userInfo) {
      console.info('更新用户信息')
      // 直接更新所有相关状态
      this.userInfo = params.userInfo
      this.username = params.userInfo.nickname
      // 保持其他统计数据不变
      console.info('用户信息已更新:', JSON.stringify(this.userInfo))
    }
  }

  // 构建顶部用户信息区
  @Builder Header() {
    Column() {
      Button() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .position({ x: 20, y: 20 })
      .onClick(() => {
        router.back()
      })

      Image(this.userInfo.avatar) // 用户头像
        .width(100)
        .height(100)
        .borderRadius(50)
        .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' }) // 圆形边框
        .margin({ top: 30, bottom: 15 })

      Text(this.userInfo.nickname)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })

      Text(this.userInfo.bio)
        .fontSize(14)
        .fontColor('rgba(255, 255, 255, 0.8)')
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      Row() {
        Column() {
          Text(this.userStats.following.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('关注')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .onClick(() => {
          // 处理关注点击
        })

        Column() {
          Text(this.userStats.followers.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('粉丝')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .margin({ left: 20, right: 20 })
        .onClick(() => {
          // 处理粉丝点击
        })

        Column() {
          Text(this.userStats.likes.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('获赞')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .onClick(() => {
          // 处理获赞点击
        })
      }
      .margin({ bottom: 20 })

      Button('编辑资料')
        .width(120)
        .height(36)
        .fontSize(14)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .borderRadius(18)
        .fontColor('#FFFFFF')
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfileEdit' })
        })
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor('transparent')
  }

  // 构建内容标签切换区
  @Builder ContentTabs() {
    Row() {
      ForEach(['collections', 'works', 'likes', 'history'] as TabType[], (tab: TabType) => {
        Text(this.tabNames[tab])
          .fontSize(16)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.7)')
          .padding({ top: 15, bottom: 15 })
          .borderWidth({ bottom: this.currentTab === tab ? 2 : 0 })
          .borderColor('#FF0050')
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

  // 构建作品网格布局
  @Builder ContentGrid() {
    Grid() {
      ForEach(this.works, (work: Work) => { // 网格项
        GridItem() {
          Stack() {
            Image(work.image)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
            Row() {
              Text('❤️')
                .fontSize(12)
              Text(work.likes.toString())
                .fontSize(12)
                .fontColor('#FFFFFF')
            }
            .position({ x: 5, y: '90%' })
          }
        }
        .aspectRatio(1)
      })
    }
    .columnsTemplate('1fr 1fr 1fr')  // 三列布局
    .columnsGap(2)
    .rowsGap(2)
    .padding(2)
  }

  // 构建底部导航栏
  @Builder BottomNav() {
    Row() {
      ForEach(this.navItems, (item: NavItem) => {
        Column() {  // 导航项
          Text(item.icon)  // 导航图标
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

  getTabName(tab: TabType): string {
    return this.tabNames[tab]
  }

  // 主构建函数
  build() {
    Stack() {
      Column() {
        this.Header() // 顶部用户信息
        this.ContentTabs() // 内容标签
        this.ContentGrid()  // 作品网格
        this.BottomNav() // 底部导航
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#121212')
    }
    .width('100%')
    .height('100%')
  }

  @Builder MenuItem(title: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 10 })
      Text(title)
        .fontSize(16)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .height(50)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#121212')
    .margin({ bottom: 1 })
  }
}