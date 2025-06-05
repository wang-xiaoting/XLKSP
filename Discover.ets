import router from '@ohos.router';

interface TrendingItem {
  id: number,
  image: Resource,
  title: string,
  plays: string
}

interface Creator {
  id: number,
  avatar: Resource,
  name: string
}

interface RecommendedItem {
  id: number,
  thumbnail: Resource,
  title: string,
  author: string,
  plays: string
}

interface CategoryItem {
  key: string,
  label: string
}

@Entry
@Component
struct Discover {
  @State currentCategory: string = 'recommended'
  @State searchText: string = '' // 搜索框文本

  @State trendingItems: TrendingItem[] = [
    {
      id: 1,
      image: $r('app.media.background1'),
      title: '热门街舞视频',
      plays: '10.2万'
    },
    {
      id: 2,
      image: $r('app.media.thumbnail_cover1'),
      title: '热门音乐榜单',
      plays: '5.7万'
    }
  ]

  @State creators: Creator[] = [
    {
      id: 1,
      avatar: $r('app.media.profile1'),
      name: '舞蹈达人'
    },
    {
      id: 2,
      avatar: $r('app.media.profile2'),
      name: '音乐制作人'
    },
    {
      id: 3,
      avatar: $r('app.media.cover2'),
      name: '旅行达人'
    },
    {
      id: 4,
      avatar: $r('app.media.cover1'),
      name: '美食博主'
    }
  ]

  @State recommendedItems: RecommendedItem[] = [
    {
      id: 1,
      thumbnail: $r('app.media.background1'),
      title: '精选舞蹈教学：从零开始学习街舞基础动作',
      author: '舞蹈达人',
      plays: '2.3万'
    },
    {
      id: 2,
      thumbnail: $r('app.media.thumbnail_cover1'),
      title: '轻音乐合集：助你放松心情，提高工作效率',
      author: '音乐制作人',
      plays: '1.8万'
    },
    {
      id: 3,
      thumbnail: $r('app.media.thumbnail_cover2'),
      title: '城市日落时分：捕捉美丽光影的摄影技巧',
      author: '摄影师小王',
      plays: '1.5万'
    },
    {
      id: 4,
      thumbnail: $r('app.media.profile2'),
      title: '家常菜教程：简单易学的快手菜制作方法',
      author: '美食博主',
      plays: '3.2万'
    }
  ]

  private categories: CategoryItem[] = [
    { key: 'recommended', label: '推荐' },
    { key: 'hot', label: '热门' },
    { key: 'music', label: '音乐' },
    { key: 'dance', label: '舞蹈' },
    { key: 'game', label: '游戏' },
    { key: 'food', label: '美食' },
    { key: 'travel', label: '旅行' }
  ]

  @Builder Header() {
    Row() {
      Button() {
        Text('←')
          .fontSize(20)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => {
        router.back()
      })

      Text('发现')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding(20)
    .borderColor('rgba(255, 255, 255, 0.1)')
    .borderWidth({ bottom: 1 })
  }

  @Builder SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .opacity(0.7)
        .margin({ right: 10 })

      TextInput({ placeholder: '搜索音乐、视频或创作者' })
        .backgroundColor('transparent')
        .placeholderColor('rgba(255, 255, 255, 0.7)')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .width('100%')
        .onChange((value: string) => {
          this.searchText = value
        })
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .margin(15)
    .borderRadius(20)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
  }

  @Builder CategoryTabs() {
    Scroll() {
      Row({ space: 15 }) {
        ForEach(this.categories, (item: CategoryItem) => {
          Text(item.label)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor(this.currentCategory === item.key ? '#FF0050' : 'rgba(255, 255, 255, 0.1)')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.currentCategory = item.key
            })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }

  @Builder TrendingSection() {
    Column() {
      Row() {
        Text('正在流行')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('查看全部')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/TrendingAll' })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Grid() {
        ForEach(this.trendingItems, (item: TrendingItem) => {
          GridItem() {
            Stack() {
              Image(item.image)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .opacity(0.8)

              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(item.plays + '次播放')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
              }
              .width('100%')
              .padding(15)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.End)
              .backgroundImage($r('app.media.gradient'))
              .backgroundImageSize(ImageSize.Cover)
            }
            .width('100%')
            .height(180)
            .borderRadius(12)
          }
        })
      }
      .columnsTemplate('1fr 1fr') // 双列布局
      .columnsGap(10)
      .rowsGap(10)
    }
    .padding(15)
  }

  @Builder CreatorsSection() {
    Column() {
      Row() {
        Text('热门创作者')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('查看全部')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Creators' })
          })
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/CreateProfile' })
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Scroll() {
        Row({ space: 15 }) {
          ForEach(this.creators, (creator: Creator) => {
            Column({ space: 8 }) {
              Image(creator.avatar)
                .width(60)
                .height(60)
                .borderRadius(30)

              Text(creator.name)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(70)
                .textAlign(TextAlign.Center)
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/CreatorProfile',
                params: { id: creator.id }
              })
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
    }
    .padding(15)
  }

  @Builder RecommendedSection() {
    Column() {
      Row() {
        Text('为你推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('刷新')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .onClick(() => {
            // 刷新推荐内容
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      List() {
        ForEach(this.recommendedItems, (item: RecommendedItem) => {
          ListItem() {
            Row() {
              Image(item.thumbnail)
                .width(120)
                .height(70)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)

              Column() {
                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 5 })

                Text(item.author + ' · ' + item.plays + '次播放')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
              }
              .layoutWeight(1)
              .margin({ left: 15 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
          }
          .margin({ bottom: 15 })
        })
      }
      .width('100%')
    }
    .padding(15)
  }

  build() {
    Stack() {
      Column() {
        // 背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#121212')
          .position({ x: 0, y: 0 })

        // 内容
        Column() {
          this.Header() // 顶部导航
          this.SearchBar()  // 搜索栏
          this.CategoryTabs()

          Scroll() {  // 搜索栏
            Column() {
              this.TrendingSection()
              this.CreatorsSection()
              this.RecommendedSection()  // 推荐内容
            }
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}