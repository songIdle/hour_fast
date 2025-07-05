import { display, window } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'

export class AdManager {
  context?: Context // 是给ability使用的
  private winNames: string [] = []

  // 展示广告 采用windows窗口的创建和销毁的方式
  async showAd(url: string, width?: number, height?: number) {
    if (url) {
      let name = `win_${util.generateRandomUUID()}`
      const win = await window.createWindow({
        name,
        windowType: window.WindowType.TYPE_DIALOG,
        ctx: this.context || getContext()
      })
      if (width && width >= 320 && height && height >= 240) {
        const screen = display.getDefaultDisplaySync()
        let mainWidth = vp2px(width)
        let mainHeight = vp2px(height)
        win.resizeAsync(mainWidth, mainHeight)
        win.moveWindowToAsync((screen.width - mainWidth) / 2, (screen.height - mainHeight) / 2)
      }
      await win.showWindow() // 展示窗口
      win.setUIContent(url) // 设置地址
      this.winNames.push(name)
      return name
    }
    return ""
  }

  // 关闭广告
  async closeAd(name?: string) {
    if (name) {
      window.findWindow(name).destroyWindow()
      this.winNames = this.winNames.filter(item => item !== name) //清空数组内容
    } else {
      // 不传就认为 想关闭所有
      let index = 0
      while (index < this.winNames.length) {
        await window.findWindow(this.winNames[index]).destroyWindow()
        index++
      }
      this.winNames = [] // 清空数组
    }

  }
}

export const adManger = new AdManager()