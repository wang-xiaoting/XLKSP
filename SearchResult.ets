import router from '@ohos.router';
import {
  trendingItems,
  creators,
  recommendedItems,
  TrendingItem,
  Creator,
  RecommendedItem
} from './discoverData';

// 定义搜索结果类
class SearchResults {
  trending: TrendingItem[] = [];
  creators: Creator[] = [];
  recommended: RecommendedItem[] = [];

  constructor(trending: TrendingItem[] = [], creators: Creator[] = [], recommended: RecommendedItem[] = []) {
    this.trending = trending;
    this.creators = creators;
    this.recommended = recommended;
  }
}

// 定义路由参数类
class SearchParams {
  searchText: string = '';
}

@Entry
@Component
struct SearchResult {
  @State searchText: string = ''
  @State searchResults: SearchResults = new SearchResults()

  aboutToAppear() {
    const params = router.getParams() as SearchParams
    if (params?.searchText) {
      this.searchText = params.searchText
      this.performSearch(this.searchText)
    }
  }

  private performSearch(text: string) {
    if (!text.trim()) {
      this.searchResults = new SearchResults()
      return
    }

    const searchLower = text.toLowerCase()
    this.searchResults = new SearchResults(
      trendingItems.filter(item => 
        item.title.toLowerCase().includes(searchLower)
      ),
      creators.filter(creator => 
        creator.name.toLowerCase().includes(searchLower)
      ),
      recommendedItems.filter(item => 
        item.title.toLowerCase().includes(searchLower) || 
        item.author.toLowerCase().includes(searchLower)
      )
    )
  }

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { router.back() })

      Text('搜索结果').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
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
      TextInput({ placeholder: '搜索音乐、视频或创作者', text: this.searchText })
        .backgroundColor('transparent')
        .placeholderColor('rgba(255, 255, 255, 0.7)')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .width('100%')
        .onChange((value: string) => {
          this.searchText = value
          this.performSearch(value)
        })
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .margin(15)
    .borderRadius(20)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
  }

  @Builder TrendingSection() {
    if (this.searchResults.trending.length > 0) {
      Column() {
        Text('视频').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          .margin({ bottom: 15 })

        Grid() {
          ForEach(this.searchResults.trending, (item: TrendingItem) => {
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
  }

  @Builder CreatorsSection() {
    if (this.searchResults.creators.length > 0) {
      Column() {
        Text('创作者').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          .margin({ bottom: 15 })

        Scroll() {
          Row({ space: 15 }) {
            ForEach(this.searchResults.creators, (creator: Creator) => {
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
  }

  @Builder RecommendedSection() {
    if (this.searchResults.recommended.length > 0) {
      Column() {
        Text('推荐').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          .margin({ bottom: 15 })

        Column() {
          ForEach(this.searchResults.recommended, (item: RecommendedItem) => {
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
            .onClick(() => {
              router.pushUrl({ url: 'pages/RecommendDetail', params: { item } })
            })
          })
        }
      }
      .padding(15)
    }
  }

  @Builder NoResults() {
    Column() {
      Text('没有找到相关内容')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
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
              if (this.searchResults.trending.length === 0 && 
                  this.searchResults.creators.length === 0 && 
                  this.searchResults.recommended.length === 0) {
                this.NoResults()
              } else {
                this.TrendingSection()
                this.CreatorsSection()
                this.RecommendedSection()
              }
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