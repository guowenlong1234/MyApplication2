import deviceManager from '@ohos.distributedHardware.deviceManager';
import { BusinessError } from '@ohos.base';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: number;
}

export class DeviceService {
  // 显式声明类型，或者是 any
  private dmInstance: any = null;
  private bundleName = 'com.student.desktop'; // 确保和你 app.json5 里的一致

  // 初始化设备管理器
  initDM(onDeviceFound: (device: DeviceInfo) => void): void {
    try {
      // 【修改点】给回调参数加上类型声明
      deviceManager.createDeviceManager(this.bundleName, (err: BusinessError, data: any) => {
        if (err) {
          console.error(`[SoftBus] 创建DM失败: ${err.code} - ${err.message}`);
          return;
        }
        this.dmInstance = data;
        console.info('[SoftBus] DM创建成功');

        // 注册设备发现监听
        // 【修改点】data 类型设为 any，防止结构不匹配报错
        this.dmInstance.on('deviceFound', (data: any) => {
          // 【重要】真实的设备信息通常在 data.deviceInfo 里
          // 如果 data.deviceInfo 为空，则可能是 data 本身 (视版本而定)
          let info = data.deviceInfo ? data.deviceInfo : data;

          console.info(`[SoftBus] 发现: ${info.deviceName}, ID: ${info.deviceId}`);

          // 回调通知 UI
          onDeviceFound({
            deviceId: info.deviceId,
            deviceName: info.deviceName,
            // 注意：有的版本叫 deviceType，有的叫 deviceTypeId
            deviceType: info.deviceTypeId !== undefined ? info.deviceTypeId : info.deviceType
          });
        });

        // 开始搜索
        this.startDiscovery();
      });
    } catch (e) {
      // 捕获 BusinessError
      let err = e as BusinessError;
      console.error(`[SoftBus] 初始化异常: ${err.message}`);
    }
  }

  // 开始发现周边设备
  startDiscovery(): void {
    if (!this.dmInstance) return;

    // 发现参数
    let discoverParam = {
      subscribeId: 100,
      mode: 0xAA,       // 主动发现
      medium: 2,        // WiFi
      freq: 1,
      isSameAccount: false,
      isWakeRemote: false,
      capability: 0
    };

    try {
      // 【修改点】as any 绕过参数类型检查
      this.dmInstance.startDeviceDiscovery(discoverParam as any);
      console.info('[SoftBus] 开始雷达扫描...');
    } catch (error) {
      let err = error as BusinessError;
      console.error(`[SoftBus] 搜索失败 code:${err.code}, message:${err.message}`);
    }
  }

  // 停止发现
  stopDiscovery(): void {
    try {
      this.dmInstance?.stopDeviceDiscovery(100);
    } catch(e) {}
  }
}