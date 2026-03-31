import { common } from '@kit.AbilityKit'
import { LengthMetrics, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { BestAddressItem } from '../common/Account'
import { read } from '../common/File'

@Builder
export function BestaddressBuilder() {
  Bestaddress()
}

@ComponentV2
struct Bestaddress {
  @Local selectedIndex: number = 0
  @Local content: string = ''
  @Local array: BestAddressItem[] = []
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          TabSegmentButtonV2({
            items: new SegmentButtonV2Items([
              { text: '原始' },
              { text: '解析' }
            ]),
            selectedIndex: this.selectedIndex!!
          })
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          List() {
            if (!this.content) {
              ListItem() {
                Text('无数据')
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
            }
            if (this.selectedIndex === 0) {
              ListItem() {
                Text(this.content)
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
            }
            if (this.selectedIndex === 1) {
              ForEach(this.array, (bestAddressItem: BestAddressItem) => {
                ListItem() {
                  Column() {
                    Text('最佳：' + bestAddressItem.best)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        bottom: 6,
                        left: 12,
                        right: 12
                      })
                    Column() {
                      ForEach(bestAddressItem.list, (addressItem: string, addressIndex) => {
                        if (addressIndex !== 0) {
                          Divider()
                            .padding({
                              left: 12,
                              right: 12
                            })
                        }
                        Row() {
                          Text(addressItem)
                            .fontWeight(FontWeight.Medium)
                            .layoutWeight(1)
                            .margin({
                              right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                            })
                        }
                        .borderRadius(12)
                        .padding(12)
                        .width('100%')
                      })
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
              })
            }
            ListItem()
              .margin({
                bottom: 28
              })
          }
          .layoutWeight(1)
        }
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
          mainTitle: '最佳地址'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      const filePath = this.context.cacheDir + '/bestaddress.txt'
      if (fileIo.accessSync(filePath)) {
        this.content = await read(filePath, true)
        this.array = JSON.parse(this.content)
      }
    })
  }
}