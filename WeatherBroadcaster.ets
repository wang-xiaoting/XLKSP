// WeatherBroadcaster.ets - UDP发送端
import socket from '@ohos.net.socket';
import util from '@ohos.util';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { WeatherInfo } from '../viewmodel/WeatherInfo'

@Entry
@Component
struct WeatherBroadcaster {
  @State ip: string = '';
  @State cityName: string = '北京';
  @State temperature: string = '25';
  @State weather: string = '晴';
  @State humidity: string = '40';
  @State windSpeed: string = '3';
  @State broadcastPort: string = '8089';
  @State broadcastInterval: number = 5; // 广播间隔(秒)
  @State status: string = '未启动';
  @State isBroadcasting: boolean = false;
  private udpSocket: socket.UDPSocket | null = null;
  private timer: number = -1;
  private broadcastAddress: string = '0.0.0.0'; // 广播地址

  aboutToAppear() {
    // 创建UDP Socket
    this.udpSocket = socket.constructUDPSocketInstance();
  }

  aboutToDisappear() {
    this.stopBroadcast();
  }

  // 开始广播天气信息
  startBroadcast() {
    if (this.isBroadcasting) {
      promptAction.showToast({ message: '已在广播中' });
      return;
    }

    // 绑定一个随机端口
    this.udpSocket?.bind({ address: '0.0.0.0', port: 0, family: 1 })
      .then(() => {
        this.isBroadcasting = true;
        this.status = '广播中...';

        // 定时广播
        this.timer = setInterval(() => {
          this.broadcastWeatherInfo();
        }, this.broadcastInterval * 1000);

        // 立即发送一次
        this.broadcastWeatherInfo();

        promptAction.showToast({ message: '开始广播天气信息' });
      })
      .catch((err: BusinessError) => {
        this.status = '启动失败: ' + JSON.stringify(err);
        promptAction.showToast({ message: '启动广播失败' });
      });
  }

  // 停止广播
  stopBroadcast() {
    if (!this.isBroadcasting) {
      return;
    }

    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }

    if (this.udpSocket) {
      this.udpSocket.close()
        .then(() => {
          this.udpSocket = socket.constructUDPSocketInstance();
          this.isBroadcasting = false;
          this.status = '已停止';
          promptAction.showToast({ message: '已停止广播' });
        })
        .catch((err: BusinessError) => {
          this.status = '停止失败: ' + JSON.stringify(err);
        });
    }
  }

  // 广播天气信息
  broadcastWeatherInfo() {
    console.debug(`broadcastWeatherInfo`);
    if (!this.udpSocket || !this.isBroadcasting) {
      return;
    }

    // 构建天气信息
    const weatherData: WeatherInfo = {
      type: 'weather_info',
      city: this.cityName,
      temperature: parseInt(this.temperature),
      weather: this.weather,
      humidity: parseInt(this.humidity),
      windSpeed: parseInt(this.windSpeed),
      timestamp: Date.now()
    };

    // 发送数据
    this.udpSocket.send({
      data: JSON.stringify(weatherData),
      address: {
        address: this.broadcastAddress, // 广播地址
        port: parseInt(this.broadcastPort)
      }
    })
      .then(() => {
        console.info('天气信息广播成功');
        this.status = '上次广播: ' + new Date().toLocaleTimeString();
      })
      .catch((err: BusinessError) => {
        console.error('天气信息广播失败:', JSON.stringify(err));
        this.status = '广播失败: ' + JSON.stringify(err);
      });
  }

  build() {
    Column() {
      // 标题
      Text('天气信息广播器')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin(20)

      // 状态显示
      Text('状态: ' + this.status)
        .fontSize(16)
        .fontColor(this.isBroadcasting ? Color.Green : Color.Gray)
        .margin({ bottom: 20 })

      // 设置区域
      Scroll() {
        Column() {
          // 城市设置
          Row() {
            Text('城市:')
              .width(80)
            TextInput({ text: this.cityName })
              .width('70%')
              .onChange((value) => {
                this.cityName = value;
              })
          }
          .width('90%')
          .margin(10)

          // 温度设置
          Row() {
            Text('温度(°C):')
              .width(80)
            TextInput({ text: this.temperature })
              .width('70%')
              .type(InputType.Number)
              .onChange((value) => {
                this.temperature = value;
              })
          }
          .width('90%')
          .margin(10)

          // 天气设置
          Row() {
            Text('天气:')
              .width(80)
            TextInput({ text: this.weather })
              .width('70%')
              .onChange((value) => {
                this.weather = value;
              })
          }
          .width('90%')
          .margin(10)

          // 湿度设置
          Row() {
            Text('湿度(%):')
              .width(80)
            TextInput({ text: this.humidity })
              .width('70%')
              .type(InputType.Number)
              .onChange((value) => {
                this.humidity = value;
              })
          }
          .width('90%')
          .margin(10)

          // 风速设置
          Row() {
            Text('风速(m/s):')
              .width(80)
            TextInput({ text: this.windSpeed })
              .width('70%')
              .type(InputType.Number)
              .onChange((value) => {
                this.windSpeed = value;
              })
          }
          .width('90%')
          .margin(10)

          // 广播端口设置
          Row() {
            Text('广播端口:')
              .width(80)
            TextInput({ text: this.broadcastPort })
              .width('70%')
              .type(InputType.Number)
              .onChange((value) => {
                this.broadcastPort = value;
              })
          }
          .width('90%')
          .margin(10)

          // 广播间隔设置
          Row() {
            Text('广播间隔(秒):')
              .width(80)
            Slider({
              min: 1,
              max: 30,
              step: 1,
              value: this.broadcastInterval
            })
              .width('50%')
              .onChange((value) => {
                this.broadcastInterval = value;
              })
            Text(this.broadcastInterval.toString())
              .width(40)
          }
          .width('90%')
          .margin(10)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)

      // 操作按钮
      Row() {
        Button(this.isBroadcasting ? '停止广播' : '开始广播')
          .width('80%')
          .height(50)
          .backgroundColor(this.isBroadcasting ? '#E84335' : '#4CAF50')
          .onClick(() => {
            if (this.isBroadcasting) {
              this.stopBroadcast();
            } else {
              this.startBroadcast();
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}