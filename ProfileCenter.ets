import router from '@ohos.router';
import { DataManager } from '../utils/DataManager';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

interface UserStats {
  following: number,
  followers: number,
  likes: number
}

interface Work {
  id: number,
  image: string,
  likes: number,
  url: Resource,
  author: string,
  description: string,
  isLiked: boolean,
  isCollected: boolean
}

interface NavItem {
  icon: string,
  label: string,
  route: string,
  active?: boolean
}

interface UserInfo {
  avatar: Resource,
  nickname: string,
  bio: string,
  gender: string
}

interface PrivacySettings {
  profileVisibility: boolean;
  showLikes: boolean;
  showCollections: boolean;
  showHistory: boolean;
  allowTagging: boolean;
  allowComments: boolean;
  allowMessages: boolean;
}

interface RouteParams {
  userInfo?: UserInfo,
  privacySettings?: PrivacySettings
}

type TabType = 'collections' | 'works' | 'likes' | 'history';

@Entry
@Component
struct Profile {
  @State username: string = '舞蹈小王子'
  @State followers: number = 12580
  @State following: number = 256
  @State likes: number = 125800
  @State userInfo: UserInfo = {
    avatar: $r('app.media.profile2'),
    nickname: '舞蹈小王子',
    bio: '热爱舞蹈，分享快乐',
    gender: '男'
  }

  @State currentTab: TabType = 'works'
  @State userStats: UserStats = {
    following: 256,
    followers: 12580,
    likes: 125800
  }

  @State works: Work[] = [
    {
      id: 1,
      image: 'https://picsum.photos/200/200',
      likes: 42,
      url: $r('app.media.video'),
      author: '橘子皮',
      description: '#666被制裁了',
      isLiked: false,
      isCollected: false
    },
    {
      id: 2,
      image: 'https://picsum.photos/200/201',
      likes: 18,
      url: $r('app.media.video1'),
      author: '橘子皮',
      description: '#我被做局了',
      isLiked: false,
      isCollected: false
    }
  ]

  @State likedVideos: Work[] = []
  @State collectedVideos: Work[] = []
  @State historyVideos: Work[] = []

  // 添加加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State showLikesDialog: boolean = false;

  private readonly tabNames: Record<TabType, string> = {
    'collections': '收藏',
    'works': '作品',
    'likes': '喜欢',
    'history': '历史'
  }

  private readonly navItems: NavItem[] = [
    { icon: '🏠', label: '首页', route: 'Index', active: false },
    { icon: '🔍', label: '发现', route: 'Discover', active: false },
    { icon: '+', label: '创建', route: 'Create', active: false },
    { icon: '💬', label: '消息', route: 'Messages', active: false },
    { icon: '👤', label: '我', route: 'Profile', active: true }
  ]

  private dataManager: DataManager = DataManager.getInstance();

  // 添加下拉刷新功能
  async onRefresh() {
    this.isRefreshing = true;
    try {
      await this.loadLikedAndCollectedVideos();
      await this.loadHistoryVideos();
      promptAction.showToast({ message: '刷新成功' });
    } catch (err) {
      promptAction.showToast({ message: '刷新失败，请重试' });
    } finally {
      this.isRefreshing = false;
    }
  }

  // 优化数据加载
  async aboutToAppear() {
    this.isLoading = true;
    try {
      // 优先从本地读取用户信息
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, 'userInfoPrefs');
      const userInfoStr = await prefs.get('userInfo', '') as string;
      
      // 如果有本地存储的用户信息，使用本地信息
      if (userInfoStr) {
        const localUserInfo = JSON.parse(userInfoStr) as UserInfo;
        this.userInfo = localUserInfo;
        this.username = localUserInfo.nickname;
        console.info('从本地读取到用户信息:', userInfoStr);
      }

      // 检查路由参数，如果有新的用户信息则更新
      const params = router.getParams() as RouteParams;
      if (params?.userInfo) {
        this.userInfo = params.userInfo;
        this.username = params.userInfo.nickname;
        // 保存到本地
        await prefs.put('userInfo', JSON.stringify(this.userInfo));
        await prefs.flush();
      }

      // 检查是否有隐私设置更新
      if (params?.privacySettings) {
        const privacyPrefs = await preferences.getPreferences(context, 'privacySettings');
        await privacyPrefs.put('settings', JSON.stringify(params.privacySettings));
        await privacyPrefs.flush();
      }

      // 初始化数据
      await this.dataManager.init();
      await this.loadLikedAndCollectedVideos();
      await this.loadHistoryVideos();
    } catch (e) {
      console.error('初始化数据失败:', e);
      promptAction.showToast({ message: '加载失败，请重试' });
    } finally {
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    // 移除事件监听
    globalThis.eventHub?.off('userInfoUpdated')
  }

  // 优化视频加载
  private async loadLikedAndCollectedVideos() {
    try {
      const likedVideoIds = await this.dataManager.getLikedVideos();
      const collectedVideoIds = await this.dataManager.getCollectedVideos();

      this.likedVideos = this.works.filter(work => likedVideoIds.includes(work.id));
      this.collectedVideos = this.works.filter(work => collectedVideoIds.includes(work.id));
      this.userStats.likes = likedVideoIds.length;
    } catch (err) {
      console.error('加载点赞和收藏视频失败:', err);
      promptAction.showToast({ message: '加载失败，请重试' });
    }
  }

