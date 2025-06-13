import router from '@ohos.router';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DataManager } from '../utils/DataManager';

const DOMAIN_TIKTOK_STYLE: number = 0x0001
// 定义视频数据类型
interface VideoItem {
  id: number; // 视频ID
  url: Resource; // 视频源
  author: string; //  作者
  description: string; //  视频描述
  likes: number; //点赞数
  comments: number; // 评论数
  avatar: Resource; //头像
  isLiked: boolean; // 添加点赞状态字段
  isCollected: boolean; // 添加收藏状态字段
  isShared: boolean; // 添加分享状态字段
}

// 定义评论数据类型
interface Comment {
  id: number;
  userId: number;
  userName: string;
  content: string;
  timestamp: number;
  likes: number;
}

@Entry
@Component
struct TikTokStyle {
  @State currentTab: string = '推荐' // 当前选中的标签
  @State isPlaying: boolean = true // 播放状态
  @State showFloatingWindow: boolean = true // 是否显示悬浮窗
  @State currentBottomTab: number = 2 // 默认为推荐页面
  @State currentVideoIndex: number = 0; // 当前播放的视频索引
  @State private startY: number = 0 // 开始Y坐标
  @State private currentY: number = 0  // 当前Y坐标
  @State showCommentInput: boolean = false // 是否显示评论输入框
  @State commentText: string = '' // 评论内容
  @State charCount: number = 0 // 评论字数统计
  @State comments: Comment[] = [] // 评论列表
  @State showComments: boolean = false // 是否显示评论列表

  // 将videoList改为响应式状态
  @State videoList: VideoItem[] = [
    {
      id: 1,
      url: $r('app.media.video'),
      author: '橘子皮',
      description: '#666被制裁了',
      likes: 12000,
      comments: 2312,
      avatar: $r("app.media.wudaodaren"),
      isLiked: false,
      isCollected: false,
      isShared: false,
    },
    {
      id: 2,
      url: $r('app.media.video1'),
      author: '橘子皮',
      description: '#我被做局了 ',
      likes: 15000,
      comments: 3000,
      avatar: $r("app.media.wudaodaren"),
      isLiked: false,
      isCollected: false,
      isShared: false
    }
  ]

  private dataManager: DataManager = DataManager.getInstance();

  aboutToAppear() {
    // 初始化数据管理器
    this.dataManager.init();
    // 加载视频的点赞和收藏状态
    this.loadVideoStates();
    // 记录当前视频到历史记录
    this.recordVideoHistory();
  }

  // 加载视频状态
  private async loadVideoStates() {
    for (let i = 0; i < this.videoList.length; i++) {
      const video = this.videoList[i];
      const isLiked = await this.dataManager.isVideoLiked(video.id);
      const isCollected = await this.dataManager.isVideoCollected(video.id);
      this.updateVideoState(i, { isLiked, isCollected });
    }
  }

  // 更新视频状态的方法
  private async updateVideoState(index: number, updates: Partial<VideoItem>) {
    let currentVideo = this.videoList[index];
    this.videoList[index] = {
      id: currentVideo.id,
      url: currentVideo.url,
      author: currentVideo.author,
      description: currentVideo.description,
      likes: updates.likes !== undefined ? updates.likes : currentVideo.likes,
      comments: currentVideo.comments,
      avatar: currentVideo.avatar,
      isLiked: updates.isLiked !== undefined ? updates.isLiked : currentVideo.isLiked,
      isCollected: updates.isCollected !== undefined ? updates.isCollected : currentVideo.isCollected,
      isShared: updates.isShared !== undefined ? updates.isShared : currentVideo.isShared
    };

    // 保存状态到持久化存储
    if (updates.isLiked !== undefined) {
      await this.dataManager.saveLikedVideo(currentVideo.id, updates.isLiked);
    }
    if (updates.isCollected !== undefined) {
      await this.dataManager.saveCollectedVideo(currentVideo.id, updates.isCollected);
    }
  }

  // 记录视频到历史记录
  private async recordVideoHistory() {
    const video = this.videoList[this.currentVideoIndex];
    await this.dataManager.addToHistory(video.id);
  }

  // 处理视频切换
  private switchVideo(direction: number) {
    const newIndex = this.currentVideoIndex + direction
    if (newIndex >= 0 && newIndex < this.videoList.length) {
      this.currentVideoIndex = newIndex
      // 记录新视频到历史记录
      this.recordVideoHistory();
    }
  }

