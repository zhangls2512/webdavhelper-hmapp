import { preferences } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { getAccountInfo } from './Account'
import { getDnsServer } from './Dnsserver'

interface DeveloperErrorResponse {
  errCode: number,
  errMsg: string,
  errFix: string
}

export async function webdavRequest(context: Context, path: string, method: string, headers: rcp.RequestHeaders) {
  const accountInfo = await getAccountInfo()
  if (!accountInfo.path) {
    return 'fail'
  }
  const debugSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'debugSetting'
  })
  const session = rcp.createSession({
    requestConfiguration: {
      dns: {
        dnsRules: getDnsServer(context)
      },
      security: {
        remoteValidation: debugSettingDataPreferences.getSync('closeRemoteValidationWhenLinkWebdav',
          'system') as 'system' | 'skip',
        tlsRange: {
          min: 'TlsV1.2'
        }
      }
    },
    headers: headers
  })
  try {
    const response = await session.fetch(new rcp.Request(accountInfo.path + '/' + path, method, headers))
    session.close()
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return String(response)
    } else {
      await promptAction.openToast({
        message: 'HTTP 请求失败，状态码：' + response.statusCode
      })
      return 'fail'
    }
  } catch (err) {
    session.close()
    await promptAction.openToast({
      message: '发生错误，错误码：' + err.code
    })
    return 'fail'
  }
}

export async function developerRequest(context: Context, path: string, body: rcp.RequestContent) {
  const commonSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'commonSetting'
  })
  const allService = commonSettingDataPreferences.getSync('allService', true)
  if (!allService) {
    context.eventHub.emit('dialog', '全量模式未开启',
      '全量模式未开启，无法使用在线功能。如需使用在线功能，请前往“我的”>“设置”>“更多”>“应用服务模式”，开启全量模式。')
    return 'fail'
  }
  const session = rcp.createSession({
    requestConfiguration: {
      dns: {
        dnsRules: getDnsServer(context)
      },
      security: {
        tlsRange: {
          min: 'TlsV1.2'
        }
      }
    }
  })
  try {
    const response = await session.post('https://api.zhangls2512.cn' + path, body)
    session.close()
    if (response.statusCode === 200) {
      const res = response.toJSON() as DeveloperErrorResponse
      if (res.errCode === 0) {
        return String(response)
      }
      context.eventHub.emit('dialog', '接口调用失败',
        '错误码：' + res.errCode + '\n错误信息：' + res.errMsg + '\n修复方法：' + res.errFix)
      return 'fail'
    }
    await promptAction.openToast({
      message: 'HTTP 请求失败，状态码：' + response.statusCode
    })
    return 'fail'
  } catch (err) {
    session.close()
    await promptAction.openToast({
      message: '发生错误，错误码：' + err.code
    })
    return 'fail'
  }
}