  // 优化历史记录加载
  private async loadHistoryVideos() {
    try {
      const historyVideoIds = await this.dataManager.getHistoryVideos();
      this.historyVideos = this.works.filter(work => historyVideoIds.includes(work.id));
    } catch (err) {
      console.error('加载历史记录失败:', err);
      promptAction.showToast({ message: '加载失败，请重试' });
    }
  }

  // 优化Header组件
  @Builder Header() {
    Column() {
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

        Blank()

        Button() {
          Text('⚙️')
            .fontSize(24)
        }
        .backgroundColor('transparent')
        .onClick(() => {
          try {
            router.pushUrl({
              url: 'pages/setting',
              params: { showPrivacy: true }
            });
          } catch (error) {
            console.error('跳转失败:', error);
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20 })

      Image(this.userInfo.avatar)
        .width(100)
        .height(100)
        .borderRadius(50)
        .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
        .margin({ top: 30, bottom: 15 })

      Text(this.userInfo.nickname)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })

      Text(this.userInfo.bio)
        .fontSize(14)
        .fontColor('rgba(255, 255, 255, 0.8)')
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      Row() {
        Column() {
          Text(this.userStats.following.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('关注')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/FollowingPage' })
        })

        Column() {
          Text(this.userStats.followers.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('粉丝')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .margin({ left: 20, right: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/FollowersPage' })
        })

        Column() {
          Text(this.userStats.likes.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('获赞')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .onClick(() => {
          this.showLikesDialog = true;
        })
      }
      .margin({ bottom: 20 })

      Button('编辑资料')
        .width(120)
        .height(36)
        .fontSize(14)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .borderRadius(18)
        .fontColor('#FFFFFF')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ProfileEdit',
            params: {
              userInfo: this.userInfo
            }
          })
        })
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor('transparent')
  }

  @Builder ContentTabs() {
    Row() {
      ForEach(['collections', 'works', 'likes', 'history'] as TabType[], (tab: TabType) => {
        Text(this.tabNames[tab])
          .fontSize(16)
          .fontColor(this.currentTab === tab ? '#FFFFFF' : 'rgba(255, 255, 255, 0.7)')
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

  // 优化内容网格
  @Builder ContentGrid() {
    if (this.isLoading) {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#FF0050')
    } else {
      Refresh({ refreshing: $$this.isRefreshing }) {
        Grid() {
          if (this.currentTab === 'works') {
            ForEach(this.works, (work: Work) => {
              GridItem() {
                Stack() {
                  Image($r('app.media.Videoicon'))
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                  Row() {
                    Text('❤️')
                      .fontSize(12)
                    Text(work.likes.toString())
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  }
                  .position({ x: 5, y: '90%' })
                }
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/videoplayer',
                    params: { videoId: work.id }
                  })
                })
              }
              .aspectRatio(1)
            })
          } else if (this.currentTab === 'likes') {
            ForEach(this.likedVideos, (work: Work) => {
              GridItem() {
                Stack() {
                  Image(work.image)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                  Row() {
                    Text('❤️')
                      .fontSize(12)
                    Text(work.likes.toString())
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  }
                  .position({ x: 5, y: '90%' })
                }
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/videoplayer',
                    params: { videoId: work.id }
                  })
                })
              }
              .aspectRatio(1)
            })
          } else if (this.currentTab === 'collections') {
            ForEach(this.collectedVideos, (work: Work) => {
              GridItem() {
                Stack() {
                  Image(work.image)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                  Row() {
                    Text('❤️')
                      .fontSize(12)
                    Text(work.likes.toString())
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  }
                  .position({ x: 5, y: '90%' })
                }
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/videoplayer',
                    params: { videoId: work.id }
                  })
                })
              }
              .aspectRatio(1)
            })
          } else if (this.currentTab === 'history') {
            ForEach(this.historyVideos, (work: Work) => {
              GridItem() {
                Stack() {
                  Image(work.url)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                  Row() {
                    Text('❤️')
                      .fontSize(12)
                    Text(work.likes.toString())
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  }
                  .position({ x: 5, y: '90%' })
                }
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/videoplayer',
                    params: { videoId: work.id }
                  })
                })
              }
              .aspectRatio(1)
            })
          }
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(2)
        .rowsGap(2)
        .padding(2)
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
    }
  }

  @Builder BottomNav() {
    Row() {
      ForEach(this.navItems, (item: NavItem) => {
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
    return this.tabNames[tab]
  }

  @Builder LikesDialog() {
    if (this.showLikesDialog) {
      Stack() {
        Column(){}
          .backgroundColor('rgba(0,0,0,0.4)')
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.showLikesDialog = false
          })
        Column() {
          Text('获赞数')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
          Text(this.userStats.likes.toString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0050')
            .margin({ bottom: 20 })
          Button('关闭')
            .width(100)
            .onClick(() => {
              this.showLikesDialog = false
            })
        }
        .padding(24)
        .backgroundColor('#fff')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .width(220)
        .position({ x: '50%', y: '50%' })
        .translate({ x: -110, y: -80 })
      }
      .width('100%')
      .height('100%')
      .zIndex(99)
    }
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        this.ContentTabs()
        this.ContentGrid()
        this.BottomNav()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#121212')
      this.LikesDialog()
    }
    .width('100%')
    .height('100%')
  }

  @Builder MenuItem(title: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 10 })
      Text(title)
        .fontSize(16)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .height(50)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#121212')
    .margin({ bottom: 1 })
  }

  private async recordVideoHistory() {
    const video = this.works[this.currentTab === 'works' ? 0 : this.currentTab === 'likes' ? 1 : 2];
    await this.dataManager.addToHistory(video.id);
  }
}