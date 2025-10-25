// WeatherReceiver.ets - UDP接收端
import socket from '@ohos.net.socket';
import util from '@ohos.util';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

interface WeatherInfo {
  type: string;
  city: string;
  temperature: number;
  weather: string;
  humidity: number;
  windSpeed: number;
  timestamp: number;
}

@Entry
@Component
struct WeatherReceiver {
  @State listeningPort: string = '8089';
  @State isListening: boolean = false;
  @State status: string = '未启动';
  @State weatherInfos: WeatherInfo[] = [];
  private udpSocket: socket.UDPSocket | null = null;

  aboutToAppear() {
    // 创建UDP Socket
    this.udpSocket = socket.constructUDPSocketInstance();
  }

  aboutToDisappear() {
    this.stopListening();

  }

  // 开始监听天气信息
  startListening() {
    if (this.isListening) {
      promptAction.showToast({ message: '已在监听中' });
      return;
    }

    const port = parseInt(this.listeningPort);
    if (isNaN(port) || port <= 0 || port > 65535) {
      promptAction.showToast({ message: '端口无效' });
      return;
    }
    try {
      if (!this.udpSocket) {
        this.udpSocket = socket.constructUDPSocketInstance()
      }
      // 先设置消息事件监听
      this.udpSocket?.on('message', (data) => {
        console.info(`收到UDP消息，长度: ${data.message.byteLength}`);
        this.handleIncomingMessage(data);
      });
      // 绑定端口（指定）
      this.udpSocket?.bind({ address: '127.0.0.1', port: port, family: 1 })
        .then(() => {
          this.isListening = true;
          this.status = '监听中...';
          promptAction.showToast({ message: `开始监听端口 ${port}` });
        })
        .catch((err: BusinessError) => {
          this.status = '启动失败: ' + JSON.stringify(err);
          promptAction.showToast({ message: '启动监听失败' });
        });
    } catch (err) {
      console.error(`监听过程中出现异常:${JSON.stringify(err)}`)

    }
  }

  // 停止监听
  stopListening() {
    if (!this.isListening) {
      return;
    }

    if (this.udpSocket) {
      this.udpSocket.close()
        .then(() => {
          this.udpSocket = socket.constructUDPSocketInstance();
          this.isListening = false;
          this.status = '已停止';
          promptAction.showToast({ message: '已停止监听' });
        })
        .catch((err: BusinessError) => {
          this.status = '停止失败: ' + JSON.stringify(err);
        });
    }
  }

  // 处理接收到的消息
  handleIncomingMessage(data: socket.SocketMessageInfo) {
    try {
      // 将二进制数据转换为字符串
      const textDecoder = util.TextDecoder.create('utf-8');
      const messageStr = textDecoder.decodeWithStream(new Uint8Array(data.message));

      // 解析JSON数据
      const weatherData = JSON.parse(messageStr) as WeatherInfo;

      if (weatherData.type === 'weather_info') {
        // 添加到天气信息列表(最多保存10条)
        this.weatherInfos.unshift(weatherData);
        if (this.weatherInfos.length > 10) {
          this.weatherInfos.pop();
        }

        // 更新状态
        this.status = `收到 ${weatherData.city} 的天气信息`;
        console.info('收到天气信息:', JSON.stringify(weatherData));
      }
    } catch (err) {
      console.error('处理消息失败:', JSON.stringify(err));
    }
  }

  // 清除所有天气信息
  clearWeatherInfos() {
    this.weatherInfos = [];
    promptAction.showToast({ message: '已清除所有天气信息' });
  }

  build() {
    Column() {
      // 标题
      Text('天气信息接收器')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin(20)

      // 状态显示
      Text('状态: ' + this.status)
        .fontSize(16)
        .fontColor(this.isListening ? Color.Green : Color.Gray)
        .margin({ bottom: 10 })

      // 端口设置
      Row() {
        Text('监听端口:')
          .width(80)
        TextInput({ text: this.listeningPort })
          .width('50%')
          .type(InputType.Number)
          .enabled(!this.isListening)
          .onChange((value) => {
            this.listeningPort = value;
          })
        Button(this.isListening ? '停止' : '开始')
          .width(80)
          .backgroundColor(this.isListening ? '#E84335' : '#4CAF50')
          .onClick(() => {
            if (this.isListening) {
              this.stopListening();
            } else {
              this.startListening();
            }
          })
      }
      .width('90%')
      .margin({ bottom: 20 })

      // 天气信息列表
      Column() {
        Row() {
          Text('已接收的天气信息')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Blank()
          Button('清除')
            .fontSize(14)
            .onClick(() => {
              this.clearWeatherInfos();
            })
        }
        .width('100%')
        .margin({ bottom: 10 })

        List() {
          ForEach(this.weatherInfos, (item: WeatherInfo) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.city)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                  Blank()
                  Text(new Date(item.timestamp).toLocaleTimeString())
                    .fontSize(14)
                    .fontColor(Color.Gray)
                }
                .width('100%')

                Row() {
                  Text(`${item.temperature}°C`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                  Text(item.weather)
                    .fontSize(16)
                    .margin({ left: 10 })
                }
                .width('100%')
                .margin({ top: 5 })

                Row() {
                  Text(`湿度: ${item.humidity}%`)
                    .fontSize(14)
                  Blank()
                  Text(`风速: ${item.windSpeed}m/s`)
                    .fontSize(14)
                }
                .width('100%')
                .margin({ top: 5 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
            }
            .margin({ bottom: 10 })
          })
        }
        .width('100%')
        .layoutWeight(1)

        if (this.weatherInfos.length === 0) {
          Text('暂无天气信息')
            .fontSize(16)
            .fontColor(Color.Gray)
            .margin(20)
        }
      }
      .width('90%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}