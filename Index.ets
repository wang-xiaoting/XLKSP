// import { webview } from '@kit.ArkWeb';
//
// @Entry
// @Component
// struct Index {
//   @State message: string = 'Hello World';
//   private webviewController: webview.WebviewController = new webview.WebviewController();
//
//   // 简单的本地HTML测试内容
//   private localHtml: string = '<html><body><h1>测试Web组件</h1><p>这是本地HTML内容</p></body></html>';
//
//   build() {
//     Column() {
//       Text('Web组件测试').fontSize(20).margin(10)
//
//       // 尝试加载本地HTML内容
//       Button('加载本地HTML')
//         .margin(10)
//         .onClick(() => {
//           this.webviewController.loadUrl($rawfile('index.html'));
//         })
//
//       // 尝试加载百度网页
//       Button('加载百度')
//         .margin(10)
//         .onClick(() => {
//           this.webviewController.loadUrl('https://www.baidu.com');
//         })
//
//       Web({
//         controller: this.webviewController,
//         src: ''
//       })
//         .width('100%')
//         .userAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36')
//         .domStorageAccess(true)
//         .fileAccess(true)
//         .databaseAccess(true)
//         .onPageBegin((url: OnPageBeginEvent) => {
//           console.info('网页开始加载: ' + url);
//         })
//         .onPageEnd((url: OnPageEndEvent) => {
//           console.info('网页加载完成: ' + url);
//         })
//         .onErrorReceive((err:OnErrorReceiveEvent)=>{
//             console.error(`onErrorReceive ${err.request}`)
//         })
//         .layoutWeight(1)
//
//     }
//     .width('100%')
//     .height('100%')
//   }
// }