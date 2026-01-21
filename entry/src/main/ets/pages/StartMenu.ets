import { AppModel, AppItem } from '../model/AppModel';

@CustomDialog
export struct StartMenu {
  controller?: CustomDialogController;

  @Link appList: Array<AppItem>;

  launchApp: (item: AppItem) => void = () => {};

  build() {
    Column() {

      Row() {
        Text("已固定")
          .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
        Blank()
        Text("所有应用 >")
          .fontSize(12).fontColor('#007DFA')
          .backgroundColor('rgba(0,0,0,0.05)')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24, bottom: 10 })

      Grid() {
        ForEach(this.appList, (item: AppItem) => {
          GridItem() {
            Column() {
              Image(item.icon)
                .width(40).height(40)
                .borderRadius(8)
                .margin({ bottom: 8 })
              Text(item.label)
                .fontSize(12)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(70)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .borderRadius(8)
            .stateStyles({
              pressed: { .backgroundColor('rgba(0,0,0,0.05)') },
              normal: { .backgroundColor(Color.Transparent) }
            })
            .onClick(() => {
              this.controller?.close();
              this.launchApp(item);
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr') // 4列
      .rowsGap(10)
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 10, right: 10 })


      Row() {

        Row() {
          Image($r('app.media.person_crop'))
            .width(32).height(32)
            .borderRadius(16)
            .margin({ right: 10 })
          Text("Administrator")
            .fontSize(14).fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .padding({ left: 10 })

        .onClick(() => {
          AlertDialog.show({ message: '用户中心: Admin' });
        })


        Image($r('app.media.battery'))
          .width(24).height(24)
          .fillColor('#333')
          .padding(4)
          .borderRadius(4)
          .backgroundColor('rgba(0,0,0,0.05)')
          .onClick(() => {
            AlertDialog.show({
              title: '电源',
              message: '请选择操作',
              primaryButton: { value: '睡眠', action: () => {} },
              secondaryButton: { value: '关机', fontColor: Color.Red, action: () => {} }
            });
          })
      }
      .width('100%')
      .height(60)
      .backgroundColor('rgba(0,0,0,0.03)')
      .padding({ left: 24, right: 24 })
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width(400) // 宽度
    .height(500) // 高度
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetY: 5 })
  }
}