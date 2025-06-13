export interface CreatorStats {
  following: number,
  followers: string,
  likes: string
}

export interface Creator {
  id: number,
  name: string,
  username: string,
  avatar: Resource,
  banner: Resource,
  bio: string,
  stats: CreatorStats,
  category?: string,         // 分类，可选
  description?: string,      // 简介，可选
  isFollowing?: boolean      // creators.ets 用
}

// 创作者数据，涵盖多种分类
export const creators: Creator[] = [
  {
    id: 1,
    name: '舞蹈达人',
    username: '@dance_king',
    avatar: $r("app.media.wudaodaren"),
    banner: $r('app.media.wudao'),
    bio: '专注街舞教学十年，曾获全国街舞锦标赛冠军。热爱分享舞蹈技巧和日常训练。',
    stats: { following: 168, followers: '2.3M', likes: '16.8M' },
    category: 'dance',
    description: '专业舞者 | 街舞教学 | 编舞',
    isFollowing: false
  },
  {
    id: 2,
    name: '音乐制作人',
    username: '@music_maker',
    avatar: $r('app.media.MusicProducer'),
    banner: $r('app.media.Hotmusic'),
    bio: '音乐人 | 作曲 | 编曲 | 热爱用旋律表达情感。',
    stats: { following: 98, followers: '1.1M', likes: '8.2M' },
    category: 'music',
    description: '音乐人 | 作曲 | 编曲',
    isFollowing: true
  },
  {
    id: 3,
    name: '旅行达人',
    username: '@travel_expert',
    avatar: $r('app.media.Travelguru'),
    banner: $r('app.media.lvx'),
    bio: '旅行博主 | 风景摄影 | Vlog | 记录世界的美好。',
    stats: { following: 56, followers: '670K', likes: '2.1M' },
    category: 'travel',
    description: '旅行博主 | 风景摄影 | Vlog',
    isFollowing: false
  },
  {
    id: 4,
    name: '美食博主',
    username: '@foodie',
    avatar: $r('app.media.meishibozhu'),
    banner: $r('app.media.meishi'),
    bio: '美食探店 | 烹饪教学 | 美食摄影 | 发现生活中的美味。',
    stats: { following: 120, followers: '1.52M', likes: '9.7M' },
    category: 'food',
    description: '美食探店 | 烹饪教学 | 美食摄影',
    isFollowing: true
  },
  {
    id: 5,
    name: '二次元绘师',
    username: '@anime_artist',
    avatar: $r("app.media.erciyuanhuihua"),
    banner: $r('app.media.erciyuan'),
    bio: '喜欢用画笔表达心情，主要创作二次元人物和插画。',
    stats: { following: 88, followers: '420K', likes: '3.8M' },
    category: 'art',
    description: '插画师 | 二次元 | 绘画教学',
    isFollowing: false
  },
  {
    id: 6,
    name: '游戏解说',
    username: '@game_master',
    avatar: $r("app.media.youxijieshuo"),
    banner: $r('app.media.moba'),
    bio: '主攻MOBA游戏解说，带你上分！',
    stats: { following: 60, followers: '750K', likes: '6.2M' },
    category: 'game',
    description: '游戏解说 | MOBA | 上分教学',
    isFollowing: false
  },
  {
    id: 7,
    name: '健身教练',
    username: '@fit_coach',
    avatar: $r("app.media.jianshen"),
    banner: $r('app.media.yinshidapei'),
    bio: '科学健身，健康生活。制定个性化训练计划。',
    stats: { following: 44, followers: '310K', likes: '2.5M' },
    category: 'fitness',
    description: '健身教练 | 健康饮食 | 瘦身塑形',
    isFollowing: false
  },
  {
    id: 8,
    name: '摄影师小王',
    username: '@photo_wang',
    avatar: $r("app.media.sheyingshi"),
    banner: $r('app.media.zhaopiangushi'),
    bio: '用镜头记录生活，用光影定格美好。',
    stats: { following: 37, followers: '530K', likes: '4.1M' },
    category: 'photography',
    description: '摄影师 | 风光人像 | 拍摄技巧',
    isFollowing: false
  }
]