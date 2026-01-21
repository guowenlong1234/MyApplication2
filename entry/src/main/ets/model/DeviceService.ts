import deviceManager from '@ohos.distributedHardware.deviceManager';
import { BusinessError } from '@ohos.base';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: number;
}

export class DeviceService {

  private dmInstance: any = null;
  private bundleName = 'com.student.desktop';

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


        this.dmInstance.on('deviceFound', (data: any) => {

          let info = data.deviceInfo ? data.deviceInfo : data;

          console.info(`[SoftBus] 发现: ${info.deviceName}, ID: ${info.deviceId}`);


          onDeviceFound({
            deviceId: info.deviceId,
            deviceName: info.deviceName,
            deviceType: info.deviceTypeId !== undefined ? info.deviceTypeId : info.deviceType
          });
        });

        // 开始搜索
        this.startDiscovery();
      });
    } catch (e) {

      let err = e as BusinessError;
      console.error(`[SoftBus] 初始化异常: ${err.message}`);
    }
  }


  startDiscovery(): void {
    if (!this.dmInstance) return;

    let discoverParam = {
      subscribeId: 100,
      mode: 0xAA,
      medium: 2,
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