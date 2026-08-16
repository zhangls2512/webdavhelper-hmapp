import { common, wantAgent } from '@kit.AbilityKit'
import { sendablePreferences } from '@kit.ArkData'
import { taskpool } from '@kit.ArkTS'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { quickBarManager } from '@kit.DeskTopExtensionKit'
import { image } from '@kit.ImageKit'
import { notificationManager } from '@kit.NotificationKit'
import {
  hdsMaterial,
  HdsNavigation,
  HdsNavigationTitleMode,
  HdsSideMenu,
  HdsSideMenuMainItem,
  HdsTabs,
  HdsTabsController
} from '@kit.UIDesignKit'
import { AccountInfo, importAccounts } from '../common/Account'
import { getCurrentNetworkBearerType } from '../common/Network'
import { getFlushPreference, getTempPreference } from '../common/Preference'
import { getPreferType } from '../common/Prefertype'
import { getSizeString } from '../common/Stringformat'
import { download, upload } from '../common/Transfertask'
import Cleardata from './Cleardata'
import Filelist from './Filelist'
import Me from './Me'
import Notice from './Notice'
import Transfer from './Transfer'
import Uploaderrorlog from './Uploaderrorlog'

export interface TransferTaskItem {
  id: string,
  path: string,
  name: string,
  transferredSize: number,
  totalSize: number,
  status: string,
  errCode: number | string,
  type: string,
  accountInfo: AccountInfo,
  authorization: string,
  srcFileUri: string,
  destDownloadPath: string,
  speed: number
}

@Entry
@ComponentV2
struct Index {
  @Provider() isShowAccountlistSheet: boolean = false
  @Provider() isShowUploaderrorlogSheet: boolean = false
  @Local errorType: string = ''
  @Local errorObject: string = ''
  @Local backgroundImagePixelMap: PixelMap | undefined = undefined
  @Local preferType: SheetType = SheetType.CENTER
  @Local index: number = 0
  @Local isShowCleardataSheet: boolean = false
  @Local isShowNoticeSheet: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  controller = new HdsTabsController()
  intervalId = -1

  onBackPress() {
    if (this.index === 0) {
      const filelist = getTempPreference(this.context, 'back', 'filelist', false)
      if (!filelist) {
        return false
      } else {
        this.context.eventHub.emit('backFilelist')
        return true
      }
    } else {
      return false
    }
  }

  async getBackgroundImage() {
    const backgroundImagePath = this.context.filesDir + '/media/backgroundimage.png'
    const res = fileIo.accessSync(backgroundImagePath)
    if (res) {
      const backgroundImageSource = image.createImageSource(backgroundImagePath)
      const backgroundImagePixelMap = await backgroundImageSource.createPixelMap()
      await backgroundImageSource.release()
      return backgroundImagePixelMap
    }
    return
  }

  @Builder
  tabBuilder(index: number, image: Resource, title: string) {
    Column() {
      Image(image)
        .fillColor(this.index === index ? $r('sys.color.icon_emphasize') : $r('sys.color.icon_secondary'))
        .height(24)
        .width(24)
      Text(title)
        .fontColor(this.index === index ? $r('sys.color.font_emphasize') : '')
        .fontSize($r('sys.float.ohos_id_text_size_body3'))
        .margin({
          top: 4
        })
    }
  }

  @Builder
  CleardataSheetBuilder() {
    Cleardata()
  }

  @Builder
  NoticeSheetBuilder() {
    Notice()
  }

  @Builder
  UploaderrorlogSheetBuilder() {
    Uploaderrorlog({
      errorType: this.errorType,
      errorObject: this.errorObject
    })
  }

