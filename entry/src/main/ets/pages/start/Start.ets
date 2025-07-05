import { adManger, AdvertClass, userSetting } from 'basic'
import { router, window } from '@kit.ArkUI'

@Entry
@Component
struct Start {
  // 需要广告对象
  @State
  ad: AdvertClass = new AdvertClass()
  timer: number = -1 // 用来记录定时器的标记

  // @State
  // ad: Partial<AdvertClass> = {}
  aboutToAppear(): void {
    // 获取首选项的广告数据给到ad
    this.getAdInfo()
  }

  getAdInfo() {
    // 首选项的读取
    this.ad = userSetting.getUserAd()
    // 开启倒计时了
    if (this.ad.showAd) {
      // 如果真的展示广告要开始倒计时
      this.timer = setInterval(() => {
        if (this.ad.adTime === 0) {
          clearInterval(this.timer)
          this.toMain()
          return // return一定要写
        }
        this.ad.adTime--
      }, 1000)
    }
  }

  // 去主页的方法
  toMain() {
    // router.replaceUrl({
    //   url: 'pages/Index'
    // })
    // 销毁当前的窗口
    clearInterval(this.timer) // 先清理一下定时器
    adManger.closeAd()
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    RelativeContainer() {
      if (this.ad.showAd) {
        Image(this.ad.adImg)
          .width("100%")
          .height("100%")
          .objectFit(ImageFit.Cover)
        Text(`${this.ad.adTime}秒跳过`)
          .padding({
            left: 10,
            right: 10
          })
          .alignRules({
            right: {
              anchor: '__container__',
              align: HorizontalAlign.End
            },
            top: {
              anchor: '__container__',
              align: VerticalAlign.Top
            }
          })
          .borderRadius(15)
          .height(30)
          .fontSize(14)
          .backgroundColor($r("app.color.background_page"))
          .margin({
            right: 20,
            top: 20
          })
          .onClick(() => {
            // 此时跳过广告
            // 跳转到主页
            this.toMain()
          })
      }

    }
    .height('100%')
    .width('100%')
  }
}