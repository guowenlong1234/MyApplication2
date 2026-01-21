import { DeviceService, DeviceInfo } from '../model/DeviceService';

@CustomDialog
export struct DistributedDialog {
  controller?: CustomDialogController;

  // 两个波纹的缩放和透明度状态
  @State scale1: number = 1;
  @State opacity1: number = 1;

  @State scale2: number = 1;
  @State opacity2: number = 1;

  @State isPhoneConnected: boolean = false;
  @State isPadConnected: boolean = false;
  @State realDevices: Array<DeviceInfo> = [];

  private deviceService = new DeviceService();

  aboutToAppear() {

    this.runWave1();

    setTimeout(() => { this.runWave2(); }, 1000);

    try {
      this.deviceService.initDM((device) => {
        if (!this.realDevices.find(d => d.deviceId === device.deviceId)) {
          this.realDevices.push(device);
        }
      });
    } catch(e) {}
  }

  aboutToDisappear() {
    this.deviceService.stopDiscovery();
  }


  runWave1() {

    this.scale1 = 1;
    this.opacity1 = 1;

    // 2. 启动扩散动画
    animateTo({
      duration: 2000,
      curve: Curve.EaseOut,
      onFinish: () => {

        this.runWave1();
      }
    }, () => {
      this.scale1 = 4;
      this.opacity1 = 0;
    })
  }

  // 波纹 2 循环 (同理)
  runWave2() {
    this.scale2 = 1;
    this.opacity2 = 1;
    animateTo({
      duration: 2000,
      curve: Curve.EaseOut,
      onFinish: () => { this.runWave2(); }
    }, () => {
      this.scale2 = 4;
      this.opacity2 = 0;
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {

      // 1. 背景
      Column()
        .width('100%').height('100%')
        .backgroundColor('rgba(20, 20, 30, 0.9)')
        .backdropBlur(30)
        .onClick(() => this.controller?.close())

      // 2. 标题
      Column() {
        Text("超级终端")
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 50 })
        Text("拖拽或点击设备以协同")
          .fontSize(14).fontColor('rgba(255,255,255,0.6)').margin({ top: 8 })
      }
      .position({ x: 0, y: 0 })
      .width('100%').alignItems(HorizontalAlign.Center)


      Stack() {
        // 圈 1
        Circle()
          .width(350).height(350)
          .fill(Color.Transparent)
          .stroke('rgba(255, 255, 255, 0.5)')
          .strokeWidth(5)
          .scale({ x: this.scale1, y: this.scale1 })
          .opacity(this.opacity1)

        // 圈 2
        Circle()
          .width(350).height(350) //
          .fill(Color.Transparent)
          .stroke('rgba(255, 255, 255, 0.3)')
          .strokeWidth(5)
          .scale({ x: this.scale2, y: this.scale2 })
          .opacity(this.opacity2)
      }
      .width('100%').height('100%')
      .alignContent(Alignment.Center)
      .hitTestBehavior(HitTestMode.None)


      // === 4. 中心设备 (RVBook) ===
      Column() {
        Image($r('app.media.RVbook'))
          .width(120).height(120).objectFit(ImageFit.Contain)
        Text("RVBook").fontSize(16).fontColor(Color.White).margin({ top: 10 })
      }
      .zIndex(2)

      // === 5. 真实设备渲染 ===
      ForEach(this.realDevices, (device: DeviceInfo, index: number) => {
        Column() {
          Image($r('app.media.phone')).width(80).height(80).objectFit(ImageFit.Contain)
          Text(device.deviceName).fontSize(14).fontColor(Color.White).margin({ top: 5 })
        }
        .position(this.getPosition(index))
        .onClick(() => {
          AlertDialog.show({ message: `正在连接：${device.deviceName}` });
        })
      })

      // === 6. 模拟设备 ===
      if (this.realDevices.length === 0) {
        // [模拟手机]
        Column() {
          Image($r('app.media.phone'))
            .width(80).height(80).objectFit(ImageFit.Contain)
            .opacity(this.isPhoneConnected ? 0.5 : 1)
          Text("Mate 60 Pro").fontSize(14).fontColor(Color.White).margin({ top: 5 })
        }
        .position({ x: '15%', y: '25%' })
        .onClick(() => this.connectDevice('Mate 60', true))
        .translate(this.isPhoneConnected ? { x: 200, y: 120 } : { x: 0, y: 0 })
        .animation({ duration: 500, curve: Curve.FastOutSlowIn })

        // [模拟平板]
        Column() {
          Image($r('app.media.pad'))
            .width(90).height(90).objectFit(ImageFit.Contain)
            .opacity(this.isPadConnected ? 0.5 : 1)
          Text("MatePad Pro").fontSize(14).fontColor(Color.White).margin({ top: 5 })
        }
        .position({ x: '70%', y: '55%' })
        .onClick(() => this.connectDevice('MatePad', false))
        .translate(this.isPadConnected ? { x: -150, y: -100 } : { x: 0, y: 0 })
        .animation({ duration: 500, curve: Curve.FastOutSlowIn })
      }
    }
    .width('100%').height('100%')
  }

  getPosition(index: number): Position {
    if (index === 0) return { x: '15%', y: '25%' };
    return { x: '70%', y: '55%' };
  }

  connectDevice(name: string, isPhone: boolean): void {
    if (isPhone) this.isPhoneConnected = true;
    else this.isPadConnected = true;

    let that = this;
    AlertDialog.show({
      title: '正在协同',
      message: `正在与 ${name} 建立分布式连接...`,
      confirm: {
        value: '断开',
        action: () => {
          if (isPhone) that.isPhoneConnected = false;
          else that.isPadConnected = false;
        }
      }
    });
  }
}