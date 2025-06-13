import router from '@ohos.router';
import { trendingItems, TrendingItem } from './discoverData';

@Entry
@Component
struct TrendingAll {
  @State trendingList: TrendingItem[] = trendingItems

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { router.back() })

      Text('全部流行内容').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Blank()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding(20)
    .borderColor('rgba(255, 255, 255, 0.1)')
    .borderWidth({ bottom: 1 })
  }

  @Builder TrendingGrid() {
    Grid() {
      ForEach(this.trendingList, (item: TrendingItem) => {
        GridItem() {
          Column() {
            Stack() {
              Image(item.image)
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 6 })
                Text(item.plays + '次播放')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .opacity(0.85)
              }
              .width('100%')
              .padding({ left: 12, right: 12, bottom: 14, top: 10 })
              .position({ y: '100%' })
            }
            .width('100%').height(160)

            // 你可以在这里添加点击事件跳转到具体视频页面
          }
          .backgroundColor('rgba(255,255,255,0.04)')
          .borderRadius(12)
          .margin({ bottom: 16, right: 10, left: 0 })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(16)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  build() {
    Column() {
      this.Header()
      Scroll() {
        this.TrendingGrid()
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121212')
  }
}