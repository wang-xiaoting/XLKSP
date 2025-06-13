import router from '@ohos.router';

interface CreatorStats {
  following: number,
  followers: string,
  likes: string
}

interface Creator {
  name: string,
  username: string,
  avatar: Resource,
  banner: Resource,
  bio: string,
  stats: CreatorStats
}

interface Video {
  id: number,
  thumbnail: Resource,
  views: string
}

enum TabType {
  VIDEOS = 'videos',
  LIKES = 'likes',
  FAVORITES = 'favorites'
}

interface NavItem {
  icon: string,
  label: string,
  route: string,
  active?: boolean
}

@Entry
@Component
struct CreatorProfile {
  @State currentTab: TabType = TabType.VIDEOS
  @State isFollowing: boolean = false
  @State isProfileCollapsed: boolean = false
  @State creator: Creator = {
    name: '橘子皮',
    username: '@Hhao2071879147',
    avatar: $r("app.media.wudaodaren"),
    banner: $r('app.media.background1'),
    bio: '谁给我做局了',
    stats: {
      following: 188,
      followers: '62',
      likes: '5240'
    }
  }

  @State videos: Video[] = [
    {
      id: 1,
      thumbnail: $r('app.media.thumbnail_cover1'),
      views: '123.5万'
    },
    {
      id: 2,
      thumbnail: $r('app.media.thumbnail_cover2'),
      views: '89.2万'
    }
  ]

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

      Text('创作者主页')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Button() {
        Text('⋯')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
    }
    .width('100%')
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('rgba(0, 0, 0, 0.8)')
  }

  @Builder ProfileInfo() {
    Column() {
      Stack() {
        Image(this.creator.banner)
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .brightness(0.7)

        Image(this.creator.avatar)
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: '#000000' })
          .position({ y: 120 })
      }

      Column() {
        Text(this.creator.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 50, bottom: 5 })

        Text(this.creator.username)
          .fontSize(14)
          .fontColor('rgba(255, 255, 255, 0.6)')
          .margin({ bottom: 15 })

        if (!this.isProfileCollapsed) {
          Row() {
            Column() {
              Text(this.creator.stats.following.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('关注')
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.6)')
            }

            Column() {
              Text(this.creator.stats.followers)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('粉丝')
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.6)')
            }
            .margin({ left: 30, right: 30 })

            Column() {
              Text(this.creator.stats.likes)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('获赞')
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.6)')
            }
          }
          .margin({ bottom: 20 })

          Text(this.creator.bio)
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })
            .padding({ left: 20, right: 20 })

          Row() {
            Button() {
              Text(this.isFollowing ? '已关注' : '关注')
                .fontColor(this.isFollowing ? '#FFFFFF' : '#FFFFFF')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .width(120)
            .height(36)
            .backgroundColor(this.isFollowing ? 'transparent' : '#FF0050')
            .border({
              width: this.isFollowing ? 1 : 0,
              color: 'rgba(255, 255, 255, 0.3)'
            })
            .borderRadius(4)
            .onClick(() => {
              this.isFollowing = !this.isFollowing
            })

            Button() {
              Text('私信')
                .fontColor('#FFFFFF')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .width(120)
            .height(36)
            .backgroundColor('transparent')
            .border({
              width: 1,
              color: 'rgba(255, 255, 255, 0.3)'
            })
            .borderRadius(4)
            .margin({ left: 15 })
          }
        }
      }
      .width('100%')
      .backgroundColor('#000000')

      Button() {
        Text(this.isProfileCollapsed ? '展开 ▼' : '收起 ▲')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('rgba(255, 255, 255, 0.2)')
      .borderRadius(20)
      .padding({ left: 15, right: 15, top: 5, bottom: 5 })
      .margin({ bottom: 5 })
      .onClick(() => {
        this.isProfileCollapsed = !this.isProfileCollapsed
      })
    }
  }

  @Builder ContentTabs() {
    Row() {
      ForEach([TabType.VIDEOS, TabType.LIKES, TabType.FAVORITES], (tab: TabType) => {
        Text(this.getTabName(tab))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.6)')
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

  @Builder VideoGrid() {
    Grid() {
      ForEach(this.videos, (video: Video) => {
        GridItem() {
          Stack() {
            Image(video.thumbnail)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)

            Text('▶')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .position({ x: '50%', y: '50%' })
              .translate({ x: -12, y: -12 })

            Row() {
              Text('👁️')
                .fontSize(12)
              Text(video.views)
                .fontSize(12)
                .fontColor('#FFFFFF')
            }
            .position({ x: 10, y: '90%' })
          }
        }
        .aspectRatio(3/4)
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(2)
    .columnsGap(2)
    .margin(2)
    .layoutWeight(1)
  }

  @Builder BottomNav() {
    Row() {
      ForEach([
        { icon: '🏠', label: '首页', route: 'Index', active: false },
        { icon: '🔍', label: '发现', route: 'Discover', active: true },
        { icon: '+', label: '创建', route: 'Create', active: false },
        { icon: '💬', label: '消息', route: 'Messages', active: false },
        { icon: '👤', label: '我', route: 'Profile', active: false }
      ] as NavItem[], (item: NavItem) => {
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

  getTabName(tab: TabType): string {
    switch (tab) {
      case TabType.VIDEOS:
        return '作品'
      case TabType.LIKES:
        return '喜欢'
      case TabType.FAVORITES:
        return '收藏'
      default:
        return ''
    }
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        this.ProfileInfo()
        this.ContentTabs()
        this.VideoGrid()
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