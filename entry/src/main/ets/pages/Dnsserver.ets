import { common } from '@kit.AbilityKit'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { deleteFlushPreferenceKey, getFlushPreference, setFlushPreference } from '../common/Preference'

@Builder
export function DnsserverBuilder() {
  Dnsserver()
}

@ComponentV2
struct Dnsserver {
  @Local ip: string = ''
  @Local port: string = '53'
  @Local focus: boolean = false
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Row() {
              Text('IP地址')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              TextInput({
                placeholder: '请输入IP地址',
                text: this.ip!!
              })
                .defaultFocus(this.focus)
                .enableAutoSpacing(true)
                .layoutWeight(1)
                .maxLength(39)
            }

            Row() {
              Text('端口')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              TextInput({
                placeholder: '请输入端口',
                text: this.port!!
              })
                .type(InputType.Number)
                .layoutWeight(1)
                .maxLength(5)
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })

            Button('保存')
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                if (!this.ip) {
                  deleteFlushPreferenceKey(this.context, 'debugSetting', 'dnsserverip')
                  deleteFlushPreferenceKey(this.context, 'debugSetting', 'dnsserverport')
                }
                if (this.ip) {
                  if (!this.port) {
                    await promptAction.openToast({
                      message: '请输入端口'
                    })
                    return
                  }
                  const port = Number(this.port)
                  if (!Number.isInteger(port) || port <= 0 || port > 65535) {
                    await promptAction.openToast({
                      message: '请输入有效的端口'
                    })
                    return
                  }
                  setFlushPreference(this.context, 'debugSetting', 'dnsserverip', this.ip)
                  setFlushPreference(this.context, 'debugSetting', 'dnsserverport', port)
                }
                await promptAction.openToast({
                  message: '保存成功'
                })
                this.pageInfos.pop()
              })
          }
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
              backgroundColor: $r('sys.color.comp_background_color_floating_smooth'),
              iconColor: $r('sys.color.icon_primary')
            }
          }
        },
        scrollEffectStyle: {
          contentStyle: {
            backIconStyle: {
              backgroundColor: $r('sys.color.comp_background_color_floating_smooth'),
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
          mainTitle: '自定义 DNS 服务器'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady((context) => {
      this.pageInfos = context.pathStack
      this.ip = getFlushPreference(this.context, 'debugSetting', 'dnsserverip', '') as string
      if (this.ip === '') {
        this.focus = true
      }
      this.port = String(getFlushPreference(this.context, 'debugSetting', 'dnsserverport', 53))
    })
  }
}