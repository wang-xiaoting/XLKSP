import router from '@ohos.router';
import { RecommendedItem } from './discoverData';

interface RecommendDetailParams {
  item: RecommendedItem
}

// 各分类标签和简介用变量与switch实现
const CATEGORY_TAGS_DANCE = ['入门', '基础动作', '节奏感', '热门'];
const CATEGORY_TAGS_MUSIC = ['放松', '高效', '心情', '创作'];
const CATEGORY_TAGS_PHOTOGRAPHY = ['光影', '技巧', '城市', '旅拍'];
const CATEGORY_TAGS_FOOD = ['家常菜', '简单易学', '快手菜'];
const CATEGORY_TAGS_ART = ['插画', '二次元', '临摹'];
const CATEGORY_TAGS_GAME = ['MOBA', '上分', '团队'];
const CATEGORY_TAGS_FITNESS = ['居家', '健身', '饮食'];

const DEMO_DESCRIPTION_DANCE = '本教程适合零基础学员，从基本律动到简单街舞动作分解，逐步提升节奏感和身体协调性。课程配有详细分解及动图演示，适合自学与兴趣培养。';
const DEMO_DESCRIPTION_MUSIC = '精心挑选轻音乐合集，帮助你在工作和学习中快速放松，提升专注力。适合背景音乐或者冥想使用。';
const DEMO_DESCRIPTION_PHOTOGRAPHY = '教你如何在城市中捕捉日落美景，利用光影变化拍出高级感照片，提升你的摄影水平。';
const DEMO_DESCRIPTION_FOOD = '精选家常快手菜做法，食材简单，步骤易操作，哪怕零厨艺也能轻松做美味。';
const DEMO_DESCRIPTION_ART = '带你从零学习二次元插画临摹，掌握人物结构、色彩搭配等核心技巧。';
const DEMO_DESCRIPTION_GAME = 'MOBA上分秘籍，详细讲解团队协作、细节处理与英雄选择，助你轻松超神。';
const DEMO_DESCRIPTION_FITNESS = '不用去健身房，居家也能高效锻炼，配合科学饮食建议，健康生活每一天。';

@Entry
@Component
struct RecommendDetail {
  @State detail?: RecommendedItem = undefined

  aboutToAppear() {
    const params = router.getParams() as RecommendDetailParams
    if (params && params.item) {
      this.detail = params.item
    }
  }

  getTags(): string[] {
    if (!this.detail || !this.detail.category) return [];
    switch (this.detail.category) {
      case 'dance': return CATEGORY_TAGS_DANCE;
      case 'music': return CATEGORY_TAGS_MUSIC;
      case 'photography': return CATEGORY_TAGS_PHOTOGRAPHY;
      case 'food': return CATEGORY_TAGS_FOOD;
      case 'art': return CATEGORY_TAGS_ART;
      case 'game': return CATEGORY_TAGS_GAME;
      case 'fitness': return CATEGORY_TAGS_FITNESS;
      default: return [];
    }
  }

  getDescription(): string {
    if (!this.detail || !this.detail.category) return '暂无详细介绍';
    switch (this.detail.category) {
      case 'dance': return DEMO_DESCRIPTION_DANCE;
      case 'music': return DEMO_DESCRIPTION_MUSIC;
      case 'photography': return DEMO_DESCRIPTION_PHOTOGRAPHY;
      case 'food': return DEMO_DESCRIPTION_FOOD;
      case 'art': return DEMO_DESCRIPTION_ART;
      case 'game': return DEMO_DESCRIPTION_GAME;
      case 'fitness': return DEMO_DESCRIPTION_FITNESS;
      default: return '暂无详细介绍';
    }
  }

  @Builder Header() {
    Row() {
      Button() {
        Text('←').fontSize(24).fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => { router.back() })

      Text('推荐详情').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Blank()
    }
    .width('100%').padding(20).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      this.Header()

      if (this.detail) {
        // 封面
        Image(this.detail.thumbnail)
          .width('100%')
          .height(200)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .margin({ bottom: 20 })

        // 主标题
        Text(this.detail.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 12 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 作者、播放量
        Row() {
          Text(this.detail.author)
            .fontSize(15)
            .fontColor('#CCCCCC')
            .margin({ right: 18 })
          Text(this.detail.plays + '次播放')
            .fontSize(15)
            .fontColor('#CCCCCC')
        }
        .margin({ bottom: 12 })

        // 分类
        Row() {
          Text('分类：')
            .fontSize(14)
            .fontColor('#888888')
          Text(this.detail.category)
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .margin({ bottom: 8 })

        // 标签
        Row() {
          ForEach(this.getTags(), (tag: string) => {
            Text('#' + tag)
              .fontSize(12)
              .fontColor('#FFCC66')
              .backgroundColor('rgba(255,204,102,0.09)')
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .borderRadius(10)
              .margin({ right: 8 })
          })
        }
        .margin({ bottom: 16 })

        // 简介
        Column() {
          Text('内容简介')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .margin({ bottom: 6 })
          Text(this.getDescription())
            .fontSize(14)
            .fontColor('#CFCFCF')
            .lineHeight(22)
        }
        .margin({ bottom: 24 })

        // 操作按钮
        Row() {
          Button() {
            Text('👍 赞一下').fontSize(15).fontColor('#FF5555')
          }
          .backgroundColor('#222')
          .borderRadius(15)
          .padding({ left: 18, right: 18, top: 8, bottom: 8 })
          .margin({ right: 20 })

          Button() {
            Text('分享').fontSize(15).fontColor('#FFD700')
          }
          .backgroundColor('#222')
          .borderRadius(15)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        }
        .margin({ top: 10, bottom: 10 })
        .justifyContent(FlexAlign.Start)
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 18, right: 18, top: 10 })
    .backgroundColor('#111111')
  }
}