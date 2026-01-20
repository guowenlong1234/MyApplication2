import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { AppModel, AppItem } from '../model/AppModel'
import { SearchDialog } from './SearchDialog'
import { DistributedDialog } from './DistributedDialog';
import { NotificationPanel } from './NotificationPanel';
import { VoiceDialog } from './VoiceDialog';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
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
      appList: $appList, // 双向绑定应用列表
      launchApp: (item: AppItem) => this.launchApp(item) // 把启动函数传进去
    }),
    autoCancel: true, // 点击空白处关闭
    alignment: DialogAlignment.Center, // 居中显示
    customStyle: true // 使用自定义样式(去掉默认的白色圆角背景)
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
    // 模拟 hover 效果：点击时变亮
    .stateStyles({
      pressed: { .backgroundColor('rgba(255,255,255,0.1)') },
      normal: { .backgroundColor(Color.Transparent) }
    })
    .margin({ left: 2, right: 2 })
    .onClick(() => {
      if (bundleName === 'distributed') {
        // 打开超级终端界面
        this.distController.open();
      } else {
        this.launchApp({ name: bundleName, label: 'TaskApp', icon: icon });
      }
    })
  }
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 桌面背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.wallpaper'))// 确保你有 wallpaper 图片，没有就删掉这行用 backgroundColor
        .backgroundImageSize(ImageSize.Cover)

      // 2. 桌面图标网格
      Column() {
        Grid() {
          ForEach(this.appList, (item: AppItem) => {
            GridItem() {
              Column() {
                Image(item.icon)
                  .width(60)
                  .height(60)
                  .borderRadius(12)
                  .margin({ bottom: 8 })// 给图标加个淡淡的白底，防止在深色壁纸上看不清
                  .backgroundColor('rgba(255,255,255,0.15)')
                  .padding(5)

                Text(item.label)
                  .fontSize(15)
                  .fontColor(Color.White)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              //     .shadow({ radius: 2, color: 'rgba(0,0,0,0.8)', offsetY: 1 }) // 文字阴影，更清晰
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

      // ================= 3. 底部任务栏 (Win10 风格) =================
      Row() {
        // --- A. 左侧核心区 (开始 + 搜索) ---
        Row() {
          // 1. 开始按钮 (Windows 徽标)
          Image($r('app.media.win11'))// 建议换成 Windows 图标
            .width(24)
            .height(24)
            .margin({ left: 15, right: 15 })
            .onClick(() => {
              AlertDialog.show({ message: '开始菜单尚未开发\n(这是大作业的扩展项)' })
            })

          // 2. 仿 Win10 搜索框 (点击弹出搜索弹窗)
          Row() {
            Image($r('app.media.browser'))// 这里暂用浏览器图标代替搜索放大镜，最好找个 ic_search
              .width(16).height(16)
              .margin({ right: 10 })
              .opacity(0.6)

            Text("在这里输入你要搜索的内容")
              .fontSize(12)
              .fontColor('#666')
          }
          .height(32) // 搜索框高度
          .width(220) // 搜索框宽度 (长条形)
          .backgroundColor(Color.White) // 白色背景
          .borderRadius(4) // Win10 是微圆角，Win11 是大圆角，这里设 4 比较像 Win10
          .padding({ left: 10 })
          .alignItems(VerticalAlign.Center) // 内容垂直居中
          .onClick(() => {
            this.searchController.open(); // 点击框体，触发弹窗
          })
        }

        // --- B. 常用应用栏 (紧跟搜索框) ---
        Row() {
          // 这里的应用图标稍微小一点，像任务栏
          Image($r('app.media.mic'))
            .width(26)  // 设置合适的宽度，跟旁边图标对齐
            .height(26) // 设置高度
            .margin({ left: 12 }) // 保持间距
            .onClick(() => {
              this.voiceController.open();
            })
          Column() {
            Image($r('app.media.connect'))
              .width(28).height(28)
              .fillColor(Color.White) // 图标变白
          }
          .width(44).height(44)
          .backgroundColor('#0A59F7') // 鸿蒙蓝底色！非常显眼！
          .borderRadius(12) // 圆角
          .justifyContent(FlexAlign.Center)
          .margin({ left: 10 })
          .shadow({ radius: 10, color: 'rgba(10, 89, 247, 0.5)' }) // 蓝色发光阴影
          .onClick(() => {
            this.distController.open();
          })
          // 替换原来的 Text 代码


          this.TaskbarItem('com.ohos.settings', $r('app.media.settings'))
          this.TaskbarItem('com.ohos.filepicker', $r('app.media.icon'))
          this.TaskbarItem('ohos.samples.browser', $r('app.media.browser'))
          // 分布式协同按钮

        }
        .margin({ left: 10 })

        // --- C. 占位符 (把右边的挤过去) ---
        Blank()

        // --- D. 右侧状态栏 (托盘区) ---
        Row() {
          // 小箭头
          Text("∧").fontSize(14).fontColor(Color.White).margin({ right: 10 })

          // 电池/WiFi
          Text("📶").fontSize(16).fontColor(Color.White).margin({ right: 8 })
          Text("🔋").fontSize(16).fontColor(Color.White).margin({ right: 10 })

          // 时间日期 (垂直排列)
          Column() {
            Text(this.currentTime).fontSize(12).fontColor(Color.White)
            Text(this.currentDate).fontSize(10).fontColor(Color.White)
          }
          .alignItems(HorizontalAlign.End)
        }
        .onClick(() => {
          this.notifyController.open(); // 点击时间打开通知中心
        })
        .padding({ right: 15 })
        .height('100%')
        // 鼠标悬停变色效果(模拟)
        .onClick(() => {
          // 点击弹出日历逻辑
        })

      }
      .width('100%')
      .height(48) // Win10 任务栏标准高度约为 40-50px
      .backgroundColor('rgba(30, 30, 30, 0.95)') // 深黑色底，稍微透明
      // .backgroundColor('#f3f3f3') // 如果你喜欢浅色主题，就用这个浅灰色
      .position({ y: '100%' })
      .translate({ y: -48 }) // 修正位置
      .alignItems(VerticalAlign.Center)
    }
  }

  // ==== 修复 DockItem 定义 ====
  // 必须接收 (bundleName, icon) 两个参数，才能和上面的调用匹配
  @Builder DockItem(bundleName: string, icon: Resource): void {
    Column() {
      Image(icon)
        .width(45)
        .height(45)
        .borderRadius(10)
        .backgroundColor('white') // 加个白底，防止透明图标看不见
        .padding(5)
    }
    .width(55)
    .height(55)
    .justifyContent(FlexAlign.Center)
    .margin({ left: 5, right: 5 })
    .onClick(() => {
      // 构造一个临时的 item 传给启动函数
      this.launchApp({ name: bundleName, label: 'DockApp', icon: icon });
    })
  }

  // 启动应用逻辑
  launchApp(item: AppItem): void {
    console.info(`尝试启动: ${item.label} (${item.name})`);
    if (item.name === 'distributed.center') {
      this.distController.open(); // 直接打开雷达图
      return;
    }

    if (item.name.startsWith('mock.')) {
      AlertDialog.show({ message: `[演示] 模拟启动: ${item.label}` });
      return;
    }

    let want: Want = {
      bundleName: item.name,
      abilityName: item.abilityName
    };

    this.context.startAbility(want).catch((err: BusinessError) => {
      console.error(`启动失败: ${err.message}`);
      // 失败重试
      let wantBackup: Want = { bundleName: item.name };
      this.context.startAbility(wantBackup).catch((err2: BusinessError) => {
        AlertDialog.show({ message: `启动失败: ${item.label}\n${err2.message}` });
      });
    });
  }
}