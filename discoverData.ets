export interface TrendingItem {
  id: number,
  image: Resource,
  title: string,
  plays: string,
  category?: string // 新增分类字段
}

export interface Creator {
  id: number,
  avatar: Resource,
  name: string,
  category?: string
}

export interface RecommendedItem {
  id: number,
  thumbnail: Resource,
  title: string,
  author: string,
  plays: string,
  category?: string // 新增分类字段
}

export interface CategoryItem {
  key: string,
  label: string
}

// 分类列表
export const categories: CategoryItem[] = [
  { key: 'recommended', label: '推荐' },
  { key: 'hot', label: '热门' },
  { key: 'music', label: '音乐' },
  { key: 'dance', label: '舞蹈' },
  { key: 'game', label: '游戏' },
  { key: 'food', label: '美食' },
  { key: 'travel', label: '旅行' },
  { key: 'art', label: '艺术' },
  { key: 'fitness', label: '健身' },
  { key: 'photography', label: '摄影' }
]

export const trendingItems: TrendingItem[] = [
  { id: 1, image: $r('app.media.Hiphop'), title: '热门街舞视频', plays: '10.2万', category: 'dance' },
  { id: 2, image: $r('app.media.Hotmusic'), title: '热门音乐榜单', plays: '5.7万', category: 'music' },
  { id: 3, image: $r('app.media.Travelguru'), title: '环游世界Vlog', plays: '3.6万', category: 'travel' },
  { id: 4, image: $r('app.media.jiahcangcai'), title: '家常菜速成教学', plays: '6.8万', category: 'food' },
  { id: 5, image: $r('app.media.erciyuan'), title: '二次元插画挑战', plays: '4.5万', category: 'art' },
  { id: 6, image: $r('app.media.moba'), title: 'MOBA高光操作', plays: '11.3万', category: 'game' },
  { id: 7, image: $r('app.media.jianshen'), title: '健身房日常', plays: '2.4万', category: 'fitness' },
  { id: 8, image: $r('app.media.sheyingshi'), title: '摄影师的日记', plays: '1.7万', category: 'photography' }
]

export const creators: Creator[] = [
  { id: 1, avatar: $r("app.media.wudaodaren"), name: '舞蹈达人', category: 'dance' },
  { id: 2, avatar: $r('app.media.MusicProducer'), name: '音乐制作人', category: 'music' },
  { id: 3, avatar: $r('app.media.Travelguru'), name: '旅行达人', category: 'travel' },
  { id: 4, avatar: $r('app.media.meishibozhu'), name: '美食博主', category: 'food' },
  { id: 5, avatar: $r("app.media.erciyuanhuihua"), name: '二次元绘师', category: 'art' },
  { id: 6, avatar: $r("app.media.youxijs"), name: '游戏解说', category: 'game' },
  { id: 7, avatar: $r("app.media.jianshen"), name: '健身教练', category: 'fitness' },
  { id: 8, avatar: $r("app.media.sheyingshi"), name: '摄影师小王', category: 'photography' }
]

export const recommendedItems: RecommendedItem[] = [
  { id: 1, thumbnail: $r('app.media.jingxuanwudao'), title: '精选舞蹈教学：从零开始学习街舞基础动作', author: '舞蹈达人', plays: '2.3万', category: 'dance' },
  { id: 2, thumbnail: $r('app.media.qinyingyue'), title: '轻音乐合集：助你放松心情，提高工作效率', author: '音乐制作人', plays: '1.8万', category: 'music' },
  { id: 3, thumbnail: $r('app.media.chengshiluori'), title: '城市日落时分：捕捉美丽光影的摄影技巧', author: '摄影师小王', plays: '1.5万', category: 'photography' },
  { id: 4, thumbnail: $r('app.media.jiahcangcai'), title: '家常菜教程：简单易学的快手菜制作方法', author: '美食博主', plays: '3.2万', category: 'food' },
  { id: 5, thumbnail: $r('app.media.erciyuanhuihua'), title: '二次元插画临摹实录', author: '二次元绘师', plays: '2.7万', category: 'art' },
  { id: 6, thumbnail: $r('app.media.moba'), title: 'MOBA上分秘籍：团队协作与细节', author: '游戏解说', plays: '5.1万', category: 'game' },
  { id: 7, thumbnail: $r('app.media.jianshen'), title: '居家健身全攻略', author: '健身教练', plays: '1.9万', category: 'fitness' },
  { id: 8, thumbnail: $r('app.media.zhaopiangushi'), title: '用照片讲故事：我的摄影旅程', author: '摄影师小王', plays: '1.2万', category: 'photography' },
  { id: 9, thumbnail: $r("app.media.erciyuanhuihua"), title: '漫画角色设计思路分享', author: '二次元绘师', plays: '2.1万', category: 'art' },
  { id: 10, thumbnail: $r("app.media.yinshidapei"), title: '健身饮食搭配建议', author: '健身教练', plays: '1.6万', category: 'fitness' }
]