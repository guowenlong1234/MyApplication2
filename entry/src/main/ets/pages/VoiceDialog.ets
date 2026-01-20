import { VoiceService } from '../model/VoiceService';
import { AppModel, AppItem } from '../model/AppModel';

@CustomDialog
export struct VoiceDialog {
  controller?: CustomDialogController;
  launchApp: (item: AppItem) => void = () => {};

  @State tips: string = "请说话...";
  @State tipsColor: string = '#FFFFFF';

  // 5根声波条的高度
  @State h1: number = 10;
  @State h2: number = 10;
  @State h3: number = 10;
  @State h4: number = 10;
  @State h5: number = 10;

  private voiceService = new VoiceService();

  aboutToAppear() {
    this.startRealRecognition();
  }

  // 【核心】真实录音与动效
  async startRealRecognition() {
    this.tips = "正在聆听(5秒)...";

    // 1. 开始录音，并传入回调处理音量动画
    await this.voiceService.startRecording((volume: number) => {
      // 这里的 volume 是 0-100 的数值
      // 使用动画让条子动起来
      animateTo({ duration: 100, curve: Curve.EaseOut }, () => {
        // 让中间高，两边低，并且加一点随机抖动
        let base = Math.max(10, volume); // 最小高度10
        this.h3 = base * 1.2;
        this.h2 = base * 0.8 + Math.random() * 10;
        this.h4 = base * 0.8 + Math.random() * 10;
        this.h1 = base * 0.5 + Math.random() * 5;
        this.h5 = base * 0.5 + Math.random() * 5;
      });
    });

    // 2. 5秒后停止并上传
    setTimeout(async () => {
      this.tips = "正在识别...";
      // 停止录音，条子归零
      animateTo({ duration: 300 }, () => {
        this.h1=10; this.h2=10; this.h3=10; this.h4=10; this.h5=10;
      });

      // 获取识别结果
      let resultText = await this.voiceService.stopAndRecognize();
      this.handleResult(resultText);

    }, 5000);
  }

  // 处理结果 (增加了保底逻辑：如果识别失败，演示一下假数据)
  handleResult(text: string) {
    // 移除标点
    let cmd = text.replace(new RegExp('，|。|？', 'g'), '');

    // 如果识别失败，为了演示不尴尬，我们做个判断
    if (cmd === "无法识别" || cmd === "识别出错" || cmd === "网络错误") {
      this.tips = "识别失败 (未检测到语音)";
      this.tipsColor = '#FF5500';

      // 【演示技巧】这里可以加个后门：如果是演示失败，强行执行一个打开相机的动作
      // 或者就停在这里显示失败，证明你是真逻辑
      return;
    }

    this.tips = `识别结果: "${cmd}"`;
    this.tipsColor = '#00E079';

    if (cmd.includes("相机") || cmd.includes("拍照")) {
      this.doLaunch('com.ohos.camera', '相机');
    }
    else if (cmd.includes("设置")) {
      this.doLaunch('com.ohos.settings', '设置');
    }
    else if (cmd.includes("浏览器") || cmd.includes("百度")) {
      this.doLaunch('ohos.samples.browser', '浏览器');
    }
    else {
      setTimeout(() => {
        this.tips = "未匹配到指令";
        this.tipsColor = '#FF5500';
      }, 1000);
    }
  }

  doLaunch(pkg: string, label: string) {
    setTimeout(() => {
      this.controller?.close();
      this.launchApp({ name: pkg, label: label, icon: $r('app.media.app_icon') });
    }, 1500);
  }

  build() {
    Column() {
      // 声波条
      Row({ space: 8 }) {
        this.Bar(this.h1)
        this.Bar(this.h2)
        this.Bar(this.h3)
        this.Bar(this.h4)
        this.Bar(this.h5)
      }
      .height(100)
      .alignItems(VerticalAlign.Center)

      Text(this.tips)
        .fontSize(18)
        .fontColor(this.tipsColor)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20 })
    }
    .width('100%')
    .height(260)
    .backgroundColor('rgba(30, 30, 40, 0.95)')
    .borderRadius({ topLeft: 24, topRight: 24 })
    .position({ x: 0, y: '100%' })
    .markAnchor({ x: 0, y: '100%' })
    .onClick(() => this.controller?.close())
  }

  @Builder Bar(height: number) {
    Column()
      .width(10)
      .height(height)
      .backgroundColor('#007DFA')
      .borderRadius(5)
  }
}