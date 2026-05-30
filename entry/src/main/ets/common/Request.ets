import { promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { getAccountInfo } from './Account'
import { getDnsServer } from './Dnsserver'
import { getFlushPreference } from './Preference'

interface DeveloperErrorResponse {
  errCode: number,
  errMsg: string,
  errFix: string
}

export let webdavGlobalSession: rcp.Session | undefined = undefined

export const defaultGlobalSession = rcp.createSession({
  requestConfiguration: {
    security: {
      tlsRange: {
        min: 'TlsV1.2'
      }
    }
  }
})

export function getWebdavGlobalSession(context: Context) {
  if (!webdavGlobalSession) {
    webdavGlobalSession = rcp.createSession({
      requestConfiguration: {
        dns: {
          dnsRules: getDnsServer(context)
        },
        security: {
          remoteValidation: getFlushPreference(context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav',
            'system') as 'system' | 'skip',
          tlsRange: {
            min: 'TlsV1.2'
          }
        }
      }
    })
  }
  return webdavGlobalSession
}

export async function webdavRequest(context: Context, path: string, method: string, headers: rcp.RequestHeaders) {
  const accountInfo = await getAccountInfo(context)
  try {
    const response =
      await getWebdavGlobalSession(context).fetch(new rcp.Request(accountInfo.path + '/' + path, method, headers))
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return String(response)
    } else {
      await promptAction.openToast({
        message: 'HTTP 请求失败，状态码：' + response.statusCode
      })
      return 'fail'
    }
  } catch (err) {
    await promptAction.openToast({
      message: '发生错误，错误码：' + err.code
    })
    return 'fail'
  }
}

export async function developerRequest(context: Context, path: string, body: rcp.RequestContent) {
  const allService = getFlushPreference(context, 'commonSetting', 'allService', true)
  if (!allService) {
    context.eventHub.emit('dialog', '全量模式未开启',
      '全量模式未开启，无法使用在线功能。如需使用在线功能，请前往“我的”>“设置”>“更多”>“应用服务模式”，开启全量模式。')
    return 'fail'
  }
  try {
    const response = await defaultGlobalSession.post('https://api.zhangls2512.cn' + path, body)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      const res = response.toJSON() as DeveloperErrorResponse
      if (res.errCode === 0) {
        return String(response)
      }
      context.eventHub.emit('dialog', '接口调用失败',
        '错误码：' + res.errCode + '\n错误信息：' + res.errMsg + '\n修复方法：' + res.errFix)
      return 'fail'
    } else {
      await promptAction.openToast({
        message: 'HTTP 请求失败，状态码：' + response.statusCode
      })
      return 'fail'
    }
  } catch (err) {
    await promptAction.openToast({
      message: '发生错误，错误码：' + err.code
    })
    return 'fail'
  }
}