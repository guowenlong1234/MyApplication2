@CustomDialog
export struct NotificationPanel {
  controller?: CustomDialogController;

  build() {
    Column() {
      // 1. 标题栏
      Row() {
        Text("通知中心").fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text("清空").fontSize(14).fontColor('#007DFA')
          .onClick(() => this.controller?.close()) // 暂时做成关闭
      }
      .width('100%')
      .padding({ bottom: 15 })

      // 2. 通知列表
      List({ space: 12 }) {

        // [分布式通知] - 这是一个得分点
        ListItem() {
          this.NotificationItem(
            'HUAWEI Mate 60 Pro',
            '跨端流转',
            '正在向您发送文件 "OpenHarmony架构图.png"...',
            '#0A59F7' // 蓝色高亮
          )
        }

        // [普通应用通知]
        ListItem() {
          this.NotificationItem('微信', '张三', '今晚的操作系统大作业写完了吗？', '#28C445')
        }

        // [系统通知]
        ListItem() {
          this.NotificationItem('系统更新', 'OpenHarmony 4.1', '新版本已就绪，点击安装。', '#666666')
        }

        ListItem() {
          this.NotificationItem('日程提醒', '14:00', '参加高级操作系统课程答辩', '#FFA500')
        }
      }
      .width('100%')
      .layoutWeight(1) // 占满剩余空间

      // 3. 底部快捷开关 (仿 Win11)
      Grid() {
        this.QuickSetting('WiFi', true)
        this.QuickSetting('蓝牙', true)
        this.QuickSetting('勿扰', false)
        this.QuickSetting('投屏', false)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .width('100%')
      .height(80)
      .margin({ top: 20 })
    }
    .width(350) // 侧边栏宽度
    .height('100%')
    .backgroundColor('#F0F3F5')
    .padding(20)
    // 关键布局：让它贴在屏幕右侧
    .position({ x: '100%', y: 0 })
    .markAnchor({ x: '100%', y: 0 })
    .shadow({ radius: 50, color: 'rgba(0,0,0,0.2)', offsetX: -10 })
  }

  // 通知卡片组件
  @Builder NotificationItem(app: string, title: string, content: string, color: string) {
    Column() {
      Row() {
        // 小圆点图标
        Circle({ width: 8, height: 8 }).fill(color).margin({ right: 8 })
        Text(app).fontSize(12).fontColor('#666')
        Blank()
        Text("刚刚").fontSize(10).fontColor('#999')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(title).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
      Text(content).fontSize(13).fontColor('#666').margin({ top: 4 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(15)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 5 })
  }

  // 快捷开关组件
  @Builder QuickSetting(name: string, isOn: boolean) {
    Column() {
      Column() {
        // 这里简化用个圆圈代替图标
        Circle({ width: 20, height: 20 })
          .fill(isOn ? '#007DFA' : '#999')
      }
      .width(40).height(40)
      .borderRadius(20)
      .backgroundColor(isOn ? 'rgba(0,125,250,0.2)' : '#ddd')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 5 })

      Text(name).fontSize(12).fontColor('#333')
    }
  }
}