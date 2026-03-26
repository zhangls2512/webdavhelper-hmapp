import { appRecovery, common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { deviceInfo } from '@kit.BasicServicesKit'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'
import { getFlushPreference, setFlushPreference } from '../common/Preference'

@Builder
export function DebugsettingBuilder() {
  Debugsetting()
}

@ComponentV2
struct Debugsetting {
  @Local globalErrorShowTypeIndex: number = 0
  @Local globalErrorShowTypeValue: string = 'Toast'
  @Local saveErrorLog: boolean = false
  @Local deleteErrorLogBeforeUpdateTimeWhenAppLaunch: boolean = false
  @Local autoUploadErrorLog: boolean = false
  @Local showMemoryLevelChange: boolean = false
  @Local showNetAvailableStatusChange: boolean = false
  @Local showNetBlockStatusChange: boolean = false
  @Local showNetLost: boolean = false
  @Local showNetCapabilitiesChange: boolean = false
  @Local showNetQosChange: boolean = false
  @Local showNetSceneChange: boolean = false
  @Local autoReportHighLatency: boolean = false
  @Local highLatencyThreshold: string = '200'
  @Local closeRemoteValidationWhenLinkWebdav: boolean = false
  @Local optimizeParserBudget: boolean = true
  @Local destroyModeIndex: webview.WebDestroyMode = webview.WebDestroyMode.NORMAL_MODE
  @Local destroyModeValue: string = '普通'
  @Local allService: boolean = false
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()
  processCache = false

  getSetting() {
    const globalErrorShowType = getFlushPreference(this.context, 'debugSetting', 'globalErrorShowType', 0)
    this.globalErrorShowTypeIndex = globalErrorShowType as number
    if (globalErrorShowType === 0) {
      this.globalErrorShowTypeValue = 'Toast'
    }
    if (globalErrorShowType === 1) {
      this.globalErrorShowTypeValue = 'Dialog'
    }
    this.saveErrorLog = getFlushPreference(this.context, 'debugSetting', 'saveErrorLog', true) as boolean
    this.deleteErrorLogBeforeUpdateTimeWhenAppLaunch =
      getFlushPreference(this.context, 'debugSetting', 'deleteErrorLogBeforeUpdateTimeWhenAppLaunch', true) as boolean
    this.autoUploadErrorLog = getFlushPreference(this.context, 'debugSetting', 'autoUploadErrorLog', true) as boolean
    this.showMemoryLevelChange =
      getFlushPreference(this.context, 'debugSetting', 'showMemoryLevelChange', false) as boolean
    this.processCache = getFlushPreference(this.context, 'debugSetting', 'processCache', true) as boolean
    this.autoReportHighLatency =
      getFlushPreference(this.context, 'debugSetting', 'autoReportHighLatency', true) as boolean
    this.showNetAvailableStatusChange =
      getFlushPreference(this.context, 'debugSetting', 'showNetAvailableStatusChange', false) as boolean
    this.showNetBlockStatusChange =
      getFlushPreference(this.context, 'debugSetting', 'showNetBlockStatusChange', false) as boolean
    this.showNetLost = getFlushPreference(this.context, 'debugSetting', 'showNetLost', false) as boolean
    this.showNetCapabilitiesChange =
      getFlushPreference(this.context, 'debugSetting', 'showNetCapabilitiesChange', false) as boolean
    this.showNetQosChange = getFlushPreference(this.context, 'debugSetting', 'showNetQosChange', false) as boolean
    this.showNetSceneChange = getFlushPreference(this.context, 'debugSetting', 'showNetSceneChange', false) as boolean
    this.highLatencyThreshold = String(getFlushPreference(this.context, 'debugSetting', 'highLatencyThreshold', 200))
    const destroyMode =
      getFlushPreference(this.context, 'debugSetting', 'destroyMode', webview.WebDestroyMode.NORMAL_MODE)
    this.destroyModeIndex = destroyMode as webview.WebDestroyMode
    if (destroyMode === 0) {
      this.destroyModeValue = '普通'
    }
    if (destroyMode === 1) {
      this.destroyModeValue = '快速'
    }
    this.optimizeParserBudget =
      getFlushPreference(this.context, 'debugSetting', 'optimizeParserBudget', true) as boolean
    const closeRemoteValidationWhenLinkWebdav =
      getFlushPreference(this.context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav', 'system')
    if (closeRemoteValidationWhenLinkWebdav === 'system') {
      this.closeRemoteValidationWhenLinkWebdav = false
    }
    if (closeRemoteValidationWhenLinkWebdav === 'skip') {
      this.closeRemoteValidationWhenLinkWebdav = true
    }
    const allService = getFlushPreference(this.context, 'commonSetting', 'allService', true)
    this.allService = allService as boolean
    if (!allService) {
      this.autoUploadErrorLog = false
    }
  }

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Text('基础')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('故障展示方式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: 'Toast' },
                  { value: 'Dialog' }
                ])
                  .selected(this.globalErrorShowTypeIndex!!)
                  .value(this.globalErrorShowTypeValue!!)
                  .onSelect((index) => {
                    setFlushPreference(this.context, 'debugSetting', 'globalErrorShowType', index)
                  })
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
                Text('保存故障日志')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.saveErrorLog!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'saveErrorLog', isOn)
                  })
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
                Text('应用启动时清理历史版本故障日志')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.deleteErrorLogBeforeUpdateTimeWhenAppLaunch!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'deleteErrorLogBeforeUpdateTimeWhenAppLaunch',
                      isOn)
                  })
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
                Text('自动上传故障日志')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.autoUploadErrorLog!!
                })
                  .enabled(this.allService)
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'autoUploadErrorLog', isOn)
                  })
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
                Text('自动上传故障日志类型')
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
                  .backgroundColor(this.hoverId === 0 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 0
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Autouploaderrorlogtype'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('故障日志')
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
                  .backgroundColor(this.hoverId === 1 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 1
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Errorlog'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('内存占用级别变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showMemoryLevelChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showMemoryLevelChange', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')

              if (deviceInfo.deviceType !== 'tablet') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('进程缓存后快速启动')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.processCache!!
                  })
                    .onChange(async (isOn) => {
                      setFlushPreference(this.context, 'debugSetting', 'processCache', isOn)
                      const promptAction = this.UIContext.getPromptAction()
                      const data = await promptAction.showDialog({
                        title: '提示',
                        message: '设置成功，需重启应用生效，是否重启？',
                        buttons: [
                          {
                            text: '取消',
                            color: $r('sys.color.font_primary')
                          },
                          {
                            text: '重启',
                            color: $r('sys.color.font_emphasize')
                          }
                        ]
                      })
                      if (data.index === 1) {
                        const applicationContext = this.context.getApplicationContext()
                        applicationContext.restartApp({
                          bundleName: 'com.zhuzx.webdavhelper',
                          abilityName: 'EntryAbility'
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)
                .width('100%')
              }
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Text('应用')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('沙箱文件管理器')
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
                  .backgroundColor(this.hoverId === 2 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 2
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Sandboxfilelist'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('清除全部数据并退出')
                  .fontColor($r('sys.color.warning'))
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
                  .backgroundColor(this.hoverId === 3 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 3
                }
              })
              .onClick(async () => {
                const promptAction = this.UIContext.getPromptAction()
                const data = await promptAction.showDialog({
                  title: '提示',
                  message: '此操作将清除应用全部数据，同时撤销应用向用户申请的权限。确定清除？',
                  buttons: [
                    {
                      text: '取消',
                      color: $r('sys.color.font_primary')
                    },
                    {
                      text: '清除',
                      color: $r('sys.color.warning')
                    }
                  ]
                })
                if (data.index === 1) {
                  const applicationContext = this.context.getApplicationContext()
                  await applicationContext.clearUpApplicationData()
                }
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('终止所有进程并退出')
                  .fontColor($r('sys.color.warning'))
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
                  .backgroundColor(this.hoverId === 4 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 4
                }
              })
              .onClick(async () => {
                const promptAction = this.UIContext.getPromptAction()
                const data = await promptAction.showActionMenu({
                  title: '是否清除页面堆栈？',
                  buttons: [
                    {
                      text: '是',
                      color: $r('sys.color.font_primary')
                    },
                    {
                      text: '否',
                      color: $r('sys.color.font_primary')
                    }
                  ]
                })
                if (data.index === 0) {
                  const applicationContext = this.context.getApplicationContext()
                  await applicationContext.killAllProcesses(true)
                }
                if (data.index === 1) {
                  const applicationContext = this.context.getApplicationContext()
                  await applicationContext.killAllProcesses(false)
                }
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('应用恢复')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('重启当前进程')
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
                  .backgroundColor(this.hoverId === 5 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 5
                }
              })
              .onClick(() => {
                appRecovery.restartApp()
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('保存当前状态')
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
                  .backgroundColor(this.hoverId === 6 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 6
                }
              })
              .onClick(async () => {
                const res = appRecovery.saveAppState()
                if (res) {
                  await promptAction.openToast({
                    message: '保存成功'
                  })
                }
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('设置')
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
                  .backgroundColor(this.hoverId === 7 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 7
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Recoverysetting'
                })
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('网络')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('可用状态变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetAvailableStatusChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetAvailableStatusChange', isOn)
                  })
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
                Text('阻塞状态变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetBlockStatusChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetBlockStatusChange', isOn)
                  })
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
                Text('丢失时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetLost!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetLost', isOn)
                  })
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
                Text('能力变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetCapabilitiesChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetCapabilitiesChange', isOn)
                  })
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
                Text('质量变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetQosChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetQosChange', isOn)
                  })
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
                Text('场景变化时弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showNetSceneChange!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'showNetSceneChange', isOn)
                  })
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
                Text('高时延时自动反馈传输体验')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.autoReportHighLatency!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'autoReportHighLatency', isOn)
                  })
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
                Text('时延达到')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                TextInput({
                  text: this.highLatencyThreshold!!
                })
                  .enableAutoSpacing(true)
                  .maxLength(4)
                  .type(InputType.Number)
                  .width('35%')
                  .onSubmit(async (enterKey, event) => {
                    setFlushPreference(this.context, 'debugSetting', 'highLatencyThreshold', Number(event.text))
                    await promptAction.openToast({
                      message: '设置成功'
                    })
                  })
                Text('ms时判定为高时延')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    left: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
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
                Text('反馈传输体验')
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
                  .backgroundColor(this.hoverId === 8 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 8
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'ReportQoe'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('测试')
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
                  .backgroundColor(this.hoverId === 9 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 9
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Networktest'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('自定义DNS服务器')
                  .enableAutoSpacing(true)
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
                  .backgroundColor(this.hoverId === 10 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 10
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Dnsserver'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('连接WebDAV时跳过SSL验证')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.closeRemoteValidationWhenLinkWebdav!!
                })
                  .onChange((isOn) => {
                    if (!isOn) {
                      setFlushPreference(this.context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav', 'system')
                    }
                    if (isOn) {
                      setFlushPreference(this.context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav', 'skip')
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('Webview')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('分段解析HTML优化')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.optimizeParserBudget!!
                })
                  .onChange((isOn) => {
                    setFlushPreference(this.context, 'debugSetting', 'optimizeParserBudget', isOn)
                  })
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
                Text('销毁模式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '普通' },
                  { value: '快速' }
                ])
                  .selected(this.destroyModeIndex!!)
                  .value(this.destroyModeValue!!)
                  .onSelect((index) => {
                    setFlushPreference(this.context, 'debugSetting', 'destroyMode', index)
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Button('恢复默认设置')
            .align(Alignment.Center)
            .width('100%')
            .onClick(async () => {
              const promptAction = this.UIContext.getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '此操作将恢复全部调试设置为默认。确定恢复？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '恢复',
                    color: $r('sys.color.font_emphasize')
                  }
                ]
              })
              if (data.index === 1) {
                const debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
                  name: 'debugSetting',
                  storageType: preferences.StorageType.GSKV
                })
                debugSettingDataPreferences.clearSync()
                await promptAction.openToast({
                  message: '恢复成功'
                })
                this.getSetting()
              }
            })
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
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
          mainTitle: '调试设置'
        }
      },
      enableComponentSafeArea: true
    })
    .onReady((context) => {
      this.pageInfos = context.pathStack
      this.getSetting()
    })
  }
}