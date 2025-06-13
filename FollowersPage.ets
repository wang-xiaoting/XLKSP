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
struct FollowersPage {
  @State followersList: UserInfo[] = [
  // 示例数据，实际数据可以根据需要替换
    { avatar: $r('app.media.like'), nickname: '用户1', bio: '简介1', gender: '男' },
    { avatar: $r('app.media.liked'), nickname: '用户2', bio: '简介2', gender: '女' },
    { avatar: $r('app.media.sex'), nickname: '用户3', bio: '简介3', gender: '男' },
    { avatar: $r('app.media.sex'), nickname: '用户4', bio: '简介4', gender: '女' },
  ];
  @State searchQuery: string = '';  // 存储搜索框的内容
  @State filteredFollowersList: UserInfo[] = this.followersList;  // 存储过滤后的列表

  // 过滤粉丝列表，依据昵称
  filterFollowers() {
    this.filteredFollowersList = this.followersList.filter((user) =>
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

  @Builder FollowersList() {
    List() {
      ForEach(this.filteredFollowersList, (user: UserInfo) => {
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
        this.filterFollowers();  // 每次输入内容时触发过滤
      });
  }

  build() {
    Column() {
      this.TopNavBar('followers')
      this.SearchBar()  // 搜索框
      this.FollowersList()  // 粉丝列表
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ff0c0c0c')
  }


}
