import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { userSetting } from '.'
import { BASE_URL, TOKEN_KEY } from '../constants'
import { promptAction, router } from '@kit.ArkUI'

// axios创建一个新的实例- 正规的方式
// 单例模式- 假如一个项目需要向四个域名发送请求
// 面向对象模式
const instance = axios.create({
  baseURL: BASE_URL, // 设置基础地址
  timeout: 10000
})

// 请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (AppStorage.get(TOKEN_KEY)) {
    // 统一注入token
    config.headers.Authorization = AppStorage.get(TOKEN_KEY) // token
  }
  return config // 请求的配置 可以做一些处理
}, (error: AxiosError) => {
  promptAction.showToast({ message: error.message })
  return Promise.reject(error)
})

// 想清楚
instance.interceptors.response.use((response: AxiosResponse) => {
  // 判断业务状态码
  if (response.data && response.data.code === 200) {
    return response.data.data // 唯一的成功的地方
  }
  promptAction.showToast({ message: response.data.msg }) // 弹出错误消息
  return Promise.reject(new Error(response.data.msg))


}, (error: AxiosError) => {
  // 当http状态码为非2xx的时候 进入200
  // 401
  // 404
  if (error.response?.status === 401) {
    promptAction.showToast({ message: '登录失败' })
    // 意味着你本地的token 不管有没有肯定是废了！！！
    // 删除首选项
    userSetting.setUserToken("") // 清空首选项
    AppStorage.setOrCreate(TOKEN_KEY, "") // 清空内存
    // 跳转到登录页
    router.replaceUrl({
      url: 'pages/Login/Login'
    })
    // 应该返回失败
    return Promise.reject(new Error("登录失败"))
  } else if (error.response?.status === 404) {
    promptAction.showToast({ message: '请求地址错误' })
    return Promise.reject(new Error("请求地址错误"))
  }
  promptAction.showToast({ message: error.message })
  return Promise.reject(error)
})

// axios中get类型会自己处理参数， 只需要把get的参数赋值给params属性

// 使用axios
export class RequestAxios {
  static get<T>(url: string, params?: object): Promise<T> {
    return instance.get<null, T>(url, { params })
  }

  static post<T>(url: string, data?: object): Promise<T> {
    return instance.post<null, T>(url, data)
  }

  static delete<T>(url: string, params?: object): Promise<T> {
    return instance.delete<null, T>(url, { params })
  }

  static put<T>(url: string, data?: object): Promise<T> {
    return instance.put<null, T>(url, data)
  }
}