import {
  AbilityConstant,
  appRecovery,
  bundleManager,
  ConfigurationConstant,
  contextConstant,
  errorManager,
  UIAbility,
  Want,
  wantConstant
} from '@kit.AbilityKit'
import { updateManager } from '@kit.AppGalleryKit'
import { preferences, uniformTypeDescriptor } from '@kit.ArkData'
import { promptAction, window } from '@kit.ArkUI'
import { commonEventManager, deviceInfo } from '@kit.BasicServicesKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { statusBarManager } from '@kit.DeskTopExtensionKit'
import { image } from '@kit.ImageKit'
import { netQuality } from '@kit.NetworkBoostKit'
import { connection } from '@kit.NetworkKit'
import { notificationManager } from '@kit.NotificationKit'
import { hiAppEvent } from '@kit.PerformanceAnalysisKit'
import { harmonyShare, systemShare } from '@kit.ShareKit'
import { getAccountList, getLoginStatus, loginBestPathAccount } from '../common/Account'
import { clearNouseData } from '../common/Clearnousedata'
import { write } from '../common/File'
import { getCurrentNetworkBearerType } from '../common/Network'
import openLink from '../common/Openlink'

export interface JsErrorObject {
  name: string,
  info: Error
}

interface MenuCodeEventData {
  data: EventData
}

interface EventData {
  menuCode: string
}

export default class EntryAbility extends UIAbility {
  async appInit(want: Want) {
    await notificationManager.setBadgeNumber(0)
    if (want.parameters?.noticeUrl) {
      await openLink(this.context, want.parameters.noticeUrl as string)
    }
    if (want.parameters?.shortcutId === 'file') {
      this.context.eventHub.emit('file')
    }
    if (want.parameters?.shortcutId === 'transfer') {
      this.context.eventHub.emit('transfer')
    }
    if (want.parameters?.menuHandler === 'clickMenu') {
      const uriList = want.parameters.uriList as string[]
      const fileUri = uriList[0] as string
      this.context.eventHub.emit('wantUri', fileUri)
    }
    if (want.parameters?.linkFeature) {
      const linkFeature = want.parameters.linkFeature
      if (linkFeature === 'AppStorageMgmt') {
        this.context.eventHub.emit('clearData')
      }
      if (linkFeature === 'AppNotificationMgmt') {
        this.context.eventHub.emit('notice')
      }
    }
    if (want.uri && !want.parameters?.linkFeature) {
      this.context.eventHub.emit('wantUri', want.uri)
    }
    try {
      const sharedData = await systemShare.getSharedData(want)
      const sharedRecords = sharedData.getRecords()
      if (sharedRecords.length !== 0) {
        this.context.eventHub.emit('wantUri', sharedRecords[0].uri)
      }
    } catch {
    }
    if (deviceInfo.deviceType === '2in1') {
      const lastWindow = await window.getLastWindow(this.context)
      harmonyShare.on('dataReceive', {
        windowId: lastWindow.getWindowProperties().id,
        capabilities: [
          {
            utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
            maxSupportedCount: 1
          }
        ]
      }, async (receivableTarget) => {
        await receivableTarget.receive(fileUri.getUriFromPath(this.context.tempDir), {
          onDataReceived: (sharedData) => {
            const sharedRecords = sharedData.getRecords()
            this.context.eventHub.emit('wantUri', sharedRecords[0].uri)
          }
        })
      })
    }
  }

