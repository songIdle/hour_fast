import { preferences } from '@kit.ArkData'
import { USER_SETTING, USER_SETTING_AD } from '../constants'
import { AdvertClass } from '../viewmodels'


export const defaultAd: AdvertClass = {
  showAd: true,
  isFull: true,
  adTime: 3,
  adImg: $r("app.media.start")
}

// 负责首选项的读取
export class UserSetting {
  context?: Context
  // 获取仓库
  getStore () {
    return preferences.getPreferencesSync(this.context || getContext(), {
      name: USER_SETTING
    })
  }
  // 设置用户广告
  async setUserAd(ad: AdvertClass) {
    const store = this.getStore()
    store.putSync(USER_SETTING_AD, ad)
    await store.flush()  // 让外界能够控制自己的流程
  }
  // 获取用户广告
  getUserAd() {
    const store = this.getStore()
    return store.getSync(USER_SETTING_AD, defaultAd) as AdvertClass
  }
}

export const userSetting = new UserSetting() // 导出一个单例