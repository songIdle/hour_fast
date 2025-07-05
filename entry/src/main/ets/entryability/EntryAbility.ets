import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { adManagerFinal, adManger, AdvertClass, userSetting } from 'basic';

// 云端广告
const cloudAd: AdvertClass = {
  showAd: true,
  isFull: false,
  adTime: 5,
  adImg: $r("app.media.start")
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onDestroy(): void {
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    userSetting.context = this.context // 首选项赋值上下文
    // 发起一个向云端获取广告数据的请求
    const ad = await new Promise<AdvertClass>((resolve, reject) => {
      setTimeout(() => {
        resolve(cloudAd)
      }, 500)
    })
    await userSetting.setUserAd(ad) // 将广告设置到首选项
    // 此时应该判断是不是展示广告？
    // 1. 最朴素的一种方式
    // if (ad.showAd) {
    //   windowStage.loadContent('pages/start/Start');
    // } else {
    //   windowStage.loadContent('pages/Index');
    // }
    // 2. 略微有点意思的模式
    // if (ad.showAd) {
    //   const win = await windowStage.createSubWindow("ad_win") // 二级窗口的实际对象
    //   await win.showWindow() // 展示二级窗口
    //   win.setUIContent("pages/Start/Start")
    // }

    await windowStage.loadContent("pages/Index"); // 必须等到有了UIContext才可以使用
    if (ad.showAd) {
      adManagerFinal.context = this.context
      // adManger.context = this.context
      // await adManger.showAd("pages/Start/Start", 330, 440)
      adManagerFinal.showAd(ad) // 展示广告
    }
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {

  }

  onBackground(): void {
  }
}
