import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { taskpool } from '@kit.ArkTS'
import { display } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { HdsTabs, HdsTabsController } from '@kit.UIDesignKit'
import { AccountInfo, importAccounts } from '../common/Account'
import { getCurrentNetworkBearerType } from '../common/Network'
import { getPreferType } from '../common/Prefertype'
import { download, upload } from '../common/Transfertask'
import Accountlist from './Accountlist'
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
  errCode: number,
  type: string,
  accountInfo: AccountInfo,
  authorization: string,
  srcFileUri: string,
  backupTaskId: string
}

@Entry
@ComponentV2
struct Index {
  @Provider() isShowAccountlistSheet: boolean = false
  @Provider() isShowUploaderrorlogSheet: boolean = false
  @Local errorType: string = ''
  @Local errorObject: string = ''
  @Local backgroundImagePixelMap: PixelMap | undefined = undefined
  @Local preferType: number = 1
  @Local index: number = 0
  @Local title: string = '文件'
  @Local isShowCleardataSheet: boolean = false
  @Local isShowNoticeSheet: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  controller = new HdsTabsController()
  intervalId = -1
  backDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'back'
  })
  commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'commonSetting'
  })

  onBackPress() {
    if (this.index === 1) {
      const filelist = this.backDataPreferences.getSync('filelist', false)
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

  async get() {
    this.backgroundImagePixelMap = await this.getBackgroundImage()
  }

  async getBackgroundImage() {
    const backgroundImagePath = this.context.filesDir + '/media/backgroundimage.png'
    const res = fileIo.accessSync(backgroundImagePath)
    if (res) {
      const backgroundImageSource = image.createImageSource(backgroundImagePath)
      const backgroundImagePixelMap = await backgroundImageSource.createPixelMap()
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
  AccountlistSheetBuilder() {
    Accountlist()
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
      if (this.preferType === 0) {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({
            bottom: $r('sys.float.ohos_id_elements_margin_vertical_l'),
            left: $r('sys.float.ohos_id_elements_margin_horizontal_l')
          })
      }
      HdsTabs({
        controller: this.controller
      }) {

        TabContent() {
          Filelist()
        }
        .tabBar(this.tabBuilder(0, $r('app.media.file'), '文件'))
        .bindSheet(this.isShowNoticeSheet!!, this.NoticeSheetBuilder(), {
          preferType: this.preferType,
          title: {
            title: '消息通知'
          }
        })

        TabContent() {
          Transfer()
        }
        .tabBar(this.tabBuilder(1, $r('app.media.transfer'), '传输'))

        TabContent() {
          Me()
            .height('100%')
        }
        .tabBar(this.tabBuilder(3, $r('app.media.me'), '我的'))
      }
      .barBackgroundBlurStyle(BlurStyle.Regular)
      .barPosition(this.preferType === 0 ? BarPosition.End : BarPosition.Start)
      .barWidth(this.preferType === 0 ? '100%' : 56)
      .scrollable(false)
      .vertical(this.preferType === 0 ? false : true)
      .onChange((index) => {
        this.index = index
      })
      .onAnimationStart((index, targetIndex) => {
        if (targetIndex === 0) {
          this.title = '文件'
          this.context.eventHub.emit('refreshFilelist')
        }
        if (targetIndex === 1) {
          this.title = '传输'
        }
        if (targetIndex === 2) {
          this.title = '我的'
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
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_secondary'))
    .backgroundImage(this.backgroundImagePixelMap)
    .backgroundImageSize(ImageSize.FILL)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({
      bottom: this.preferType === 0 ? 36 : 0,
      top: this.preferType === 0 ? 12 : 0
    })
    .onAppear(async () => {
      this.intervalId = setInterval(async () => {
        const transferTaskArray: TransferTaskItem[] = []
        const transferTaskDataPreferences = preferences.getPreferencesSync(this.context, {
          name: 'transferTask'
        })
        const transferTaskObject = transferTaskDataPreferences.getAllSync() as object
        const transferTaskIdArray = Object.keys(transferTaskObject)
        transferTaskIdArray.forEach(item => {
          const transferTaskString = transferTaskObject[item] as string
          const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
          transferTaskArray.push(transferTask)
        })
        if (!transferTaskArray.find(item => item.status === 'processing')) {
          const pendingTransferTaskArray = transferTaskArray.filter(item => item.status === 'pending')
          for (let i = 0; i < pendingTransferTaskArray.length; i++) {
            const item = pendingTransferTaskArray[i]
            let exec = true
            if (getCurrentNetworkBearerType() === 0) {
              const cellularDataUseRemind = this.commonSettingDataPreferences.getSync('cellularDataUseRemind', 0)
              if (cellularDataUseRemind === 0 ||
                (cellularDataUseRemind === 1 && item.totalSize > 200 * Math.pow(1024, 2))) {
                exec = false
              }
            }
            if (exec) {
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
      this.context.eventHub.on('accountList', () => {
        if (!this.isShowAccountlistSheet) {
          this.isShowAccountlistSheet = true
        }
      })
      this.context.eventHub.on('file', () => {
        this.controller.changeIndex(0)
        this.context.eventHub.emit('refreshFilelist')
      })
      this.context.eventHub.on('transfer', () => {
        this.controller.changeIndex(1)
      })
      this.context.eventHub.on('wantUri', async (wantUri: string) => {
        await importAccounts(this.context, wantUri)
      })
      const promptAction = this.UIContext.getPromptAction()
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
      display.on('change', () => {
        setTimeout(() => {
          this.preferType = getPreferType(this.UIContext)
        }, 200)
      })
      this.context.eventHub.on('refreshIndex', async () => {
        await this.get()
      })
      await this.get()
    })
    .onDisAppear(() => {
      if (this.intervalId !== -1) {
        clearInterval(this.intervalId)
      }
      this.context.eventHub.off('refreshIndex')
      this.context.eventHub.off('uploadErrorLog')
      this.context.eventHub.off('dialog')
      this.context.eventHub.off('wantUri')
      this.context.eventHub.off('file')
      this.context.eventHub.off('accountList')
      this.context.eventHub.off('notice')
      this.context.eventHub.off('clearData')
      display.off('change')
    })
    .bindSheet(this.isShowCleardataSheet!!, this.CleardataSheetBuilder(), {
      preferType: this.preferType,
      title: {
        title: '清理数据'
      }
    })
  }
}