  build() {
    Column() {
      if (deviceInfo.deviceType !== '2in1') {
        HdsTabs({
          controller: this.controller
        }) {
          TabContent() {
            HdsNavigation() {
              Filelist()
                .padding({
                  top: 56
                })
            }
            .hideBackButton(true)
            .mode(NavigationMode.Stack)
            .padding({
              top: 36
            })
            .recoverable(true)
            .titleBar({
              content: {
                title: {
                  mainTitle: '文件'
                }
              }
            })
            .titleMode(HdsNavigationTitleMode.MINI)
          }
          .tabBar(this.tabBuilder(0, $r('app.media.file'), '文件'))
          .bindSheet(this.isShowNoticeSheet!!, this.NoticeSheetBuilder(), {
            preferType: this.preferType,
            title: {
              title: '消息通知'
            }
          })

          TabContent() {
            HdsNavigation() {
              Transfer()
                .padding({
                  top: 56
                })
            }
            .hideBackButton(true)
            .mode(NavigationMode.Stack)
            .padding({
              top: 36
            })
            .recoverable(true)
            .titleBar({
              content: {
                title: {
                  mainTitle: '传输'
                }
              }
            })
            .titleMode(HdsNavigationTitleMode.MINI)
          }
          .tabBar(this.tabBuilder(1, $r('app.media.transfer'), '传输'))

          TabContent() {
            HdsNavigation() {
              Me()
            }
            .hideBackButton(true)
            .mode(NavigationMode.Stack)
            .padding({
              top: 36
            })
            .recoverable(true)
            .titleBar({
              content: {
                title: {
                  mainTitle: '我的'
                }
              }
            })
            .titleMode(HdsNavigationTitleMode.MINI)
          }
          .tabBar(this.tabBuilder(2, $r('app.media.me'), '我的'))
        }
        .barBackgroundBlurStyle(BlurStyle.Regular)
        .barFloatingStyle({
          barBottomMargin: 24,
          adaptToHandedness: true,
          thermoCtrl: true,
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.ADAPTIVE,
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
          }
        })
        .barOverlap(true)
        .barPosition(BarPosition.End)
        .barWidth(240)
        .scrollable(false)
        .onChange(index => {
          this.index = index
        })
        .onAnimationStart((index, targetIndex) => {
          if (targetIndex === 0) {
            this.context.eventHub.emit('refreshFilelist')
          }
          if (targetIndex === 2) {
            this.context.eventHub.emit('refreshMe')
          }
        })
        .bindSheet(this.isShowUploaderrorlogSheet!!, this.UploaderrorlogSheetBuilder(), {
          height: SheetSize.FIT_CONTENT,
          preferType: this.preferType,
          title: {
            title: '上传故障日志'
          }
        })
      }
      if (deviceInfo.deviceType === '2in1') {
        Row() {
          HdsSideMenu({
            items: [
              new HdsSideMenuMainItem({
                icon: $r('app.media.file_tab'),
                label: '文件'
              }),
              new HdsSideMenuMainItem({
                icon: $r('app.media.transfer'),
                label: '传输'
              }),
              new HdsSideMenuMainItem({
                icon: $r('app.media.me_tab'),
                label: '我的'
              })
            ],
            selectedIndex: 0,
            $selectedIndex: (index) => {
              this.index = index
              if (index === 0) {
                this.context.eventHub.emit('refreshFilelist')
              }
              if (index === 2) {
                this.context.eventHub.emit('refreshMe')
              }
            }
          })
            .padding({
              top: $r('sys.float.ohos_id_default_padding_top')
            })
            .width(240)
            .bindSheet(this.isShowNoticeSheet!!, this.NoticeSheetBuilder(), {
              preferType: this.preferType,
              title: {
                title: '消息通知'
              }
            })
          Divider()
            .vertical(true)
          if (this.index === 0) {
            Filelist()
              .layoutWeight(1)
          }
          if (this.index === 1) {
            Transfer()
              .layoutWeight(1)
          }
          if (this.index === 2) {
            Me()
              .layoutWeight(1)
          }
        }
        .alignItems(VerticalAlign.Top)
        .bindSheet(this.isShowUploaderrorlogSheet!!, this.UploaderrorlogSheetBuilder(), {
          height: SheetSize.FIT_CONTENT,
          preferType: this.preferType,
          title: {
            title: '上传故障日志'
          }
        })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_secondary'))
    .backgroundImage(this.backgroundImagePixelMap)
    .backgroundImageSize(ImageSize.FILL)
    .onAppear(async () => {
      this.intervalId = setInterval(async () => {
        const transferTaskArray: TransferTaskItem[] = []
        const transferTaskDataPreferences = sendablePreferences.getPreferencesSync(this.context, {
          name: 'transferTask'
        })
        const transferTaskObject = transferTaskDataPreferences.getAllSync() as object
        Object.keys(transferTaskObject).forEach(item => {
          const transferTaskString = transferTaskObject[item] as string
          const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
          transferTaskArray.push(transferTask)
        })
        const processingTransferTask = transferTaskArray.find(item => item.status === 'processing')
        if (!processingTransferTask) {
          const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(this.context)
          if (continuousTasks.length > 0) {
            await backgroundTaskManager.stopBackgroundRunning(this.context)
          }
          const pendingTransferTaskArray = transferTaskArray.filter(item => item.status === 'pending')
          for (let i = 0; i < pendingTransferTaskArray.length; i++) {
            const item = pendingTransferTaskArray[i]
            let exec = true
            if (getCurrentNetworkBearerType() === 0) {
              const cellularDataUseRemind =
                getFlushPreference(this.context, 'commonSetting', 'cellularDataUseRemind', 0)
              if (cellularDataUseRemind === 0 ||
                (cellularDataUseRemind === 1 && item.totalSize > 200 * Math.pow(1024, 2))) {
                exec = false
              }
            }
            if (exec) {
              const wandAgent = await wantAgent.getWantAgent({
                wants: [
                  {
                    bundleName: 'com.zhuzx.webdavhelper',
                    abilityName: 'EntryAbility'
                  }
                ],
                actionType: wantAgent.OperationType.START_ABILITY,
                requestCode: 0,
                wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
              })
              let taskLength = -1
              while (taskLength !== 0) {
                const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(this.context)
                taskLength = continuousTasks.length
              }
              try {
                await backgroundTaskManager.startBackgroundRunning(this.context, ['dataTransfer'], wandAgent)
              } catch {
              }
              item.status = 'processing'
              transferTaskDataPreferences.putSync(item.id, JSON.stringify(item))
              if (item.type === 'download') {
                const task = new taskpool.LongTask(download, this.context, item.id)
                await taskpool.execute(task)
              }
              if (item.type === 'upload') {
                const task = new taskpool.LongTask(upload, this.context, item.id)
                await taskpool.execute(task)
              }
            }
          }
        }
        if (processingTransferTask) {
          let wz = ''
          if (processingTransferTask.type === 'download') {
            wz = '下载'
          }
          if (processingTransferTask.type === 'upload') {
            wz = '上传'
          }
          const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(this.context)
          if (continuousTasks.length > 0) {
            const progress =
              Number((processingTransferTask.transferredSize / processingTransferTask.totalSize).toFixed(2)) * 100
            await quickBarManager.setProgressValue(this.context, progress, 100)
            await notificationManager.publish({
              content: {
                notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
                systemLiveView: {
                  typeCode: 8,
                  title: '正在' + wz + '文件：' + processingTransferTask.name,
                  text: '进度：' + progress + '% (' + getSizeString(processingTransferTask.transferredSize) + '/' +
                    getSizeString(processingTransferTask.totalSize) + ')'
                }
              },
              id: continuousTasks[0].notificationId,
              notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
              template: {
                name: 'downloadTemplate',
                data: {
                  title: '正在' + wz + '文件，进度：' + progress + '%',
                  fileName: processingTransferTask.name,
                  progressValue: progress
                }
              }
            })
          }
        }
      }, 1000)
      this.context.eventHub.on('clearData', () => {
        if (!this.isShowCleardataSheet) {
          this.isShowCleardataSheet = true
        }
      })
      this.context.eventHub.on('notice', () => {
        if (!this.isShowNoticeSheet) {
          this.isShowNoticeSheet = true
        }
      })
      const promptAction = this.UIContext.getPromptAction()
      this.context.eventHub.on('file', async () => {
        if (deviceInfo.deviceType !== '2in1') {
          this.controller.changeIndex(0)
          this.context.eventHub.emit('refreshFilelist')
        }
        if (deviceInfo.deviceType === '2in1') {
          await promptAction.showDialog({
            title: '提示',
            message: '暂不支持',
            buttons: [
              {
                text: '确定',
                color: $r('sys.color.font_emphasize')
              }
            ]
          })
        }
      })
      this.context.eventHub.on('transfer', async () => {
        if (deviceInfo.deviceType !== '2in1') {
          this.controller.changeIndex(1)
        }
        if (deviceInfo.deviceType === '2in1') {
          await promptAction.showDialog({
            title: '提示',
            message: '暂不支持',
            buttons: [
              {
                text: '确定',
                color: $r('sys.color.font_emphasize')
              }
            ]
          })
        }
      })
      this.context.eventHub.on('wantUri', async (wantUri: string) => {
        await importAccounts(this.context, wantUri)
      })
      this.context.eventHub.on('dialog', async (title: string, message: string) => {
        await promptAction.showDialog({
          title: title,
          message: message,
          buttons: [
            {
              text: '确定',
              color: $r('sys.color.font_emphasize')
            }
          ]
        })
      })
      this.context.eventHub.on('uploadErrorLog', (errorType: string, errorObject: string) => {
        this.errorType = errorType
        this.errorObject = errorObject
        this.isShowUploaderrorlogSheet = true
      })
      this.preferType = getPreferType(this.UIContext)
      this.context.eventHub.on('refreshIndex', async () => {
        this.backgroundImagePixelMap = await this.getBackgroundImage()
      })
      this.backgroundImagePixelMap = await this.getBackgroundImage()
    })
    .onDisAppear(() => {
      if (this.intervalId !== -1) {
        clearInterval(this.intervalId)
      }
      this.context.eventHub.off('refreshIndex')
      this.context.eventHub.off('uploadErrorLog')
      this.context.eventHub.off('dialog')
      this.context.eventHub.off('wantUri')
      this.context.eventHub.off('transfer')
      this.context.eventHub.off('file')
      this.context.eventHub.off('notice')
      this.context.eventHub.off('clearData')
    })
    .bindSheet(this.isShowCleardataSheet!!, this.CleardataSheetBuilder(), {
      preferType: this.preferType
    })
  }
}