/*
Creator 接口：说明创作者信息的数据结构，包括ID、头像、名称等字段
CategoryItem 接口：说明分类项的数据结构，包括键值和标签
Creators 组件：说明这是用于展示热门创作者列表的页面组件
状态变量注释：
currentCategory：当前选中的分类
creators：创作者列表数据
构建器注释：
Header()：页面头部构建器，包含返回按钮、标题和搜索按钮
CategoryTabs()：分类标签构建器，用于构建分类切换标签栏
CreatorCard()：创作者卡片构建器，用于构建单个创作者的展示卡片
方法注释：
build()：页面主体构建函数，说明整个创作者页面的UI结构
这些注释应该能帮助更好地理解代码的结构和功能，使代码更易于维护和理解。
*/
import router from '@ohos.router';

/**
 * 创作者接口
 * 定义创作者信息的数据结构
 */
interface Creator {
  id: number,           // 创作者ID
  avatar: Resource,     // 创作者头像
  name: string,         // 创作者名称
  category: string,     // 创作者分类
  followers: string,    // 粉丝数量
  isFollowing: boolean, // 是否已关注
  description: string   // 创作者描述
}

/**
 * 分类项接口
 * 定义内容分类的数据结构
 */
interface CategoryItem {
  key: string,    // 分类键值
  label: string   // 分类标签
}

/**
 * 创作者页面组件
 * 用于展示热门创作者列表
 */
@Entry
@Component
struct Creators {
  @State currentCategory: string = 'all'  // 当前选中的分类
  @State creators: Creator[] = [          // 创作者列表
    {
      id: 1,
      avatar: $r('app.media.profile1'),
      name: '舞蹈达人',
      category: 'dance',
      followers: '12.5w',
      isFollowing: false,
      description: '专业舞者 | 街舞教学 | 编舞'
    },
    {
      id: 2,
      avatar: $r('app.media.profile2'),
      name: '音乐制作人',
      category: 'music',
      followers: '8.9w',
      isFollowing: true,
      description: '音乐人 | 作曲 | 编曲'
    },
    {
      id: 3,
      avatar: $r('app.media.cover2'),
      name: '旅行达人',
      category: 'travel',
      followers: '6.7w',
      isFollowing: false,
      description: '旅行博主 | 风景摄影 | Vlog'
    },
    {
      id: 4,
      avatar: $r('app.media.cover1'),
      name: '美食博主',
      category: 'food',
      followers: '15.2w',
      isFollowing: true,
      description: '美食探店 | 烹饪教学 | 美食摄影'
    }
  ]

  // 分类选项配置
  private categories: CategoryItem[] = [
    { key: 'all', label: '全部' },
    { key: 'music', label: '音乐' },
    { key: 'dance', label: '舞蹈' },
    { key: 'food', label: '美食' },
    { key: 'travel', label: '旅行' },
    { key: 'photography', label: '摄影' },
    { key: 'art', label: '艺术' }
  ]

  /**
   * 页面头部构建器
   * 包含返回按钮、标题和搜索按钮
   */
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

      Text('热门创作者')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Button() {
        Text('🔍')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => {
        // 打开搜索页面
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(20)
  }

  /**
   * 分类标签构建器
   * 构建分类切换标签栏
   */
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

  /**
   * 创作者卡片构建器
   * 构建单个创作者的展示卡片
   * @param creator 创作者信息
   */
  @Builder CreatorCard(creator: Creator) {
    Column() {
      Stack() {
        Image(creator.avatar)
          .width('100%')
          .height(180)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Image(creator.avatar)
              .width(60)
              .height(60)
              .borderRadius(30)
              .border({ width: 2, color: '#FFFFFF' })

            Column() {
              Text(creator.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(creator.description)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .opacity(0.8)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
          }
          .width('100%')
        }
        .width('100%')
        .padding(15)
        .backgroundImage($r('app.media.gradient'))
        .backgroundImageSize({ width: '100%', height: '100%' })
        .position({ y: '100%' })
        .translate({ y: -100 })
      }

      Column() {
        Row() {
          Text(creator.followers + ' 粉丝')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.8)

          Button() {
            Text(creator.isFollowing ? '已关注' : '关注')
              .fontColor(creator.isFollowing ? '#FFFFFF' : '#FF0050')
              .fontSize(14)
          }
          .height(32)
          .backgroundColor(creator.isFollowing ? 'rgba(255, 255, 255, 0.2)' : '#FFFFFF')
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            creator.isFollowing = !creator.isFollowing
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 10, bottom: 10 })
      }
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/CreatorProfile',
        params: { id: creator.id }
      })
    })
  }

  /**
   * 页面主体构建函数
   * 构建整个创作者页面的UI结构
   */
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
          this.Header()
          this.CategoryTabs()

          Grid() {
            ForEach(this.creators.filter(creator =>
            this.currentCategory === 'all' || creator.category === this.currentCategory
            ), (creator: Creator) => {
              GridItem() {
                this.CreatorCard(creator)
              }
              .padding(8)
            })
          }
          .columnsTemplate('1fr 1fr')
          .width('100%')
          .layoutWeight(1)
          .padding(8)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}