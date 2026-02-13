import { common } from '@kit.AbilityKit'
import { LengthMetrics } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { hiAppEvent } from '@kit.PerformanceAnalysisKit'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'
import { read } from '../common/File'
import copy from '../common/Pasteboard'
import { getTimeStringFromTimeStamp } from '../common/Stringformat'

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
          const externalLog: string[] = []
          if (errorLog.appEventInfos) {
            errorLog.appEventInfos.forEach(item => {
              const external_log = item.params['external_log'] as string[] | undefined
              if (external_log) {
                external_log.forEach(item => {
                  if (item) {
                    externalLog.push(item)
                  }
                })
              }
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
          const externalLog: string[] = []
          if (errorLog.appEventInfos) {
            errorLog.appEventInfos.forEach(item => {
              const external_log = item.params['external_log'] as string[] | undefined
              if (external_log) {
                external_log.forEach(item => {
                  if (item) {
                    externalLog.push(item)
                  }
                })
              }
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
          Select([
            { value: '全部' },
            { value: 'js 运行异常' },
            { value: '应用崩溃' },
            { value: '应用冻屏' },
            { value: '应用查杀' },
            { value: '应用启动耗时' },
            { value: '资源泄漏' },
            { value: '地址越界' },
            { value: '主线程超时' },
            { value: '滑动丢帧' },
            { value: 'CPU 高负载' },
            { value: '24 小时功耗器件分解统计' }
          ])
            .selected(0)
            .value('全部')
            .onSelect(async (index: number) => {
              if (index === 0) {
                await this.get()
              }
              if (index === 1) {
                await this.filter('JS_ERROR')
              }
              if (index === 2) {
                await this.filter('APP_CRASH')
              }
              if (index === 3) {
                await this.filter('APP_FREEZE')
              }
              if (index === 4) {
                await this.filter('APP_KILLED')
              }
              if (index === 5) {
                await this.filter('APP_LAUNCH')
              }
              if (index === 6) {
                await this.filter('RESOURCE_OVERLIMIT')
              }
              if (index === 7) {
                await this.filter('ADDRESS_SANITIZER')
              }
              if (index === 8) {
                await this.filter('MAIN_THREAD_JANK')
              }
              if (index === 9) {
                await this.filter('SCROLL_JANK')
              }
              if (index === 10) {
                await this.filter('CPU_USAGE_HIGH')
              }
              if (index === 11) {
                await this.filter('BATTERY_USAGE')
              }
            })
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
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
                  .width('100%')

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
                  .width('100%')
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
                  .width('100%')

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
                    .width('100%')
                    .onHover((isHover) => {
                      if (!isHover) {
                        this.hoverId = -1
                      }
                      if (isHover) {
                        this.hoverId = errorLogIndex + ',' + externalLogIndex
                      }
                    })
                    .onClick(async () => {
                      const filestring = await read(externalLogItem)
                      if (filestring !== 'fail') {
                        const promptAction = this.UIContext.getPromptAction()
                        const data = await promptAction.showDialog({
                          title: externalLogItem,
                          message: filestring,
                          buttons: [
                            {
                              text: '关闭',
                              color: $r('sys.color.warning')
                            },
                            {
                              text: '复制',
                              color: $r('sys.color.font_emphasize')
                            }
                          ]
                        })
                        if (data.index === 1) {
                          await copy(this.context, this.UIContext, filestring)
                        }
                      }
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
          }
          .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding({
        bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
      })
    }
    .backgroundColor($r('app.color.sheet_background'))
    .titleBar({
      padding: {
        end: LengthMetrics.vp(60)
      },
      style: {
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
      },
      enableComponentSafeArea: true
    })
    .onAppear(async () => {
      await this.get()
    })
  }
}