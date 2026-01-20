export interface AppItem {
  name: string;
  label: string;
  icon: Resource;
  abilityName?: string;
}

export interface FileItem {
  name: string;
  desc: string;    // 显示路径
  type: 'doc' | 'img' | 'video' | 'music';
  content: string; // 【核心】这里存放文档的真实内容，用于搜索
}

export class AppModel {
  getMockFiles(): Array<FileItem> {
    return [
    // === 真实文档 1：操作系统作业 ===
      {
        name: '高级操作系统_大作业报告.docx',
        desc: 'C:/Documents/Study/OS',
        type: 'doc',
        content: '本次实验基于OpenHarmony 4.1 Release版本，完成了智能桌面Launcher的开发。实现了Dock栏跨端设备应用接续，桌面融合搜索模块支持文件名与文档内容的语义搜索。使用了ArkTS进行UI布局...'
      },

      // === 真实文档 2：复习资料 ===
      {
        name: '期末考试复习重点.txt',
        desc: 'C:/Desktop',
        type: 'doc',
        content: 'OpenHarmony架构分为内核层、系统服务层、框架层和应用层。HDC是命令行工具。Ability分为UIAbility和ExtensionAbility。分布式软总线是实现万物互联的底座...'
      },

      // === 真实文档 3：周杰伦歌词 (测试娱乐搜索) ===
      {
        name: '周杰伦_七里香.lrc',
        desc: 'C:/Music/Jay',
        type: 'music',
        content: '窗外的麻雀在电线杆多嘴，你说这一句很有夏天的感觉。手中的铅笔在纸上来来回回...'
      },

      // === 普通文件 (内容为空或简单描述) ===
      { name: 'RVBook_原理图.pdf', desc: 'C:/Downloads', type: 'doc', content: 'RISC-V电路设计图纸' },
      { name: '家庭聚会_全家福.jpg', desc: 'C:/Pictures/Life', type: 'img', content: '照片 人物 聚会' },
      { name: '演示视频.mp4', desc: 'C:/Videos', type: 'video', content: '视频录制' }
    ];
  }

  getRecommendItems(): Array<string> {
    return ['设置', '作业', '分布式', '架构', '周杰伦'];
  }
  getAppList(): Array<AppItem> {
    return [
    // ===========================
    // 第一排：核心与学习
    // ===========================
      {
        name: 'com.example.aiclass',
        label: 'AI学堂',
        icon: $r('app.media.aiclass'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.isrc.texteditor',
        label: '文本编辑',
        icon: $r('app.media.texteditor'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'ohos.samples.etsclock',
        label: '时钟',
        icon: $r('app.media.etsclock'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.ohos.settings',
        label: '系统设置',
        icon: $r('app.media.setting'),
        abilityName: 'com.ohos.settings.MainAbility'
      },

      // ===========================
      // 第二排：办公与效率
      // ===========================
      {
        name: 'com.ohos.filepicker', // 或者是  com.ohos.UserFile.ExternalFileManager
        label: '文件管理器',
        icon: $r('app.media.filepicker'),
        abilityName: 'MainAbility'
      },
      {
        name: 'com.ohos.note',
        label: '备忘录',
        icon: $r('app.media.note'),
        abilityName: 'MainAbility'
      },
      {
        name: 'ohos.samples.qrcodescan',
        label: '二维码扫描',
        icon: $r('app.media.qrcodescan'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.example.office',
        label: 'WPS云文档',
        icon: $r('app.media.office'),
        abilityName: 'EntryAbility'
      },

      // ===========================
      // 第三排：工具与多媒体
      // ===========================
      {
        name: 'com.example.distributedcalc',
        label: '计算器',
        icon: $r('app.media.distributedcalc'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.ohos.photos',
        label: '相册',
        icon: $r('app.media.photos'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.ohos.camera',
        label: '相机',
        icon: $r('app.media.camera'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'net.openvally.videoplay',
        label: '视频播放器',
        icon: $r('app.media.videoplay'),
        abilityName: 'EntryAbility'
      },

      // ===========================
      // 第四排：互联网与通讯
      // ===========================
      {
        name: 'ohos.samples.browser',
        label: '浏览器',
        icon: $r('app.media.browser'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.example.weichat',
        label: '微信传输助手',
        icon: $r('app.media.weichat'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.isrc.photoviewer',
        label: '图片浏览器',
        icon: $r('app.media.photoviewer'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.ohos.updateapp',
        label: '软件更新',
        icon: $r('app.media.updateapp'),
        abilityName: 'MainAbility'
      },

      // ===========================
      // 凑数/系统组件 (丰富界面)
      // ===========================
      {
        name: 'com.example.distributedmusicplayer',
        label: '分布式音乐',
        icon: $r('app.media.distributedmusicplayer'),
        abilityName: 'EntryAbility'
      },
      {
        name: 'com.ohos.permissionmanager',
        label: '权限管理',
        icon: $r('app.media.permissionmanager')
      },
      {
        name: 'mock.appstore',
        label: '应用商店', // 这是一个Mock，因为dump里没找到明确的Store
        icon: $r('app.media.appstore')
      },
      {
        name: 'mock.trash',
        label: '回收站',
        icon: $r('app.media.trash')
      },
    {
        name: 'distributed.center', // 特殊包名，用于识别
        label: '超级终端',
        icon: $r('app.media.connect') // 用你新替换的图标
      },
    ];
  }
}