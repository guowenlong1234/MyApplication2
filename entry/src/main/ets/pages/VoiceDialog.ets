import { VoiceService } from '../model/VoiceService';
import { AppModel, AppItem } from '../model/AppModel';

@CustomDialog
export struct VoiceDialog {
  controller?: CustomDialogController;
  launchApp: (item: AppItem) => void = () => {};

  @State tips: string = "请说话...";
  @State tipsColor: string = '#FFFFFF';

  // 声波高度
  @State h1: number = 10;
  @State h2: number = 20;
  @State h3: number = 30;
  @State h4: number = 20;
  @State h5: number = 10;

  private voiceService = new VoiceService();
  private fakeTimer: number = -1;

  aboutToAppear() {
    this.startForcedDemo();
  }

  aboutToDisappear() {
    clearInterval(this.fakeTimer);
  }

  async startForcedDemo() {
    this.tips = "正在聆听(5秒)...";


    this.fakeTimer = setInterval(() => {
      // 随机生成高度
      this.h3 = Math.random() * 64 + 24;
      this.h2 = Math.random() * 48 + 16;
      this.h4 = Math.random() * 48 + 16;
      this.h1 = Math.random() * 24 + 8;
      this.h5 = Math.random() * 24 + 8;
    }, 150); // 频率稍微放慢一点点

    // 尝试调用底层服务 (仅走流程)
    this.voiceService.startRecording((vol) => {}).catch(() => {});


    setTimeout(async () => {
      clearInterval(this.fakeTimer);
      // 归位
      this.h1=10; this.h2=10; this.h3=10; this.h4=10; this.h5=10;

      this.tips = "正在识别...";
      this.tipsColor = '#FFD700';

      setTimeout(() => {
        this.handleForceSuccess();
      }, 1000);
    }, 5000);
  }

  handleForceSuccess() {
    this.tips = "打开设置";
    this.tipsColor = '#00E079';

    setTimeout(() => {
      this.controller?.close();
      this.launchApp({
        name: 'com.ohos.settings',
        label: '系统设置',
        icon: $r('app.media.app_icon'),
        abilityName: 'com.ohos.settings.MainAbility'
      });
    }, 1500);
  }

  build() {
    Column() {
      // 声波条
      Row({ space: 8 }) {

        Column()
          .width(10).height(this.h1).backgroundColor('#007DFA').borderRadius(5)
          .animation({ duration: 150, curve: Curve.Linear }) // 自带动画属性

        Column()
          .width(10).height(this.h2).backgroundColor('#007DFA').borderRadius(5)
          .animation({ duration: 150, curve: Curve.Linear })

        Column()
          .width(10).height(this.h3).backgroundColor('#007DFA').borderRadius(5)
          .animation({ duration: 150, curve: Curve.Linear })

        Column()
          .width(10).height(this.h4).backgroundColor('#007DFA').borderRadius(5)
          .animation({ duration: 150, curve: Curve.Linear })

        Column()
          .width(10).height(this.h5).backgroundColor('#007DFA').borderRadius(5)
          .animation({ duration: 150, curve: Curve.Linear })
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
}