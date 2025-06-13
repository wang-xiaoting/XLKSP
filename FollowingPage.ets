import router from '@ohos.router';
import { DataManager } from '../utils/DataManager';

interface followingList {
  avatar: Resource,
  nickname: string,
  bio: string,
  gender: string
}


interface UserInfo {
  avatar: Resource,
  nickname: string,
  bio: string,
  gender: string
}
@Entry
@Component
struct FollowingPage {
  @State followingList: UserInfo[] = [
  // 示例数据，实际数据可以根据需要替换
    { avatar: $r('app.media.sex'), nickname: '用户A', bio: '简介A', gender: '男' },
    { avatar: $r('app.media.liked'), nickname: '用户B', bio: '简介B', gender: '女' },
    { avatar: $r('app.media.like'), nickname: '用户C', bio: '简介C', gender: '男' },
  ];
  @State searchQuery: string = '';  // 存储搜索框的内容
  @State filteredFollowingList: UserInfo[] = this.followingList;  // 存储过滤后的列表

  filterFollowing() {
    this.filteredFollowingList = this.followingList.filter((user) =>
    user.nickname.toLowerCase().includes(this.searchQuery.toLowerCase())
    );
  }

  @Builder TopNavBar(currentTab: string) {
    Row() {
      Text('关注')
        .fontSize(18)
        .fontColor(currentTab === 'following' ? '#FF0050' : '#FFFFFF')
        .onClick(() => {
          if (currentTab !== 'following') {
            router.pushUrl({ url: 'pages/FollowingPage' })
          }
        })
        .padding({ right: 20 })
      Text('粉丝')
        .fontSize(18)
        .fontColor(currentTab === 'followers' ? '#FF0050' : '#FFFFFF')
        .onClick(() => {
          if (currentTab !== 'followers') {
            router.pushUrl({ url: 'pages/FollowersPage' })
          }
        })
      Blank()
      Button() {
        Text('退出')
          .fontSize(16)
          .fontColor('#FFFFFF')
      }
      .backgroundColor('transparent')
      .onClick(() => {
        router.back()
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .backgroundColor('#1a1a1a')
    .alignItems(VerticalAlign.Center)
  }

  @Builder FollowingList() {
    List() {
      ForEach(this.filteredFollowingList, (user: UserInfo) => {
        ListItem() {
          Row() {
            Image(user.avatar)
              .width(40)
              .height(40)
              .borderRadius(20)
            Text(user.nickname)
              .fontSize(16)
              .fontColor('#FFFFFF')
          }
          .padding(15)
        }
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ProfileCenter',
            params: { userInfo: user }
          })
        })
      })
    }
    .width('100%')
  }

  @Builder SearchBar() {
    TextInput({ placeholder: '搜索联系人或消息' })
      .backgroundColor('transparent')
      .placeholderColor('rgba(255, 255, 255, 0.5)')
      .fontSize(14)
      .width('90%')
      .margin({ left: 10 })
      .onChange((value: string) => {
        this.searchQuery = value;
        this.filterFollowing();  // 每次输入内容时触发过滤
      });
  }
  build() {
    Column() {
      this.TopNavBar('following')
      this.SearchBar()  // 搜索框
      this.FollowingList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121212')
  }
}