  async windowInit(windowStage: window.WindowStage) {
    await windowStage.getMainWindowSync().setWindowLayoutFullScreen(true)
    await windowStage.loadContent('pages/Index')
    const context = this.context
    const commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'commonSetting'
    })
    if (deviceInfo.deviceType === '2in1') {
      const windowRectAutoSave = commonSettingDataPreferences.getSync('windowRectAutoSave', false) as boolean
      await windowStage.setWindowRectAutoSave(windowRectAutoSave)
    }
    if (deviceInfo.deviceType === '2in1') {
      const lastWindow = await window.getLastWindow(this.context)
      const windowTopmost = commonSettingDataPreferences.getSync('windowTopmost', false) as boolean
      await lastWindow.setWindowTopmost(windowTopmost)
    }
    if (!notificationManager.isNotificationEnabledSync()) {
      await notificationManager.requestEnableNotification(this.context)
    }
    const debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'debugSetting'
    })
    const errorLogDir = this.context.filesDir + '/log/error/'
    errorManager.on('error', {
      async onUnhandledException(errMsg) {
        if (debugSettingDataPreferences.getSync('globalErrorShowType', 0) === 0) {
          await promptAction.openToast({
            message: 'js 运行异常：' + errMsg
          })
        }
      },
      async onException(err) {
        const object: JsErrorObject = {
          name: 'JS_ERROR',
          info: {
            name: err.name,
            message: err.message,
            stack: err.stack
          }
        }
        if (debugSettingDataPreferences.getSync('saveErrorLog', true)) {
          await write(errorLogDir + Date.now() + '.txt', JSON.stringify(object))
        }
        if (debugSettingDataPreferences.getSync('globalErrorShowType', 0) === 0) {
          await promptAction.openToast({
            message: 'js 运行异常，错误名称：' + err.name + '，错误信息：' + err.message
          })
        }
        if (debugSettingDataPreferences.getSync('globalErrorShowType', 0) === 1) {
          context.eventHub.emit('dialog', 'js 运行异常', '名称：' + err.name + '\n信息：' + err.message)
        }
        if (debugSettingDataPreferences.getSync('autoUploadErrorLog', true) &&
          commonSettingDataPreferences.getSync('allService', true)) {
          if ((debugSettingDataPreferences.getSync('autoUploadErrorLogType',
            ['JS_ERROR', 'APP_CRASH']) as string[]).includes('JS_ERROR')) {
            context.eventHub.emit('uploadErrorLog', object.name, JSON.stringify(object))
          }
        }
      }
    })
    errorManager.on('unhandledRejection', async (err: Error) => {
      if (err.message !== 'cancel' && err.message !== 'Default error message') {
        const object: JsErrorObject = {
          name: 'JS_ERROR',
          info: {
            name: err.name,
            message: err.message,
            stack: err.stack
          }
        }
        if (debugSettingDataPreferences.getSync('saveErrorLog', true)) {
          await write(errorLogDir + Date.now() + '.txt', JSON.stringify(object))
        }
        if (debugSettingDataPreferences.getSync('globalErrorShowType', 0) === 0) {
          await promptAction.openToast({
            message: 'js 运行异常，错误名称：' + err.name + '，错误信息：' + err.message
          })
        }
        if (debugSettingDataPreferences.getSync('globalErrorShowType', 0) === 1) {
          this.context.eventHub.emit('dialog', 'js 运行异常', '名称：' + err.name + '\n信息：' + err.message)
        }
        if (debugSettingDataPreferences.getSync('autoUploadErrorLog', true) &&
          commonSettingDataPreferences.getSync('allService', true)) {
          if ((debugSettingDataPreferences.getSync('autoUploadErrorLogType',
            ['JS_ERROR', 'APP_CRASH']) as string[]).includes('JS_ERROR')) {
            this.context.eventHub.emit('uploadErrorLog', object.name, JSON.stringify(object))
          }
        }
      }
    })
    hiAppEvent.addWatcher({
      name: 'watcher',
      appEventFilters: [
        {
          domain: hiAppEvent.domain.OS,
          eventTypes: [hiAppEvent.EventType.FAULT]
        }
      ],
      onReceive: async (domain, appEventGroups) => {
        if (debugSettingDataPreferences.getSync('saveErrorLog', true)) {
          const promises = appEventGroups.map(async (item) => {
            await write(errorLogDir + Date.now() + '.txt', JSON.stringify(item))
          })
          await Promise.all(promises)
        }
        if (debugSettingDataPreferences.getSync('autoUploadErrorLog', true) &&
          commonSettingDataPreferences.getSync('allService', true)) {
          appEventGroups.forEach(item => {
            if ((debugSettingDataPreferences.getSync('autoUploadErrorLogType',
              ['JS_ERROR', 'APP_CRASH']) as string[]).includes(item.name)) {
              this.context.eventHub.emit('uploadErrorLog', item.name, JSON.stringify(item))
            }
          })
        }
      }
    })
    const netConnection = connection.createNetConnection()
    netConnection.register(() => {
    })
    netConnection.on('netAvailable', async (data) => {
      if (debugSettingDataPreferences.getSync('showNetAvailableStatusChange', false)) {
        await promptAction.openToast({
          message: '网络可用，数据网络句柄：' + data.netId
        })
      }
    })
    netConnection.on('netUnavailable', async () => {
      if (debugSettingDataPreferences.getSync('showNetAvailableStatusChange', false)) {
        await promptAction.openToast({
          message: '网络不可用'
        })
      }
    })
    netConnection.on('netBlockStatusChange', (data) => {
      if (debugSettingDataPreferences.getSync('showNetBlockStatusChange', false)) {
        this.context.eventHub.emit('dialog', '网络阻塞状态变化',
          '数据网络句柄：' + data.netHandle.netId + '\n是否堵塞：' + data.blocked ? '是' : '否')
      }
    })
    netConnection.on('netLost', async (data) => {
      if (debugSettingDataPreferences.getSync('showNetLost', false)) {
        await promptAction.openToast({
          message: '网络丢失，数据网络句柄：' + data.netId
        })
      }
    })
    netConnection.on('netCapabilitiesChange', (data) => {
      if (debugSettingDataPreferences.getSync('showNetCapabilitiesChange', false)) {
        const netBearType = data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR) ? '蜂窝' :
          data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_WIFI) ? 'Wi-Fi' :
            data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_BLUETOOTH) ? '蓝牙' :
              data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET) ? '以太网' :
                data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_VPN) ? 'VPN' : 'undefined'
        this.context.eventHub.emit('dialog', '网络能力变化',
          '数据网络句柄：' + data.netHandle.netId + '\n上行带宽：' + data.netCap.linkUpBandwidthKbps +
            ' KB/s\n下行带宽：' + data.netCap.linkDownBandwidthKbps + ' KB/s\n网络类型：' + netBearType)
      }
    })
    netQuality.on('netQosChange', async (list) => {
      if (list.length > 0) {
        const data = list[0]
        if (debugSettingDataPreferences.getSync('showNetQosChange', false)) {
          const pathType = data.pathType === netQuality.PathType.CELLULAR_PRIMARY ? '蜂窝主卡' :
            data.pathType === netQuality.PathType.CELLULAR_SECONDARY ? '蜂窝副卡' :
              data.pathType === netQuality.PathType.WIFI_PRIMARY ? '主 Wi-Fi' :
                data.pathType === netQuality.PathType.WIFI_SECONDARY ? '副 Wi-Fi' : 'undefined'
          this.context.eventHub.emit('dialog', '网络质量变化',
            '数据路径：' + pathType + '\n上行带宽：' + data.linkUpBandwidth + ' bps\n下行带宽：' + data.linkDownBandwidth +
              ' bps\n上行速率：' + data.linkUpRate + ' bps\n下行速率：' + data.linkDownRate + '\nRTT 时延：' + data.rttMs +
              ' ms\n上行发送空口缓冲时延：' + data.linkUpBufferDelayMs + ' ms\n上行发送空口缓冲时延占总缓冲时间的比例：' +
              data.linkUpBufferCongestionPercent + '%')
        }
        if (debugSettingDataPreferences.getSync('autoReportHighLatency', true) &&
          data.rttMs >= debugSettingDataPreferences.getSync('highLatencyThreshold', 200)) {
          netQuality.reportQoe({
            serviceType: 'default',
            qoeType: 'highLatency'
          })
          await promptAction.openToast({
            message: '自动反馈网络高时延传输体验成功'
          })
        }
      }
    })
    netQuality.on('netSceneChange', (list) => {
      if (list.length > 0) {
        const data = list[0]
        if (debugSettingDataPreferences.getSync('showNetSceneChange', false)) {
          const pathType = data.pathType === netQuality.PathType.CELLULAR_PRIMARY ? '蜂窝主卡' :
            data.pathType === netQuality.PathType.CELLULAR_SECONDARY ? '蜂窝副卡' :
              data.pathType === netQuality.PathType.WIFI_PRIMARY ? '主 Wi-Fi' :
                data.pathType === netQuality.PathType.WIFI_SECONDARY ? '副 Wi-Fi' : 'undefined'
          const scene = data.scene === 'normal' ? '正常' :
            data.scene === 'congestion' ? '拥塞' :
              data.scene === 'frequentHandover' ? '小区切换频繁' :
                data.scene === 'weakSignal' ? '弱信号' : 'undefined'
          const dataSpeedSimpleAction = data.recommendedAction === 'doCaching' ? '做缓存动作' :
            data.recommendedAction === 'suspendData' ? '停止发包' :
              data.recommendedAction === 'decreaseData' ? '降低发包速率' :
                data.recommendedAction === 'increaseData' ? '增加发包速率' :
                  data.recommendedAction === 'keepData' ? '保持当前发包速率' : 'undefined'
          const isLastPredictionValid = data.weakSignalPrediction?.isLastPredictionValid ? '是' : '否'
          this.context.eventHub.emit('dialog', '网络场景变化',
            '数据路径：' + pathType + '\n场景类型：' + scene + '\n建议的数传策略：' + dataSpeedSimpleAction +
              '\n最近一次的弱信号预测是否有效：' + isLastPredictionValid + '\n预计多长时间进入弱信号：' +
              data.weakSignalPrediction?.startTime + ' s\n预计在弱信号区域停留时长：' +
              data.weakSignalPrediction?.duration + ' s')
        }
      }
    })
    if (debugSettingDataPreferences.getSync('deleteErrorLogBeforeUpdateTimeWhenAppLaunch', true)) {
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
      const updateTime = bundleInfo.updateTime
      if (fileIo.accessSync(errorLogDir)) {
        const errorLogFileName = await fileIo.listFile(errorLogDir)
        const errorLogFilePath = errorLogFileName.map(item => errorLogDir + item)
        const promises = errorLogFilePath.map(async (item) => {
          const time = Number(item.replace(errorLogDir, '').replace('.txt', ''))
          if (time < updateTime) {
            await fileIo.unlink(item)
          }
        })
        await Promise.all(promises)
      }
    }
    const showAccountlistSheetAfterAppLaunch =
      commonSettingDataPreferences.getSync('showAccountlistSheetAfterAppLaunch', false)
    const accounts = await getAccountList()
    const isLogin = await getLoginStatus()
    if (showAccountlistSheetAfterAppLaunch) {
      if (!isLogin && accounts.length !== 0) {
        this.context.eventHub.emit('accountList')
      }
      if (isLogin && accounts.length > 1) {
        this.context.eventHub.emit('accountList')
      }
    }
    if (getCurrentNetworkBearerType() !== -1) {
      const checkVersionUpdate = commonSettingDataPreferences.getSync('checkVersionUpdate', 1)
      if (checkVersionUpdate === 2 ||
        (checkVersionUpdate === 1 && getCurrentNetworkBearerType() !== connection.NetBearType.BEARER_CELLULAR)) {
        try {
          const res = await updateManager.checkAppUpdate(this.context)
          if (res.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
            await updateManager.showUpdateDialog(this.context)
          }
        } catch (err) {
          await promptAction.openToast({
            message: '发生错误，错误码：' + err.code + '，错误信息：' + err.message
          })
        }
      }
    }
  }

  async onCreate(want: Want) {
    appRecovery.enableAppRecovery(appRecovery.RestartFlag.RESTART_WHEN_APP_FREEZE)
    const commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'commonSetting'
    })
    const allowContinue = commonSettingDataPreferences.getSync('allowContinue', true)
    if (!allowContinue) {
      await this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE)
    }
    if (allowContinue) {
      await this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE)
    }
    const allowRestore = commonSettingDataPreferences.getSync('allowRestore', true) as boolean
    this.context.setRestoreEnabled(allowRestore)
    if (deviceInfo.deviceType === '2in1') {
      statusBarManager.on('statusBarIconClick', async () => {
        await this.context.showAbility()
      })
      statusBarManager.on('rightMenuClick', (data) => {
        const datastring = JSON.stringify(data)
        const eventData = JSON.parse(datastring) as MenuCodeEventData
        this.context.eventHub.emit(eventData.data.menuCode)
      })
      const statusBarDataPreferences = preferences.getPreferencesSync(this.context, {
        name: 'statusBar'
      })
      const subscriber = commonEventManager.createSubscriberSync({
        events: ['BACKGROUNDABILITY_EVENT_PREPARETOTERMINATE']
      })
      await commonEventManager.subscribeToEvent(subscriber, async (data) => {
        if (data.event === 'BACKGROUNDABILITY_EVENT_PREPARETOTERMINATE') {
          statusBarManager.removeFromStatusBar(this.context)
          statusBarDataPreferences.putSync('exist', false)
          await this.context.terminateSelf()
        }
      })
      const statusBar = commonSettingDataPreferences.getSync('statusBar', false)
      if (statusBar) {
        const fileData = this.context.resourceManager.getRawFileContentSync('icon.png')
        const imageSource = image.createImageSource(fileData.buffer)
        const pixelMap = await imageSource.createPixelMap()
        await imageSource.release()
        statusBarManager.addToStatusBar(this.context, {
          icons: {
            black: pixelMap,
            white: pixelMap
          },
          quickOperation: {
            title: '',
            height: 1,
            abilityName: '',
            moduleName: 'entry',
            loadingStatus: true
          }
        })
        await pixelMap.release()
        statusBarManager.updateStatusBarMenu(this.context, [
          [
            {
              title: '打开',
              menuAction: {
                abilityName: 'EntryAbility'
              }
            }
          ],
          [
            {
              title: '文件',
              menuAction: {
                abilityName: 'EntryAbility',
                notifyOnly: true,
                menuCode: 'file'
              }
            },
            {
              title: '传输',
              menuAction: {
                abilityName: 'EntryAbility',
                notifyOnly: true,
                menuCode: 'transfer'
              }
            }
          ]
        ])
        setTimeout(async () => {
          await this.context.startAbility({
            bundleName: 'com.zhuzx.webdavhelper',
            abilityName: 'BackGroundAbility'
          }, {
            processMode: contextConstant.ProcessMode.NEW_PROCESS_ATTACH_TO_STATUS_BAR_ITEM,
            startupVisibility: contextConstant.StartupVisibility.STARTUP_HIDE
          })
          statusBarDataPreferences.putSync('exist', true)
        }, 200)
      }
    }
    const applicationContext = this.context.getApplicationContext()
    const colorMode = commonSettingDataPreferences.getSync('colorMode', 0)
    if (colorMode === 0) {
      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    }
    if (colorMode === 1) {
      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
    }
    if (colorMode === 2) {
      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    }
    const debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'debugSetting'
    })
    if (deviceInfo.deviceType !== 'tablet') {
      const processCache = debugSettingDataPreferences.getSync('processCache', true) as boolean
      applicationContext.setSupportedProcessCache(processCache)
    }
    await this.appInit(want)
    await clearNouseData(this.context)
    await loginBestPathAccount(this.context)
  }

  async onNewWant(want: Want) {
    await this.appInit(want)
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    await this.windowInit(windowStage)
  }

  async onWindowStageRestore(windowStage: window.WindowStage) {
    await this.windowInit(windowStage)
  }

  async onPrepareToTerminateAsync(): Promise<boolean> {
    const statusBarDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'statusBar'
    })
    const statusBarExist = statusBarDataPreferences.getSync('exist', false) as boolean
    if (statusBarExist) {
      await this.context.hideAbility()
    }
    return statusBarExist
  }

  onBackPressed() {
    const commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'commonSetting'
    })
    const destroyWhenBackPressed = commonSettingDataPreferences.getSync('destroyWhenBackPressed', false)
    if (!destroyWhenBackPressed) {
      return true
    } else {
      return false
    }
  }

  async onContinue(wantParam: Record<string, Object>) {
    if (wantParam.version !== 5) {
      await promptAction.openToast({
        message: '接续失败，原因：目标端应用版本号与发起端不匹配'
      })
      return AbilityConstant.OnContinueResult.MISMATCH
    }
    const commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'commonSetting'
    })
    const exitAfterContinue = commonSettingDataPreferences.getSync('exitAfterContinue', true)
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = exitAfterContinue
    return AbilityConstant.OnContinueResult.AGREE
  }

  onCollaborate() {
    const commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'commonSetting'
    })
    const acceptCollaborate = commonSettingDataPreferences.getSync('acceptCollaborate', true)
    if (!acceptCollaborate) {
      return 1
    } else {
      return 0
    }
  }

  async onMemoryLevel(level: AbilityConstant.MemoryLevel) {
    const debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
      name: 'debugSetting'
    })
    const showMemoryLevelChange = debugSettingDataPreferences.getSync('showMemoryLevelChange', false)
    if (showMemoryLevelChange) {
      let memoryLevel = ''
      if (level === AbilityConstant.MemoryLevel.MEMORY_LEVEL_MODERATE) {
        memoryLevel = '适中'
      }
      if (level === AbilityConstant.MemoryLevel.MEMORY_LEVEL_LOW) {
        memoryLevel = '低'
      }
      if (level === AbilityConstant.MemoryLevel.MEMORY_LEVEL_CRITICAL) {
        memoryLevel = '高'
      }
      await promptAction.openToast({
        message: '当前内存占用' + memoryLevel
      })
    }
  }
}