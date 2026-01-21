import { AppModel, AppItem, FileItem } from '../model/AppModel';

@CustomDialog
export struct SearchDialog {
  controller: CustomDialogController;
  @Link appList: Array<AppItem>;
  launchApp: (item: AppItem) => void = () => {};

  @State searchText: string = '';
  @State resultApps: Array<AppItem> = [];
  @State resultFiles: Array<FileItem> = [];
  @State recommends: Array<string> = [];

  private model = new AppModel();
  private allFiles = this.model.getMockFiles();

  aboutToAppear() {
    this.recommends = this.model.getRecommendItems();
  }

  build() {
    Column() {
      // 1. 搜索栏
      Row() {
        Text("🔍").fontSize(18).margin({ right: 10 })
        TextInput({ placeholder: '搜应用 / 搜文档内容 (如: "软总线")', text: this.searchText })
          .height(40)
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.searchText = value;
            this.doSearch(value);
          })
        if (this.searchText.length > 0) {
          Text("✖").fontSize(16).fontColor('#999')
            .onClick(() => { this.searchText = ''; this.doSearch(''); })
        }
      }
      .width('100%')
      .height(50)
      .backgroundColor('#f2f3f5')
      .borderRadius(8)
      .padding({ left: 15, right: 15 })
      .margin({ bottom: 10 })

      // 2. 内容区
      Scroll() {
        Column() {
          if (this.searchText.length === 0) {
            // 推荐区
            Text("热门搜索").fontSize(14).fontColor('#666').width('100%').margin({ top: 10, bottom: 10 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.recommends, (item: string) => {
                Text(item).fontSize(13).fontColor('#333').backgroundColor('#f0f0f0')
                  .padding({ top: 6, bottom: 6, left: 12, right: 12 })
                  .borderRadius(15).margin({ right: 10, bottom: 10 })
                  .onClick(() => { this.searchText = item; this.doSearch(item); })
              })
            }
          } else {
            // --- 应用结果 ---
            if (this.resultApps.length > 0) {
              Text("应用").fontSize(14).fontColor('#007DFA').width('100%').margin({ top: 5, bottom: 5 })
              List() {
                ForEach(this.resultApps, (app: AppItem) => {
                  ListItem() {
                    Row() {
                      Image(app.icon).width(32).height(32).borderRadius(6).margin({ right: 12 })
                      Text(app.label).fontSize(16).fontColor('#333')
                    }
                    .width('100%').height(50)
                    .onClick(() => { this.controller.close(); this.launchApp(app); })
                  }
                })
              }
            }

            if (this.resultFiles.length > 0) {
              Text("文档与内容").fontSize(14).fontColor('#007DFA').width('100%').margin({ top: 15, bottom: 5 })
              List() {
                ForEach(this.resultFiles, (file: FileItem) => {
                  ListItem() {
                    Row() {
                      Text(this.getFileEmoji(file.type)).fontSize(28).margin({ right: 12 })
                      Column() {
                        // 文件名
                        Text(file.name).fontSize(15).fontColor('#333')


                        Text(file.desc).fontSize(12).fontColor('#999')

                        if (file.content.toLowerCase().includes(this.searchText.toLowerCase())) {
                          Text(`...包含: "${this.getSnippet(file.content, this.searchText)}"...`)
                            .fontSize(12)
                            .fontColor('#e67e22') // 橙色高亮
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 2 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%').padding({ top: 8, bottom: 8 })
                    .onClick(() => {
                      AlertDialog.show({
                        title: file.name,
                        message: `文件预览:\n\n${file.content}\n\n[真实打开功能需系统权限]`
                      });
                    })
                  }
                })
              }
            }
          }
        }
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .width(600)
    .height(450) // 稍微加高一点
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(20)
    .shadow({ radius: 40, color: 'rgba(0,0,0,0.4)', offsetY: 10 })
  }

  doSearch(keyword: string) {
    if (!keyword) return;
    let key = keyword.toLowerCase().trim();

    // 1. 搜应用
    this.resultApps = this.appList.filter(app => app.label.toLowerCase().includes(key));

    // 2. 搜文件 (名字 OR 内容)
    this.resultFiles = this.allFiles.filter(file => {
      let matchName = file.name.toLowerCase().includes(key);
      let matchContent = file.content.toLowerCase().includes(key); // 核心：内容搜索
      return matchName || matchContent;
    });
  }

  // 截取关键词附近的文字作为摘要
  getSnippet(content: string, keyword: string): string {
    let index = content.toLowerCase().indexOf(keyword.toLowerCase());
    let start = Math.max(0, index - 5);
    let end = Math.min(content.length, index + 10);
    return content.substring(start, end);
  }

  getFileEmoji(type: string): string {
    switch(type) {
      case 'doc': return '📄';
      case 'img': return '🖼️';
      case 'music': return '🎵';
      case 'video': return '🎬';
      default: return '📦';
    }
  }
}