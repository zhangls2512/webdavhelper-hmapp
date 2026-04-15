import { common } from '@kit.AbilityKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { LengthMetrics } from '@kit.ArkUI'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { hiAppEvent } from '@kit.PerformanceAnalysisKit'
import { systemShare } from '@kit.ShareKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { read } from '../common/File'
import copy from '../common/Pasteboard'
import { getSizeString, getTimeStringFromTimeStamp } from '../common/Stringformat'
import { Type } from './Autouploaderrorlogtype'

interface ErrorLogItem {
  type: string,
  content: string,
  time: string,
  externalLog: string[]
}

@Builder
export function ErrorlogBuilder() {
  Errorlog()
}

@ComponentV2
struct Errorlog {
  @Local errorLogArray: ErrorLogItem[] = []
  @Local hoverId: number | string = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  typeArray: Type[] = [
    {
      name: '全部',
      value: ''
    },
    {
      name: 'js 运行异常',
      value: 'JS_ERROR'
    },
    {
      name: '崩溃',
      value: 'APP_CRASH'
    },
    {
      name: '应用冻屏',
      value: 'APP_FREEZE'
    },
    {
      name: '资源泄漏',
      value: 'RESOURCE_OVERLIMIT'
    },
    {
      name: '地址越界',
      value: 'ADDRESS_SANITIZER'
    },
    {
      name: '主线程超时',
      value: 'MAIN_THREAD_JANK'
    },
    {
      name: '任务执行超时',
      value: 'APP_HICOLLIE'
    },
    {
      name: '应用终止',
      value: 'APP_KILLED'
    },
    {
      name: 'ArkWeb 抛滑丢帧',
      value: 'SCROLL_ARKWEB_FLING_JANK'
    },
    {
      name: '启动耗时',
      value: 'APP_LAUNCH'
    },
    {
      name: '滑动丢帧',
      value: 'SCROLL_JANK'
    },
    {
      name: 'CPU 高负载',
      value: 'CPU_USAGE_HIGH'
    },
    {
      name: '24 小时功耗器件分解统计',
      value: 'BATTERY_USAGE'
    },
    {
      name: '音频卡顿',
      value: 'AUDIO_JANK_FRAME'
    }
  ]

  async get() {
    this.errorLogArray = []
    const errorLogDir = this.context.filesDir + '/log/error/'
    if (fileIo.accessSync(errorLogDir)) {
      const errorLogFileName = await fileIo.listFile(errorLogDir)
      const errorLogFilePath = errorLogFileName.map(item => errorLogDir + item)
      const promises = errorLogFilePath.map(async (item) => {
        const filestring = await read(item)
        try {
          const errorLog = JSON.parse(filestring) as hiAppEvent.AppEventGroup
          let externalLog: string[] = []
          if (errorLog.appEventInfos) {
            errorLog.appEventInfos.forEach(item => {
              const external_log = item.params['external_log'] as string[]
              externalLog = externalLog.concat(external_log)
            })
          }
          this.errorLogArray.push({
            type: errorLog.name,
            content: filestring,
            time: getTimeStringFromTimeStamp(Number(item.replace(errorLogDir, '').replace('.txt', ''))),
            externalLog: externalLog
          })
        } catch {
        }
      })
      await Promise.all(promises)
    }
  }