  // 添加评论的方法
  private addComment(content: string) {
    if (content.trim() === '') return;

    const newComment: Comment = {
      id: Date.now(),
      userId: 1,
      userName: '橘子皮', // 使用当前视频作者作为评论者
      content: content,
      timestamp: Date.now(),
      likes: 0
    };

    this.comments = [newComment, ...this.comments];
    this.commentText = '';
    this.charCount = 0;
    this.showCommentInput = false;
  }

  build() {
    Stack() {
      // 视频容器
      Video({
        src: this.videoList[this.currentVideoIndex].url,
        currentProgressRate: 1.0,
        controller: new VideoController()
      })
        .width('100%')
        .height('85%')
        .objectFit(ImageFit.Cover)
        .autoPlay(true)
        .loop(true)
        .muted(false) // 取消静音
        .controls(false) //隐藏进度条
        .gesture(
          PanGesture()
            .onActionStart((event: GestureEvent) => {
              this.startY = event.offsetY
            })
            .onActionUpdate((event: GestureEvent) => {
              this.currentY = event.offsetY
            })
            .onActionEnd(() => {
              const distance = this.currentY - this.startY
              if (Math.abs(distance) > 50) { // 设置最小滑动距离
                if (distance > 0) {
                  // 向下滑动
                  if (this.currentVideoIndex < this.videoList.length - 1) {
                    this.switchVideo(1)
                  }
                } else {
                  // 向上滑动
                  if (this.currentVideoIndex > 0) {
                    this.switchVideo(-1)
                  }
                }
              }
            })
        )

      // 顶部导航
      Row() {
        ForEach(['关注', '推荐', '热门'], (tab: string) => {
          Text(tab)
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(this.currentTab === tab ? FontWeight.Bold : FontWeight.Normal)
            .opacity(this.currentTab === tab ? 1.0 : 0.7)
            .margin({ left: 20, right: 20 })
            .onClick(() => {
              this.currentTab = tab
            })
        })
      }
      .width('100%')
      .height('5%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .position({ x: 0, y: 0 })
      .justifyContent(FlexAlign.Center)


      Column(){
        //作者头像
        Column({ space: 5 }) {
          Image(this.videoList[this.currentVideoIndex].isLiked ? $r("app.media.Videoicon") : $r('app.media.Videoicon'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .onClick(() => {
              router.pushUrl({ url: 'pages/cpubg' });
              const newLiked = !this.videoList[this.currentVideoIndex].isLiked;
              this.updateVideoState(this.currentVideoIndex, {
                isLiked: newLiked,
                likes: this.videoList[this.currentVideoIndex].likes + (newLiked ? 1 : -1)
              });
            })
        }
        // 点赞按钮
        Column({ space: 5 }) {
          Image(this.videoList[this.currentVideoIndex].isLiked ? $r("app.media.liked") : $r("app.media.like"))
            .width(40)
            .height(40)
            .borderRadius(20)
            .onClick(() => {
              const newLiked = !this.videoList[this.currentVideoIndex].isLiked;
              this.updateVideoState(this.currentVideoIndex, {
                isLiked: newLiked,
                likes: this.videoList[this.currentVideoIndex].likes + (newLiked ? 1 : -1)
              });
            });

          Text(`${this.videoList[this.currentVideoIndex].likes}`)
            .fontSize(12)
            .fontColor(Color.White);
        }
        .margin({ bottom: 20 })

        // 评论按钮
        Column({ space: 5 }) {
          Image($r('app.media.commented'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .onClick(() => {
              this.showComments = true;
            })
          Text(`${this.videoList[this.currentVideoIndex].comments}`)
            .fontSize(12)
            .fontColor(Color.White)
        }
        .margin({ bottom: 20 })

        // 收藏按钮
        Column({ space: 5 }) {
          Image(this.videoList[this.currentVideoIndex].isCollected ? $r("app.media.collected") : $r("app.media.collect"))
            .width(40)
            .height(40)
            .borderRadius(20)
            .onClick(() => {
              const newCollected = !this.videoList[this.currentVideoIndex].isCollected;
              this.updateVideoState(this.currentVideoIndex, {
                isCollected: newCollected
              });
            });

          Text(this.videoList[this.currentVideoIndex].isCollected ? '已收藏' : '收藏')
            .fontSize(12)
            .fontColor(Color.White);
        }
        .margin({ bottom: 20 })

        // 分享按钮
        Column({ space: 5 }) {
          Image(this.videoList[this.currentVideoIndex].isShared ? $r('app.media.share1') : $r('app.media.share1'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .onClick(() => {
              const newShared = !this.videoList[this.currentVideoIndex].isShared;
              this.updateVideoState(this.currentVideoIndex, {
                isShared: newShared
              });
              hilog.info(DOMAIN_TIKTOK_STYLE, 'TikTokStyle', 'Share button clicked');
            });

          Text('分享')
            .fontSize(12)
            .fontColor(Color.White);
        }
        .margin({ bottom: 20 })
      }
      .margin({ bottom: 20 })
      .position({ x: '90%', y: '50%' })
      .translate({ x: -20, y: -100 })


      // 底部视频信息
      Column() {
        Row() {
          Text('@' + this.videoList[this.currentVideoIndex].author)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 0 })
            .fontColor(Color.White)
            .alignSelf(ItemAlign.Start)

        }
        Text(this.videoList[this.currentVideoIndex].description)
          .fontSize(20)
          .margin({ top: 0 })
          .fontColor(Color.White)
          .alignSelf(ItemAlign.Start)
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/cpubg' });
      })
      .width('70%')
      .position({ x: 0, y: '100%' })
      .translate({ y: -120 })
      .alignItems(HorizontalAlign.Start)


      // 底部导航栏
      Row() {
        // 首页
        Column() {
          Text('首页')
            .fontSize(20)
            .fontColor(this.currentBottomTab === 0 ? '#F0000' : '#FFFFFF');
        }
        .width('20%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentBottomTab = 0;
          router.pushUrl({ url: 'pages/Index' });
        });

        // 发现
        Column() {
          Text('发现')
            .fontSize(20)
            .fontColor(this.currentBottomTab === 1 ? '#FF0050' : '#FFFFFF');
        }
        .width('20%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentBottomTab = 1;
          router.pushUrl({ url: 'pages/Discover' });
        });

        // 创建
        Column() {

          Text('创建')
            .fontSize(20)
            .fontColor(this.currentBottomTab === 2 ? '#FF0050' : '#FFFFFF');
        }
        .width('20%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentBottomTab = 2;
          router.pushUrl({ url: 'pages/Create' });
        });

        // 消息
        Column() {

          Text('消息')
            .fontSize(20)
            .fontColor(this.currentBottomTab === 3 ? '#FF0050' : '#FFFFFF');
        }
        .width('20%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentBottomTab = 3;
          router.pushUrl({ url: 'pages/Message' });
        });

        // 我
        Column() {

          Text('我')
            .fontSize(20)
            .fontColor(this.currentBottomTab === 4 ? '#FF0050' : '#FFFFFF');
        }
        .width('20%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentBottomTab = 4;
          router.pushUrl({ url: 'pages/ProfileCenter' });
        });
      }
      .width('100%')
      .height(60)
      .backgroundColor('#1E1E1E')
      .position({ x: 0, y: '100%' })
      .translate({ y: -60 });

      // 评论列表
      if (this.showComments) {
        Column() {
          // 评论列表标题栏
          Row() {
            Text('评论')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)
            Blank()
            Image($r('app.media.ic_close'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.showComments = false;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)

          // 评论列表内容
          List() {
            ForEach(this.comments, (comment: Comment) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(comment.userName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.Black)
                    Text(new Date(comment.timestamp).toLocaleString())
                      .fontSize(12)
                      .fontColor('#666666')
                      .margin({ left: 8 })
                  }
                  Text(comment.content)
                    .fontSize(14)
                    .fontColor(Color.Black)
                    .margin({ top: 8 })
                  Row() {
                    Image($r('app.media.like'))
                      .width(16)
                      .height(16)
                    Text(comment.likes.toString())
                      .fontSize(12)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  }
                  .margin({ top: 8 })
                }
                .width('100%')
                .padding(16)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(Color.White)

          // 评论输入框
          Row() {
            TextInput({ placeholder: '说点什么...', text: this.commentText })
              .width('80%')
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(20)
              .padding({ left: 15, right: 15 })
              .fontColor(Color.Black)
              .placeholderColor('#999999')
              .onChange((value: string) => {
                this.commentText = value;
                this.charCount = value.length;
              })

            Button('发送')
              .width(60)
              .height(40)
              .backgroundColor('#FF0050')
              .borderRadius(20)
              .fontColor(Color.White)
              .onClick(() => {
                this.addComment(this.commentText);
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
        }
        .width('100%')
        .height('100%') // 使用全屏高度
        .position({ x: 0, y: 0 }) // 从顶部开始
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}