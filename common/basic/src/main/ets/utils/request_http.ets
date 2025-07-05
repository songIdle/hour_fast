import http from '@ohos.net.http'
import { BASE_URL, TOKEN_KEY } from '../constants'
import { PromptAction, promptAction, router } from '@kit.ArkUI'
import { userSetting } from '.'
import { ResponseData } from '../viewmodels'


// 实现一个静态类的四个方法 get/post/put/delete
async function requestByHttp<T>(url: string, method: http.RequestMethod, data?: object) {
  // 1. 创建http的对象
  const req = http.createHttp()
  let urlStr = BASE_URL + url
  // 2. 要考虑参数的问题  当请求为get类型的时候 它不会帮你处理参数
  // /getList?id=1&page=1&pagesize=10 /getList  { id: 1, page: 1, pagesize: 10  }

  if (method === http.RequestMethod.GET && data) {
    // 拼装参数到地址上
    // 可以对object类型进行遍历
    // 接口比较脆 不支持没有value的内容拼接 /getList?id=&page=&pagesize=
    urlStr += "?" + Object.keys(data)
      .filter(key =>!!data[key])// 过滤一下当前的value不存在的情况
      .map(key => {
        return `${key}=${data[key]}`
      }).join("&")
  }
  // 发送请求
  // 组装参数
  let config: http.HttpRequestOptions = {
    method,
    header: {
      // json请求体模式 {  }
      // "Content-Type": 'application/x-www-form-urlencoded'
      //
      "Content-Type": 'application/json', // 请求体的类型
      "Authorization": AppStorage.get(TOKEN_KEY) || "" // 从首选项读取 从内存读取
    },
    extraData: method !== http.RequestMethod.GET ? data : "",
    readTimeout: 10000 // 超时时间
    // key1=value1&key2=value2&key3=value3 -'application/x-www-form-urlencoded'
    // { a: 1, b: 2 } - 'application/json'
  }
  try {
    const res = await req.request(urlStr, config)
    // res.result
    if (res.responseCode === 401) {
      // 此时意味着token超时或者没有传token
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
    } else if (res.responseCode === 404) {
      promptAction.showToast({ message: '请求地址错误' })
      return Promise.reject(new Error("请求地址错误"))
    } else {
      // 认为http状态码暂时过关
      const result = JSON.parse(res.result as string) as ResponseData<T>
      if (result.code === 200) {
        // 此时才是真正的成功
        return result.data as T
      } else {
        // 此时意味着 业务状态码失败
        promptAction.showToast({ message: result.msg }) // 这个msg友情提醒 - 有的时候会报出java的调用栈
        return Promise.reject(new Error(result.msg)) // 结束当前的promise的流程
      }
    }
    // http状态码
    // 状态码 http状态码 业务状态码
  } catch (error) {
    promptAction.showToast({ message: error.message })
    return Promise.reject(error)
  }
}


export class RequestHttp {
  // 查  传递参数需求
  static get<T>(url: string, data?: object): Promise<T> {
    return requestByHttp<T>(url, http.RequestMethod.GET, data)
  }

  // 增
  static post<T>(url: string, data?: object): Promise<T> {
    return requestByHttp<T>(url, http.RequestMethod.POST, data)

  }

  // 删
  static delete<T>(url: string, data?: object): Promise<T> {
    return requestByHttp<T>(url, http.RequestMethod.DELETE, data)

  }

  // 修改
  static put<T>(url: string, data?: object): Promise<T> {
    return requestByHttp<T>(url, http.RequestMethod.PUT, data)
  }
}