  async filter(type: string) {
    this.errorLogArray = []
    const errorLogDir = this.context.filesDir + '/log/error/'
    if (fileIo.accessSync(errorLogDir)) {
      const errorLogFileName = await fileIo.listFile(errorLogDir)
      const errorLogFilePath = errorLogFileName.map(item => errorLogDir + item)
      const promises = errorLogFilePath.map(async (item) => {
        const filestring = await read(item)
        try {
          const errorLog = JSON.parse(filestring) as hiAppEvent.AppEventGroup
          let externalLog: string[] = []
          if (errorLog.appEventInfos) {
            errorLog.appEventInfos.forEach(item => {
              const external_log = item.params['external_log'] as string[]
              externalLog = externalLog.concat(external_log)
            })
          }
          if (errorLog.name === type) {
            this.errorLogArray.push({
              type: errorLog.name,
              content: filestring,
              time: getTimeStringFromTimeStamp(Number(item.replace(errorLogDir, '').replace('.txt', ''))),
              externalLog: externalLog
            })
          }
        } catch {
        }
      })
      await Promise.all(promises)
    }
  }

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          Select(this.typeArray.map((item): SelectOption => {
            return {
              value: item.name
            }
          }))
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .selected(0)
            .value('全部')
            .onSelect(async (index) => {
              if (index !== 0) {
                await this.filter(this.typeArray[index].value)
              }
              if (index === 0) {
                await this.get()
              }
            })
          List() {
            if (this.errorLogArray.length === 0) {
              ListItem() {
                Text('无数据')
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
            }
            ForEach(this.errorLogArray, (errorLogItem: ErrorLogItem, errorLogIndex) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('类型')
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Text(errorLogItem.type)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .layoutWeight(1)
                      .textAlign(TextAlign.End)
                  }
                  .borderRadius(12)
                  .padding(12)

                  Divider()
                    .padding({
                      left: 12,
                      right: 12
                    })
                  Row() {
                    Text('内容')
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Text(errorLogItem.content)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .layoutWeight(1)
                      .textAlign(TextAlign.End)
                  }
                  .borderRadius(12)
                  .padding(12)
                  .stateStyles({
                    normal: {
                      .backgroundColor(this.hoverId === errorLogIndex ? $r('sys.color.interactive_hover') :
                        $r('sys.color.ohos_id_color_card_bg'))
                    },
                    pressed: {
                      .backgroundColor($r('sys.color.interactive_pressed'))
                    }
                  })
                  .onHover((isHover) => {
                    if (!isHover) {
                      this.hoverId = -1
                    }
                    if (isHover) {
                      this.hoverId = errorLogIndex
                    }
                  })
                  .onClick(async () => {
                    await copy(this.context, this.UIContext, errorLogItem.content)
                  })

                  Divider()
                    .padding({
                      left: 12,
                      right: 12
                    })
                  Row() {
                    Text('时间')
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Text(errorLogItem.time)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .layoutWeight(1)
                      .textAlign(TextAlign.End)
                  }
                  .borderRadius(12)
                  .padding(12)

                  ForEach(errorLogItem.externalLog, (externalLogItem: string, externalLogIndex) => {
                    Divider()
                      .padding({
                        left: 12,
                        right: 12
                      })
                    Row() {
                      Text(externalLogItem)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                      Image($r('app.media.right'))
                        .fillColor($r('sys.color.icon_fourth'))
                        .height(12)
                        .width(12)
                    }
                    .borderRadius(12)
                    .padding(12)
                    .stateStyles({
                      normal: {
                        .backgroundColor(this.hoverId === errorLogIndex + ',' + externalLogIndex ?
                          $r('sys.color.interactive_hover') : $r('sys.color.ohos_id_color_card_bg'))
                      },
                      pressed: {
                        .backgroundColor($r('sys.color.interactive_pressed'))
                      }
                    })
                    .onHover((isHover) => {
                      if (!isHover) {
                        this.hoverId = -1
                      }
                      if (isHover) {
                        this.hoverId = errorLogIndex + ',' + externalLogIndex
                      }
                    })
                    .onClick(async () => {
                      const shareData = new systemShare.SharedData({
                        utd: uniformTypeDescriptor.UniformDataType.FILE,
                        title: externalLogItem.substring(externalLogItem.lastIndexOf('/') + 1),
                        description: getSizeString(fileIo.statSync(externalLogItem).size),
                        uri: fileUri.getUriFromPath(externalLogItem)
                      })
                      const shareController = new systemShare.ShareController(shareData)
                      await shareController.show(this.context, {})
                    })
                  })
                }
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                .padding($r('sys.float.ohos_id_corner_radius_mark'))
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
            })
            ListItem()
              .margin({
                bottom: 28
              })
          }
          .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          top: 64
        })
      }
      .padding({
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
      })
    }
    .backgroundColor($r('app.color.sheet_background'))
    .recoverable(true)
    .titleBar({
      padding: {
        end: LengthMetrics.vp(60)
      },
      style: {
        scrollEffectOpts: {
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR
        },
        originalStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('sys.color.font_primary')
            },
            backIconStyle: {
              iconColor: $r('sys.color.icon_primary')
            }
          }
        },
        thermoCtrl: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      },
      content: {
        title: {
          mainTitle: '故障日志'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      await this.get()
    })
  }
}