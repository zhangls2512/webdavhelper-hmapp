import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

interface Item {
  title: string,
  pubDate: string,
  link: string
}

@Builder
export function LetsencryptrssBuilder() {
  Letsencryptrss()
}

@ComponentV2
struct Letsencryptrss {
  @Local itemArray: Item[] = []
  @Local hoverId: number = -1
  pageInfos = new NavPathStack()

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ForEach(this.itemArray, (item: Item, index) => {
          ListItem() {
            Column() {
              Row() {
                Text('标题')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(item.title)
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
                Text('发布日期')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(item.pubDate)
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
                Text('查看')
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
                  .backgroundColor(this.hoverId === index ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = index
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Webview',
                  param: item.link
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
          mainTitle: "Let's Encrypt RSS"
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady(async (context) => {
      this.pageInfos = context.pathStack
      const dialogControllerProgress = new CustomDialogController({
        builder: LoadingDialog({
          content: '请求中...'
        })
      })
      dialogControllerProgress.open()
      const session = rcp.createSession({
        requestConfiguration: {
          security: {
            tlsRange: {
              min: 'TlsV1.2'
            }
          }
        }
      })
      try {
        const response = await session.get('https://letsencrypt.org/feed.xml')
        session.close()
        dialogControllerProgress.close()
        if (response.statusCode >= 200 && response.statusCode < 300) {
          let rss = String(response)
          while (rss.includes('<item>')) {
            const item = rss.substring(rss.indexOf('<item>') + 6, rss.indexOf('</item>'))
            const date = new Date(item.substring(item.indexOf('<pubDate>') + 9, item.indexOf('</pubDate>')))
            this.itemArray.push({
              title: item.substring(item.indexOf('<title>') + 7, item.indexOf('</title>')),
              link: item.substring(item.indexOf('<link>') + 6, item.indexOf('</link>')),
              pubDate: date.getFullYear() + '-' + String((date.getMonth() + 1)).padStart(2, '0') + '-' +
                String((date.getDate())).padStart(2, '0')
            })
            rss = rss.substring(rss.indexOf('</item>') + 7)
          }
        } else {
          await promptAction.openToast({
            message: 'HTTP 请求失败，状态码：' + response.statusCode
          })
        }
      } catch (err) {
        session.close()
        dialogControllerProgress.close()
        await promptAction.openToast({
          message: '发生错误，错误码：' + err.code
        })
      }
    })
  }
}