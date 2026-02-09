import { common } from '@kit.AbilityKit'
import { LengthMetrics } from '@kit.ArkUI'
import { HdsNavDestination } from '@kit.UIDesignKit'
import openLink from '../common/Openlink'

interface Item {
  property: string,
  value: string
}

@Builder
export function LicenseBuilder() {
  License()
}

@ComponentV2
struct License {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  gabaInfoArray: Item[] = [
    { property: '名称', value: 'WebDAV助手' },
    { property: '主体类型', value: '个人' },
    { property: '开办者名称', value: '张轩铭' },
    { property: '注册地公安机关', value: '萨尔图区网安大队' },
    { property: '注册时间', value: '2026-02-13' }
  ]

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Text() {
            Span('ICP备案：')
            Span('黑ICP备2024023054号-11A')
              .fontColor($r('sys.color.font_emphasize'))
              .onClick(async () => {
                await openLink(this.context, 'https://beian.miit.gov.cn/#/Integrated/recordQuery')
              })
          }
          .enableAutoSpacing(true)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Text('公安备案')
              .fontColor($r('sys.color.font_emphasize'))
              .fontWeight(FontWeight.Bold)
              .onClick(async () => {
                await openLink(this.context, 'https://beian.mps.gov.cn/#/query/appSearch')
              })
            Flex({
              alignItems: ItemAlign.Stretch,
              wrap: FlexWrap.Wrap
            }) {
              ForEach(this.gabaInfoArray, (item: Item) => {
                Column() {
                  Text(item.property)
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Center)
                }
                .border({
                  color: $r('sys.color.font_primary'),
                  width: {
                    right: 1,
                    top: 1
                  }
                })
                .justifyContent(FlexAlign.Center)
                .padding($r('sys.float.ohos_id_elements_margin_vertical_m'))
                .width('50%')

                Column() {
                  Text(item.value)
                    .enableAutoSpacing(true)
                    .textAlign(TextAlign.Center)
                }
                .border({
                  color: $r('sys.color.font_primary'),
                  width: {
                    top: 1
                  }
                })
                .justifyContent(FlexAlign.Center)
                .padding($r('sys.float.ohos_id_elements_margin_vertical_m'))
                .width('50%')
              })
            }
            .border({
              color: $r('sys.color.font_primary'),
              width: {
                bottom: 1,
                left: 1,
                right: 1
              }
            })
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          }
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
      content: {
        title: {
          mainTitle: '资质证照'
        }
      },
      enableComponentSafeArea: true
    })
  }
}