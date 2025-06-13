import preferences from '@ohos.data.preferences';

// 评论接口
interface Comment {
  id: number,
  userId: number,
  userName: string,
  content: string,
  time: string
}

/**
 * 消息接口定义
 */
export interface Message {
  id: number;
  avatar: Resource;
  name: string;
  time: string;
  content: string;
  unreadCount?: number;
}

/**
 * 消息数据接口
 */
interface MessageData {
  id: number;
  avatar: Resource;
  name: string;
  time: string;
  content: string;
  unreadCount?: number;
}

/**
 * 消息类实现
 */
class MessageImpl implements Message {
  id: number;
  avatar: Resource;
  name: string;
  time: string;
  content: string;
  unreadCount?: number;

  constructor(id: number, avatar: Resource, name: string, time: string, content: string, unreadCount?: number) {
    this.id = id;
    this.avatar = avatar;
    this.name = name;
    this.time = time;
    this.content = content;
    this.unreadCount = unreadCount;
  }
}

export class DataManager {
  private static instance: DataManager;
  private preferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'videoData';
  private readonly LIKED_VIDEOS_KEY = 'likedVideos';
  private readonly COLLECTED_VIDEOS_KEY = 'collectedVideos';
  private readonly HISTORY_VIDEOS_KEY = 'historyVideos';
  private readonly COMMENTS_KEY = 'videoComments';
  private initialized: boolean = false;
  private readonly MESSAGES_KEY = 'messages';

  private constructor() {}

  public static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager();
    }
    return DataManager.instance;
  }

  public async init(): Promise<void> {
    if (this.initialized) {
      return;
    }
    this.initialized = true;
    try {
      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (err) {
      console.error('初始化preferences失败:', err);
    }
  }

  // 保存点赞状态
  public async saveLikedVideo(videoId: number, isLiked: boolean) {
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

  // 保存收藏状态
  public async saveCollectedVideo(videoId: number, isCollected: boolean) {
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

  // 获取点赞的视频列表
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

  // 获取收藏的视频列表
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

  // 检查视频是否已点赞
  public async isVideoLiked(videoId: number): Promise<boolean> {
    const likedVideos = await this.getLikedVideos();
    return likedVideos.includes(videoId);
  }

  // 检查视频是否已收藏
  public async isVideoCollected(videoId: number): Promise<boolean> {
    const collectedVideos = await this.getCollectedVideos();
    return collectedVideos.includes(videoId);
  }

  // 添加视频到历史记录
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

  // 获取历史记录列表
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

  // 清除历史记录
  public async clearHistory(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(this.HISTORY_VIDEOS_KEY, '[]');
      await this.preferences.flush();
    } catch (err) {
      console.error('清除历史记录失败:', err);
    }
  }

  // 添加评论
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

  // 获取视频评论
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

  // 获取所有视频的评论
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

  // 清除视频评论
  public async clearComments(videoId: number): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(`${this.COMMENTS_KEY}_${videoId}`, '[]');
      await this.preferences.flush();
    } catch (err) {
      console.error('清除评论失败:', err);
    }
  }

  /**
   * 获取所有消息
   * @returns 消息列表
   */
  public async getMessages(): Promise<Message[]> {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, 'messages');
      const messagesStr = await prefs.get(this.MESSAGES_KEY, '[]') as string;
      const messagesData = JSON.parse(messagesStr) as MessageData[];
      const messages: Message[] = messagesData.map(data => new MessageImpl(
        data.id,
        data.avatar,
        data.name,
        data.time,
        data.content,
        data.unreadCount
      ));
      console.info('获取消息成功:', messages.length);
      return messages;
    } catch (err) {
      console.error('获取消息失败:', err);
      return [];
    }
  }

  /**
   * 保存消息列表
   * @param messages 消息列表
   */
  public async saveMessages(messages: Message[]): Promise<void> {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, 'messages');
      const messagesStr = JSON.stringify(messages);
      await prefs.put(this.MESSAGES_KEY, messagesStr);
      await prefs.flush();
      console.info('保存消息成功:', messages.length);
    } catch (err) {
      console.error('保存消息失败:', err);
    }
  }

  /**
   * 添加新消息
   * @param message 新消息
   */
  public async addMessage(message: Message): Promise<void> {
    try {
      const messages = await this.getMessages();
      const newMessages: Message[] = [message];
      for (let i = 0; i < messages.length; i++) {
        newMessages.push(messages[i]);
      }
      await this.saveMessages(newMessages);
      console.info('添加消息成功:', message.id);
    } catch (err) {
      console.error('添加消息失败:', err);
    }
  }

  /**
   * 更新消息
   * @param messageId 消息ID
   * @param updates 更新内容
   */
  public async updateMessage(messageId: number, updates: Partial<Message>): Promise<void> {
    try {
      const messages = await this.getMessages();
      const index = messages.findIndex(msg => msg.id === messageId);
      if (index !== -1) {
        const updatedMessage = new MessageImpl(
          messages[index].id,
          updates.avatar || messages[index].avatar,
          updates.name || messages[index].name,
          updates.time || messages[index].time,
          updates.content || messages[index].content,
          updates.unreadCount
        );
        messages[index] = updatedMessage;
        await this.saveMessages(messages);
        console.info('更新消息成功:', messageId);
      }
    } catch (err) {
      console.error('更新消息失败:', err);
    }
  }

  /**
   * 删除消息
   * @param messageId 消息ID
   */
  public async deleteMessage(messageId: number): Promise<void> {
    try {
      const messages = await this.getMessages();
      const newMessages: Message[] = [];
      for (let i = 0; i < messages.length; i++) {
        if (messages[i].id !== messageId) {
          newMessages.push(messages[i]);
        }
      }
      await this.saveMessages(newMessages);
      console.info('删除消息成功:', messageId);
    } catch (err) {
      console.error('删除消息失败:', err);
    }
  }
}

// 导出DataManager实例
export const dataManager = DataManager.getInstance();