import { common } from '@kit.AbilityKit'
import { LengthMetrics } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { deleteFlushPreferenceKey, getFlushPreferences, KvItem, PreferenceItem } from '../common/Preference'

@Builder
export function ClearpreferencekeyBuilder() {
  Clearpreferencekey()
}

@ComponentV2
struct Clearpreferencekey {
  @Local preferenceArray: PreferenceItem[] = []
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  async get() {
    this.preferenceArray = await getFlushPreferences(this.context)
  }

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ForEach(this.preferenceArray, (item: PreferenceItem, index) => {
          ListItem() {
            Text(item.name)
              .fontWeight(FontWeight.Medium)
          }
          .margin({
            bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
            top: index === 0 ? $r('sys.float.ohos_id_elements_margin_vertical_m') :
              $r('sys.float.ohos_id_elements_margin_vertical_l')
          })

          ForEach(item.kvs, (keyItem: KvItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(keyItem.key)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Image($r('app.media.delete'))
                    .height(24)
                    .onClick(async () => {
                      deleteFlushPreferenceKey(this.context, item.name, keyItem.key)
                      await this.get()
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              .padding($r('sys.float.ohos_id_corner_radius_mark'))
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          })
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
          mainTitle: '高级清理设置数据'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      await this.get()
    })
  }
}