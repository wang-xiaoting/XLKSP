import preferences from '@ohos.data.preferences';

// 评论类型
interface Comment {
  id: number,
  userId: number,
  userName: string,
  content: string,
  time: string
}
export interface Notification {
  id: number,
  avatar: Resource,
  name: string,
  time: string,
  type: string,
  content?: string
}
export interface Message {
  id: number,
  avatar: Resource,
  name: string,
  time: string,
  content: string,
  unreadCount?: number
}

// 单聊消息类型（Chat.ets 聊天历史用）
export interface ChatMessage {
  id: number,
  content: string,
  isSelf: boolean,
  time: string
}

export class DataManager {
  private static instance: DataManager;
  private preferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'videoData';
  private readonly LIKED_VIDEOS_KEY = 'likedVideos';
  private readonly COLLECTED_VIDEOS_KEY = 'collectedVideos';
  private readonly HISTORY_VIDEOS_KEY = 'historyVideos';
  private readonly COMMENTS_KEY = 'videoComments';
  private readonly PRIVATE_MESSAGES_KEY = 'privateMessages';
  private readonly NOTIFICATIONS_KEY = 'notifications';

  // 聊天历史前缀
  private readonly USER_MESSAGES_PREFIX = 'messages_';

  private constructor() {}

  public static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager();
    }
    return DataManager.instance;
  }

  public async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (err) {
      console.error('初始化preferences失败:', err);
    }
  }

  public async savePrivateMessages(messages: Message[]): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(this.PRIVATE_MESSAGES_KEY, JSON.stringify(messages));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存私信消息失败:', err);
    }
  }

  public async getPrivateMessages(): Promise<Message[]> {
    if (!this.preferences) return [];
    try {
      const messagesStr = await this.preferences.get(this.PRIVATE_MESSAGES_KEY, '[]') as string;
      return JSON.parse(messagesStr);
    } catch (err) {
      console.error('获取私信消息失败:', err);
      return [];
    }
  }

  public async saveNotifications(notifications: Notification[]): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(this.NOTIFICATIONS_KEY, JSON.stringify(notifications));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存通知失败:', err);
    }
  }

  public async getNotifications(): Promise<Notification[]> {
    if (!this.preferences) return [];
    try {
      const notificationsStr = await this.preferences.get(this.NOTIFICATIONS_KEY, '[]') as string;
      return JSON.parse(notificationsStr);
    } catch (err) {
      console.error('获取通知失败:', err);
      return [];
    }
  }

  public async saveLikedVideo(videoId: number, isLiked: boolean): Promise<void> {
    if (!this.preferences) return;
    try {
      let likedVideos = await this.getLikedVideos();
      if (isLiked) {
        if (!likedVideos.includes(videoId)) {
          likedVideos.push(videoId);
        }
      } else {
        likedVideos = likedVideos.filter(id => id !== videoId);
      }
      await this.preferences.put(this.LIKED_VIDEOS_KEY, JSON.stringify(likedVideos));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存点赞状态失败:', err);
    }
  }

  public async saveCollectedVideo(videoId: number, isCollected: boolean): Promise<void> {
    if (!this.preferences) return;
    try {
      let collectedVideos = await this.getCollectedVideos();
      if (isCollected) {
        if (!collectedVideos.includes(videoId)) {
          collectedVideos.push(videoId);
        }
      } else {
        collectedVideos = collectedVideos.filter(id => id !== videoId);
      }
      await this.preferences.put(this.COLLECTED_VIDEOS_KEY, JSON.stringify(collectedVideos));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存收藏状态失败:', err);
    }
  }

  public async getLikedVideos(): Promise<number[]> {
    if (!this.preferences) return [];
    try {
      const likedVideosStr = await this.preferences.get(this.LIKED_VIDEOS_KEY, '[]');
      return JSON.parse(likedVideosStr as string);
    } catch (err) {
      console.error('获取点赞视频列表失败:', err);
      return [];
    }
  }

  public async getCollectedVideos(): Promise<number[]> {
    if (!this.preferences) return [];
    try {
      const collectedVideosStr = await this.preferences.get(this.COLLECTED_VIDEOS_KEY, '[]');
      return JSON.parse(collectedVideosStr as string);
    } catch (err) {
      console.error('获取收藏视频列表失败:', err);
      return [];
    }
  }

  public async isVideoLiked(videoId: number): Promise<boolean> {
    const likedVideos = await this.getLikedVideos();
    return likedVideos.includes(videoId);
  }

  public async isVideoCollected(videoId: number): Promise<boolean> {
    const collectedVideos = await this.getCollectedVideos();
    return collectedVideos.includes(videoId);
  }

  public async addToHistory(videoId: number): Promise<void> {
    if (!this.preferences) return;
    try {
      let historyVideos = await this.getHistoryVideos();
      const index = historyVideos.indexOf(videoId);
      if (index > -1) {
        historyVideos.splice(index, 1);
      }
      historyVideos.unshift(videoId);
      if (historyVideos.length > 50) {
        historyVideos.pop();
      }
      await this.preferences.put(this.HISTORY_VIDEOS_KEY, JSON.stringify(historyVideos));
      await this.preferences.flush();
    } catch (err) {
      console.error('添加历史记录失败:', err);
    }
  }

  public async getHistoryVideos(): Promise<number[]> {
    if (!this.preferences) return [];
    try {
      const historyVideosStr = await this.preferences.get(this.HISTORY_VIDEOS_KEY, '[]') as string;
      return JSON.parse(historyVideosStr);
    } catch (err) {
      console.error('获取历史记录失败:', err);
      return [];
    }
  }

  public async clearHistory(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(this.HISTORY_VIDEOS_KEY, '[]');
      await this.preferences.flush();
    } catch (err) {
      console.error('清除历史记录失败:', err);
    }
  }

  public async addComment(videoId: number, comment: Comment): Promise<void> {
    if (!this.preferences) return;
    try {
      const comments = await this.getComments(videoId);
      comments.push(comment);
      await this.preferences.put(`${this.COMMENTS_KEY}_${videoId}`, JSON.stringify(comments));
      await this.preferences.flush();
    } catch (err) {
      console.error('添加评论失败:', err);
    }
  }

  public async getComments(videoId: number): Promise<Comment[]> {
    if (!this.preferences) return [];
    try {
      const commentsStr = await this.preferences.get(`${this.COMMENTS_KEY}_${videoId}`, '[]') as string;
      return JSON.parse(commentsStr);
    } catch (err) {
      console.error('获取评论失败:', err);
      return [];
    }
  }

  public async getAllComments(): Promise<Record<number, Comment[]>> {
    if (!this.preferences) return {};
    try {
      const allCommentsStr = await this.preferences.get(this.COMMENTS_KEY, '{}') as string;
      return JSON.parse(allCommentsStr);
    } catch (err) {
      console.error('获取所有评论失败:', err);
      return {};
    }
  }

  public async clearComments(videoId: number): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(`${this.COMMENTS_KEY}_${videoId}`, '[]');
      await this.preferences.flush();
    } catch (err) {
      console.error('清除评论失败:', err);
    }
  }

  // 单用户聊天历史，Chat.ets 用
  public async saveUserMessages(userId: number, messages: ChatMessage[]): Promise<void> {
    if (!this.preferences) return;
    try {
      const key = `${this.USER_MESSAGES_PREFIX}${userId}`;
      await this.preferences.put(key, JSON.stringify(messages));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存用户聊天记录失败:', err);
    }
  }

  public async getUserMessages(userId: number): Promise<ChatMessage[]> {
    if (!this.preferences) return [];
    try {
      const key = `${this.USER_MESSAGES_PREFIX}${userId}`;
      const str = await this.preferences.get(key, '[]') as string;
      return JSON.parse(str) as ChatMessage[];
    } catch (err) {
      console.error('获取用户聊天记录失败:', err);
      return [];
    }
  }
}

export const dataManager = DataManager.getInstance();