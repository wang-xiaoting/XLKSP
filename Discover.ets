import router from '@ohos.router';
import {
  trendingItems,
  creators,
  recommendedItems,
  categories,
  TrendingItem,
  Creator,
  RecommendedItem,
  CategoryItem
} from './discoverData';

@Entry
@Component
struct Discover {
  @State currentCategory: string = 'recommended'
  @State searchText: string = ''

  @State trendingItems: TrendingItem[] = trendingItems
  @State creators: Creator[] = creators
  @State recommendedItems: RecommendedItem[] = recommendedItems

  @State recommendStartIndex: number = 0

  private categories: CategoryItem[] = categories

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { router.back() })

      Text('发现').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
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
      Text('🔍').fontSize(16).opacity(0.7).margin({ right: 10 })
      TextInput({ placeholder: '搜索音乐、视频或创作者' })
        .backgroundColor('transparent')
        .placeholderColor('rgba(255, 255, 255, 0.7)')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .width('100%')
        .onChange((value: string) => { 
          this.searchText = value
          if (value.trim()) {
            router.pushUrl({ url: 'pages/SearchResult', params: { searchText: value } })
          }
        })
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .margin(15)
    .borderRadius(20)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
  }

  @Builder TrendingSection() {
    Column() {
      Row() {
        Text('正在流行').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('查看全部')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .onClick(() => { router.pushUrl({ url: 'pages/TrendingAll' }) })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Grid() {
        ForEach(this.trendingItems.slice(0, 2), (item: TrendingItem) => {
          GridItem() {
            Stack() {
              Image(item.image).width('100%').height('100%').objectFit(ImageFit.Cover).opacity(0.8)
              Column() {
                Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                Text(item.plays + '次播放').fontSize(12).fontColor('#FFFFFF').opacity(0.8)
              }
              .width('100%').padding(15).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.End)
            }
            .width('100%').height(180).borderRadius(12)
          }
        })
      }
      .columnsTemplate('1fr 1fr').columnsGap(10).rowsGap(10)
    }
    .padding(15)
  }

  @Builder CreatorsSection() {
    Column() {
      Row() {
        Text('热门创作者').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('查看全部').fontSize(14).fontColor('#FFFFFF').opacity(0.8)
          .onClick(() => { router.pushUrl({ url: 'pages/creators' }) })
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 15 })

      Scroll() {
        Row({ space: 15 }) {
          ForEach(this.creators, (creator: Creator) => {
            Column({ space: 8 }) {
              Image(creator.avatar).width(60).height(60).borderRadius(30)
              Text(creator.name)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(70)
                .textAlign(TextAlign.Center)
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/CreateProfile', params: { id: creator.id } })
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
    }
    .padding(15)
  }

  // 推荐区只显示4条，刷新时切换
  @Builder RecommendedSection() {
    Column() {
      Row() {
        Text('为你推荐').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('刷新')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .onClick(() => {
            const total = this.recommendedItems.length
            if (this.recommendStartIndex + 4 >= total) {
              this.recommendStartIndex = 0
            } else {
              this.recommendStartIndex += 4
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Column() {
        ForEach(this.getRecommendedList(), (item: RecommendedItem) => {
          Row() {
            Image(item.thumbnail).width(100).height(60).borderRadius(8).objectFit(ImageFit.Cover)
            Column() {
              Text(item.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 5 })
              Text(item.author + ' · ' + item.plays + '次播放').fontSize(12).fontColor('#FFFFFF').opacity(0.8)
            }
            .layoutWeight(1).margin({ left: 15 }).alignItems(HorizontalAlign.Start)
          }
          .width('100%').margin({ bottom: 15 })
          // 点击每条推荐跳转到详情页
          .onClick(() => {
            router.pushUrl({ url: 'pages/RecommendDetail', params: { item } })
          })
        })
      }
    }
    .padding(15)
  }

  // 推荐区处理函数，始终返回4条
  getRecommendedList(): Array<RecommendedItem> {
    let total = this.recommendedItems.length
    let start = this.recommendStartIndex
    let end = start + 4 > total ? total : start + 4
    let showList: Array<RecommendedItem> = []
    if (end - start < 4) {
      showList = this.recommendedItems.slice(start, end).concat(
        this.recommendedItems.slice(0, 4 - (end - start))
      )
    } else {
      showList = this.recommendedItems.slice(start, end)
    }
    return showList
  }

  build() {
    Stack() {
      Column() {
        Column().width('100%').height('100%').backgroundColor('#121212').position({ x: 0, y: 0 })
        Column() {
          this.Header()
          this.SearchBar()
          Scroll() {
            Column() {
              this.TrendingSection()
              this.CreatorsSection()
              this.RecommendedSection()
            }
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }
}