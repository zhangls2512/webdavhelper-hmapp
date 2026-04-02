import { common } from '@kit.AbilityKit'
import { url } from '@kit.ArkTS'
import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

interface Body {
  and?: RuleItem[],
  or?: RuleItem[]
}

interface Response {
  success: boolean,
  data: Data
}

interface Data {
  data: Item[],
  error: string
}

interface Item {
  name: string,
  developer_name: string,
  pkg_name: string
}

interface RuleItem {
  key: string,
  op: string,
  value: string
}

@Builder
export function HmappsearchBuilder() {
  Hmappsearch()
}

@ComponentV2
struct Hmappsearch {
  @Local itemArray: Item[] = []
  @Local page: number = 1
  @Local pageSize: number = 10
  @Local logic: string = 'and'
  @Local ruleArray: RuleItem[] = []
  @Local hoverId: number = -1
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text('页号')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Counter() {
                Text(String(this.page))
              }
              .enableDec(this.page > 1)
              .onInc(() => {
                this.page++
              })
              .onDec(() => {
                this.page--
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
              Text('每页个数')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Counter() {
                Text(String(this.pageSize))
              }
              .enableDec(this.pageSize > 1)
              .onInc(() => {
                this.pageSize++
              })
              .onDec(() => {
                this.pageSize--
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
              Text('匹配逻辑')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Select([
                { value: '与' },
                { value: '或' }
              ])
                .selected(0)
                .value('与')
                .onSelect((index) => {
                  if (index === 0) {
                    this.logic = 'and'
                  }
                  if (index === 1) {
                    this.logic = 'or'
                  }
                })
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
          .padding($r('sys.float.ohos_id_corner_radius_mark'))

          Button('搜索')
            .enabled(this.ruleArray.length > 0 ? true : false)
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .width('100%')
            .onClick(async () => {
              this.itemArray = []
              const body = {} as Body
              if (this.logic === 'and') {
                body.and = this.ruleArray
              }
              if (this.logic === 'or') {
                body.or = this.ruleArray
              }
              const dialogControllerProgress = new CustomDialogController({
                builder: LoadingDialog({
                  content: '请求中...'
                })
              })
              dialogControllerProgress.open()
              const session = rcp.createSession()
              try {
                const response = await session.post('http://shenjack.top:10003/api/v0/apps/query?' + new url.URLParams({
                  page: String(this.page),
                  page_size: String(this.pageSize),
                  sort: 'download_count',
                  desc: String(true)
                }).toString(), body)
                session.close()
                dialogControllerProgress.close()
                if (response.statusCode >= 200 && response.statusCode < 300) {
                  const res = JSON.parse(String(response)) as Response
                  if (!res.success) {
                    await promptAction.openToast({
                      message: '接口调用失败，原因：' + res.data.error
                    })
                    return
                  }
                  if (res.success) {
                    this.itemArray = res.data.data
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
          List() {
            if (this.itemArray.length === 0) {
              ListItem() {
                Text('无数据')
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
            }
            ForEach(this.itemArray, (item: Item, index) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('名称')
                      .enableAutoSpacing(true)
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Text(item.name)
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
                    Text('开发者')
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Text(item.developer_name)
                      .enableAutoSpacing(true)
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
                    Text('应用详情')
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
                  .width('100%')
                  .onHover((isHover) => {
                    if (!isHover) {
                      this.hoverId = -1
                    }
                    if (isHover) {
                      this.hoverId = index
                    }
                  })
                  .onClick(async () => {
                    await this.context.openLink('https://appgallery.huawei.com/app/detail?id=' + item.pkg_name)
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
          mainTitle: '鸿蒙应用搜索'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
  }
}