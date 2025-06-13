import router from '@ohos.router';
import { creators, Creator } from './creatorsData';

interface CategoryItem {
  key: string,
  label: string
}

@Entry
@Component
struct Creators {
  @State currentCategory: string = 'all'
  @State creatorsList: Creator[] = creators

  private categories: CategoryItem[] = [
    { key: 'all', label: '全部' },
    { key: 'music', label: '音乐' },
    { key: 'dance', label: '舞蹈' },
    { key: 'food', label: '美食' },
    { key: 'travel', label: '旅行' },
    { key: 'photography', label: '摄影' },
    { key: 'art', label: '艺术' }
  ]

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(24).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { router.back() })

      Text('热门创作者').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')

      Button() {
        Text('🔍').fontSize(24).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { /* 搜索功能 */ })
    }
    .width('100%').justifyContent(FlexAlign.SpaceBetween).padding(20)
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
            .onClick(() => { this.currentCategory = item.key })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }

  @Builder CreatorCard(creator: Creator) {
    Column() {
      Stack() {
        Image(creator.avatar).width('100%').height(180).borderRadius({ topLeft: 12, topRight: 12 }).objectFit(ImageFit.Cover)
        Column() {
          Row() {
            Image(creator.avatar).width(60).height(60).borderRadius(30).border({ width: 2, color: '#FFFFFF' })
            Column() {
              Text(creator.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
              Text(creator.description ?? '').fontSize(12).fontColor('#FFFFFF').opacity(0.8).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start).margin({ left: 10 })
          }
          .width('100%')
        }
        .width('100%').padding(15)
        .position({ y: '100%' }).translate({ y: -100 })
      }
      Column() {
        Row() {
          Text((creator.name)).fontSize(20).fontColor('#FFFFFF').opacity(0.8)
        }
        Row() {
          Text((creator.stats?.followers ?? '') + ' 粉丝').fontSize(14).fontColor('#FFFFFF').opacity(0.8)
          Button() {
            Text(creator.isFollowing ? '已关注' : '关注').fontColor(creator.isFollowing ? '#FFFFFF' : '#FF0050').fontSize(14)
          }
          .height(32)
          .backgroundColor(creator.isFollowing ? 'rgba(255,255,255,0.2)' : '#FFFFFF')
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .onClick(() => { creator.isFollowing = !creator.isFollowing })
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 10, bottom: 10 })
      }
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .backgroundColor('rgba(255,255,255,0.1)')
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({ url: 'pages/CreateProfile', params: { id: creator.id } })
    })
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        this.CategoryTabs()
        Grid() {
          ForEach(this.creatorsList.filter(creator => this.currentCategory === 'all' || creator.category === this.currentCategory), (creator: Creator) => {
            GridItem() { this.CreatorCard(creator) }.padding(8)
          })
        }
        .columnsTemplate('1fr 1fr').width('100%').layoutWeight(1).padding(8)
      }
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }
}