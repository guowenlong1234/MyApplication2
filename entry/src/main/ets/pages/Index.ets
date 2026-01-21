import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { AppModel, AppItem } from '../model/AppModel'
import { SearchDialog } from './SearchDialog'
import { DistributedDialog } from './DistributedDialog';
import { NotificationPanel } from './NotificationPanel';
import { VoiceDialog } from './VoiceDialog';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { StartMenu } from './StartMenu';
@Entry
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext;
  private model = new AppModel();
  notifyController: CustomDialogController = new CustomDialogController({
    builder: NotificationPanel({}),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.TopEnd, // 靠右上角
    offset: { dx: 0, dy: 0 }
  });

  // 语音助手控制器 (底部弹起)
  voiceController: CustomDialogController = new CustomDialogController({
    builder: VoiceDialog({
      launchApp: (item: AppItem) => this.launchApp(item)
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Bottom // 靠底部
  });
  // 1. 定义应用列表数据
  @State appList: Array<AppItem> = [];
  searchController: CustomDialogController = new CustomDialogController({
    builder: SearchDialog({
      appList: $appList,
      launchApp: (item: AppItem) => this.launchApp(item)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  // 开始菜单控制器
  startMenuController: CustomDialogController = new CustomDialogController({
    builder: StartMenu({
      appList: $appList,
      launchApp: (item: AppItem) => this.launchApp(item)
    }),
    autoCancel: true,
    customStyle: true,

    alignment: DialogAlignment.BottomStart,
    offset: { dx: 10, dy: -60 }
  });

  // 超级终端控制器
  distController: CustomDialogController = new CustomDialogController({
    builder: DistributedDialog({}),
    autoCancel: true,
    customStyle: true, // 全屏沉浸式
    alignment: DialogAlignment.Center
  });
  // 2. 定义时间状态 (修复标黄)
  @State currentTime: string = '12:00';
  @State currentDate: string = '2024/01/20';
  private timerId: number = -1;

  aboutToAppear() {
    // 加载应用白名单
    this.requestMicPermission();
    this.appList = this.model.getAppList();

    // 初始化时间并启动定时器
    this.updateTime();
    this.timerId = setInterval(() => {
      this.updateTime();
    }, 1000);
  }
  requestMicPermission() {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context, ['ohos.permission.MICROPHONE'])
        .then((data) => {
          console.info('麦克风权限申请成功');
        })
        .catch((err: BusinessError) => {
          console.error('麦克风权限申请失败: ' + JSON.stringify(err));
        });
    } catch (err) {
      console.error('权限申请异常');
    }
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  // 更新时间逻辑
  updateTime() {
    let now = new Date();
    let hours = now.getHours().toString().padStart(2, '0');
    let minutes = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}`;
    this.currentDate = `${now.getFullYear()}/${now.getMonth() + 1}/${now.getDate()}`;
  }
  @Builder TaskbarItem(bundleName: string, icon: Resource): void {
    Column() {
      Image(icon)
        .width(26) // 图标做小一点
        .height(26)
    }
    .width(40) // 点击热区宽度
    .height(40) // 点击热区高度
    .justifyContent(FlexAlign.Center)
    .borderRadius(4)
    .stateStyles({
      pressed: { .backgroundColor('rgba(255,255,255,0.1)') },
      normal: { .backgroundColor(Color.Transparent) }
    })
    .margin({ left: 2, right: 2 })
    .onClick(() => {
      if (bundleName === 'distributed') {
        this.distController.open();
      } else {
        this.launchApp({ name: bundleName, label: 'TaskApp', icon: icon });
      }
    })
  }
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.wallpaper'))
        .backgroundImageSize(ImageSize.Cover)

      Column() {
        Grid() {
          ForEach(this.appList, (item: AppItem) => {
            GridItem() {
              Column() {
                Image(item.icon)
                  .width(60)
                  .height(60)
                  .borderRadius(12)
                  .margin({ bottom: 8 })
                  .backgroundColor('rgba(255,255,255,0.15)')
                  .padding(5)

                Text(item.label)
                  .fontSize(15)
                  .fontColor(Color.White)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

               }
              .width(80)
              .height(100)
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.launchApp(item))
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(15)
        .padding({ top: 40, left: 30, right: 30 })
        .height('85%')
      }
      .width('100%')
      .height('100%')


      Row() {
        Row() {

          Image($r('app.media.win11'))
            .width(24)
            .height(24)
            .margin({ left: 15, right: 15 })
            .onClick(() => {
              this.startMenuController.open();
            })


          Row() {
            Image($r('app.media.browser'))
              .width(16).height(16)
              .margin({ right: 10 })
              .opacity(0.6)

            Text("在这里输入你要搜索的内容")
              .fontSize(12)
              .fontColor('#666')
          }
          .height(32)
          .width(220)
          .backgroundColor(Color.White)
          .borderRadius(4)
          .padding({ left: 10 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.searchController.open();
          })
        }

        // --- B. 常用应用栏 (紧跟搜索框) ---
        Row() {

          Image($r('app.media.mic'))
            .width(26)
            .height(26)
            .margin({ left: 12 })
            .onClick(() => {
              this.voiceController.open();
            })
          Column() {
            Image($r('app.media.connect'))
              .width(28).height(28)
              .fillColor(Color.White)
          }
          .width(44).height(44)
          .backgroundColor('#0A59F7')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .margin({ left: 10 })
          .shadow({ radius: 10, color: 'rgba(10, 89, 247, 0.5)' })
          .onClick(() => {
            this.distController.open();
          })



          this.TaskbarItem('com.ohos.settings', $r('app.media.settings'))
          this.TaskbarItem('com.ohos.filepicker', $r('app.media.icon'))
          this.TaskbarItem('ohos.samples.browser', $r('app.media.browser'))


        }
        .margin({ left: 10 })


        Blank()


        Row() {

          Text("∧").fontSize(14).fontColor(Color.White).margin({ right: 10 })


          Image($r('app.media.wifi'))
            .width(18).height(18)
            .objectFit(ImageFit.Contain)
            .fillColor(Color.White)
            .margin({ right: 8 })


          Image($r('app.media.bluetooth'))
            .width(18).height(18)
            .objectFit(ImageFit.Contain)
            .fillColor(Color.White)
            .margin({ right: 8 })


          Image($r('app.media.battery'))
            .width(22).height(22)
            .objectFit(ImageFit.Contain)
            .fillColor(Color.White)
            .margin({ right: 10 })


          Column() {
            Text(this.currentTime).fontSize(12).fontColor(Color.White)
            Text(this.currentDate).fontSize(10).fontColor(Color.White)
          }
          .alignItems(HorizontalAlign.End)
        }
        .padding({ right: 15 })
        .height('100%')

        .onClick(() => {
          console.info('打开通知中心');
          this.notifyController.open();
        })
        .padding({ right: 15 })
        .height('100%')


      }
      .width('100%')
      .height(48)
      .backgroundColor('rgba(30, 30, 30, 0.95)')

      .position({ y: '100%' })
      .translate({ y: -48 }) // 修正位置
      .alignItems(VerticalAlign.Center)
    }
  }


  @Builder DockItem(bundleName: string, icon: Resource): void {
    Column() {
      Image(icon)
        .width(45)
        .height(45)
        .borderRadius(10)
        .backgroundColor('white')
        .padding(5)
    }
    .width(55)
    .height(55)
    .justifyContent(FlexAlign.Center)
    .margin({ left: 5, right: 5 })
    .onClick(() => {

      this.launchApp({ name: bundleName, label: 'DockApp', icon: icon });
    })
  }

  // 启动应用逻辑
  launchApp(item: AppItem): void {
    console.info(`尝试启动: ${item.label} (${item.name})`);

    if (item.name === 'distributed.center') {
      this.distController.open();
      return;
    }


    let want: Want = {
      bundleName: item.name,
      abilityName: item.abilityName
    };


    console.info(`启动参数: bundle=${want.bundleName}, ability=${want.abilityName}`);

    this.context.startAbility(want).catch((err: BusinessError) => {
      console.error(`启动失败: ${JSON.stringify(err)}`);


      if (want.abilityName) {
        console.warn("尝试降级启动（只传包名）...");
        let wantBackup: Want = { bundleName: item.name };
        this.context.startAbility(wantBackup).catch((err2: BusinessError) => {
          AlertDialog.show({ message: `无法启动 ${item.label}\n${err2.message}` });
        });
      } else {
        AlertDialog.show({ message: `无法启动 ${item.label}\n${err.message}` });
      }
    });
  }
  }
