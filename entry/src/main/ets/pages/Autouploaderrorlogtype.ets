import { common } from '@kit.AbilityKit'
import { LengthMetrics } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { getFlushPreference, setFlushPreference } from '../common/Preference'

export interface Type {
  name: string,
  value: string
}

@Builder
export function AutouploaderrorlogtypeBuilder() {
  Autouploaderrorlogtype()
}

@ComponentV2
struct Autouploaderrorlogtype {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  autoUploadErrorLogType: string[] = []
  typeArray: Type[] = [
    {
      name: 'js运行异常',
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
      name: 'ArkWeb抛滑丢帧',
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
      name: 'CPU高负载',
      value: 'CPU_USAGE_HIGH'
    },
    {
      name: '24小时功耗器件分解统计',
      value: 'BATTERY_USAGE'
    },
    {
      name: '音频卡顿',
      value: 'AUDIO_JANK_FRAME'
    }
  ]

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            ForEach(this.typeArray, (item: Type, index) => {
              if (index !== 0) {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
              }
              Row() {
                Text(item.name)
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.autoUploadErrorLogType.includes(item.value)
                })
                  .onChange(isOn => {
                    if (!isOn) {
                      this.autoUploadErrorLogType = this.autoUploadErrorLogType.filter(inItem => inItem !== item.value)
                    }
                    if (isOn) {
                      this.autoUploadErrorLogType = Array.from(new Set([...this.autoUploadErrorLogType, item.value]))
                    }
                    setFlushPreference(this.context, 'debugSetting', 'autoUploadErrorLogType',
                      this.autoUploadErrorLogType)
                  })
              }
              .borderRadius(12)
              .padding(12)
            })
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem()
          .margin({
            bottom: 28
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
          mainTitle: '自动上传故障日志类型'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(() => {
      this.autoUploadErrorLogType =
        getFlushPreference(this.context, 'debugSetting', 'autoUploadErrorLogType',
          ['JS_ERROR', 'APP_CRASH']) as string[]
    })
  }
}