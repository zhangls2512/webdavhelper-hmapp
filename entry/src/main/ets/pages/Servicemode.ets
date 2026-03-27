import { common } from '@kit.AbilityKit'
import { privacyManager } from '@kit.AppGalleryKit'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { getFlushPreference, setFlushPreference } from '../common/Preference'

@Builder
export function ServicemodeBuilder() {
  Servicemode()
}

@ComponentV2
struct Servicemode {
  @Local allService: boolean = false
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
            Column() {
              Row() {
                Text('全量模式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.allService!!
                })
                  .enabled(!this.allService)
                  .onChange((isOn) => {
                    this.allService = isOn
                    setFlushPreference(this.context, 'commonSetting', 'allService', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Text() {
              Span('全量模式下，本应用需要连接本应用开发者服务器，除可使用检查本应用更新等无需连接本应用开发者服务器的功能外，还可使用自动上传故障日志等需要连接本应用开发者服务器的功能。我们仅在您使用具体业务功能时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
                .fontColor($r('sys.color.font_secondary'))
              Span('关于WebDAV助手与隐私的声明')
                .fontColor($r('sys.color.font_emphasize'))
                .fontWeight(FontWeight.Medium)
                .onClick(async () => {
                  try {
                    const appPrivacyLink = privacyManager.getAppPrivacyMgmtInfo().privacyInfo
                      .find(item => item.type === privacyManager.AppPrivacyLinkType.PRIVACY_STATEMENT_LINK)
                    this.pageInfos.pushPath({
                      name: 'Webview',
                      param: appPrivacyLink?.url
                    })
                  } catch (err) {
                    await promptAction.openToast({
                      message: '发生错误，错误码：' + err.code + '，错误信息：' + err.message
                    })
                  }
                })
              Span('。开启开关，即表示您知悉并同意我们向您提供本应用服务。')
                .fontColor($r('sys.color.font_secondary'))
            }
            .enableAutoSpacing(true)
            .fontSize($r('sys.float.ohos_id_text_size_body3'))
            .margin({
              top: 6,
              left: 12,
              right: 12
            })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('基本模式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: !this.allService
                })
                  .enabled(this.allService)
                  .onChange((isOn) => {
                    this.allService = !isOn
                    setFlushPreference(this.context, 'commonSetting', 'allService', !isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Text('基本模式下，本应用无需连接本应用开发者服务器，可使用检查本应用更新等无需连接本应用开发者服务器的功能。此模式下无法使用自动上传故障日志等需要连接本应用开发者服务器的功能。')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
              .margin({
                top: 6,
                left: 12,
                right: 12
              })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
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
          mainTitle: '应用服务模式'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady((context) => {
      this.pageInfos = context.pathStack
      this.allService = getFlushPreference(this.context, 'commonSetting', 'allService', true) as boolean
    })
    .onDisAppear(() => {
      this.context.eventHub.emit('refreshSetting')
    })
  }
}