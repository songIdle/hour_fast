export class AdvertClass {
  showAd: boolean = false // 是否展示广告
  isFull: boolean = true // 是否全屏
  adTime: number = 5 // 倒计时数据
  adUrl?: string = "" // 要跳转的连接
  adImg?: ResourceStr = "" // 图片连接
  dialogName?: string
}

// 全屏广告 半屏广告