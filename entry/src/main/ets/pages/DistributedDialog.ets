import { DeviceService, DeviceInfo } from '../model/DeviceService';

@CustomDialog
export struct DistributedDialog {
  controller?: CustomDialogController;

  // 1. 动画状态
  @State scaleRing1: number = 1;
  @State scaleRing2: number = 1;
  @State opacityRing: number = 0.8;

  // 2. 【修复点】补上这俩缺失的状态变量！
  @State isPhoneConnected: boolean = false;
  @State isPadConnected: boolean = false;

  // 3. 真实设备列表
  @State realDevices: Array<DeviceInfo> = [];

  // 4. 服务实例
  private deviceService = new DeviceService();

  aboutToAppear() {
    this.startRadarAnimation();
    // 启动真实搜索
    this.deviceService.initDM((device) => {
      // 去重逻辑
      if (!this.realDevices.find(d => d.deviceId === device.deviceId)) {
        this.realDevices.push(device);
      }
    });
  }

  aboutToDisappear() {
    this.deviceService.stopDiscovery();
  }

  startRadarAnimation() {
    // 第一圈
    animateTo({ duration: 2000, iterations: -1, curve: Curve.EaseOut }, () => {
      this.scaleRing1 = 4;
      this.opacityRing = 0;
    })
    // 第二圈
    setTimeout(() => {
      animateTo({ duration: 2000, iterations: -1, curve: Curve.EaseOut }, () => {
        this.scaleRing2 = 4;
      })
    }, 1000);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {

      // === 1. 背景层 ===
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(20, 20, 30, 0.85)')
        .backdropBlur(30)
        .onClick(() => this.controller?.close())

      // === 2. 标题 ===
      Column() {
        Text("超级终端")
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 50 })
        Text("拖拽或点击设备以协同")
          .fontSize(14).fontColor('rgba(255,255,255,0.6)').margin({ top: 8 })
      }
      .position({ x: 0, y: 0 })
      .width('100%').alignItems(HorizontalAlign.Center)

      // === 3. 雷达波纹 ===
      // 波纹 1
      Circle()
        .width(150).height(150)
        .fill(Color.Transparent) // 不填充颜色
        .stroke('rgba(255, 255, 255, 0.8)') // 边框：亮白色
        .strokeWidth(2) // 边框宽度
        .scale({ x: this.scaleRing1, y: this.scaleRing1 })
        .opacity(this.opacityRing)
        .zIndex(1) // 确保在背景之上

      // 波纹 2
      Circle()
        .width(150).height(150)
        .fill(Color.Transparent)
        .stroke('rgba(255, 255, 255, 0.6)') // 稍微淡一点
        .strokeWidth(2)
        .scale({ x: this.scaleRing2, y: this.scaleRing2 })
        .opacity(this.opacityRing)
        .zIndex(1)
      // === 4. 中心本机 ===
      Column() {
        Image($r('app.media.RVbook')) // 换成 ic_device_pc
          .width(80).height(80).borderRadius(40)
          .border({ width: 2, color: 'rgba(255,255,255,0.5)' })
        Text("RVBook").fontSize(14).fontColor(Color.White).margin({ top: 10 })
      }
      .zIndex(2)

      // === 5. 真实设备渲染 ===
      ForEach(this.realDevices, (device: DeviceInfo, index: number) => {
        Column() {
          Image($r('app.media.app_icon')).width(50).height(50).borderRadius(25)
          Text(device.deviceName).fontSize(12).fontColor(Color.White).margin({ top: 5 })
        }
        .position(this.getPosition(index))
        .onClick(() => {
          AlertDialog.show({ message: `正在连接真实设备：${device.deviceName}` });
        })
      })

      // === 6. 保底模拟设备 (当搜不到真设备时显示) ===
      if (this.realDevices.length === 0) {
        // [模拟手机]
        Column() {
          Image($r('app.media.phone')).width(50).height(50).borderRadius(25)
            .opacity(this.isPhoneConnected ? 0.5 : 1)
          Text("演示: Mate 60").fontSize(12).fontColor(Color.White).margin({ top: 5 })
        }
        .position({ x: '20%', y: '30%' }) // 左上角
        .onClick(() => this.connectDevice('Mate 60', true)) // 点击触发连接
        // 关键动画：连接时吸附到中心 (x:150, y:100 是大致偏移量)
        .translate(this.isPhoneConnected ? { x: 150, y: 100 } : { x: 0, y: 0 })
        .animation({ duration: 500, curve: Curve.FastOutSlowIn })

        // [模拟平板]
        Column() {
          Image($r('app.media.pad')).width(60).height(60).borderRadius(30)
            .opacity(this.isPadConnected ? 0.5 : 1)
          Text("演示: MatePad").fontSize(12).fontColor(Color.White).margin({ top: 5 })
        }
        .position({ x: '70%', y: '60%' }) // 右下角
        .onClick(() => this.connectDevice('MatePad', false))
        .translate(this.isPadConnected ? { x: -100, y: -100 } : { x: 0, y: 0 })
        .animation({ duration: 500, curve: Curve.FastOutSlowIn })
      }

    }
    .width('100%').height('100%')
  }

  getPosition(index: number): Position {
    // 简单排布
    if (index === 0) return { x: '20%', y: '30%' };
    if (index === 1) return { x: '70%', y: '60%' };
    return { x: '50%', y: '70%' };
  }

  // 模拟连接逻辑
  connectDevice(name: string, isPhone: boolean): void {
    // 1. 播放吸附动画
    if (isPhone) this.isPhoneConnected = true;
    else this.isPadConnected = true;

    let that = this; // 暂存 this

    // 2. 弹出提示
    AlertDialog.show({
      title: '正在协同',
      message: `正在与 ${name} 建立分布式连接...`,
      confirm: {
        value: '断开',
        action: () => {
          // 在回调里恢复状态
          if (isPhone) that.isPhoneConnected = false;
          else that.isPadConnected = false;
        }
      }
    });
  }
}