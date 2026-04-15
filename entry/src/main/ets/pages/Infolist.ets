import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { pushService } from '@kit.PushKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

@Builder
export function InfolistBuilder() {
  Infolist()
}

@ComponentV2
struct Infolist {
  @Local hoverId: number = -1
  pageInfos = new NavPathStack()

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Text('朱子轩 (以下简称我) 会严格遵从国家的法规要求，将合法合规融入产品设计和业务流程中，并采用业界先进的安全技术保证数据安全。\n在新的服务需求及业务功能变更时，我可能会调整我收集信息的范围，并及时在本说明中向您说明情况。')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
        }
        .margin({
          left: 12,
          right: 12,
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Text('PushToken')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Column() {
                Text('使用场景')
                  .fontWeight(FontWeight.Medium)
                Text('服务器推送通知时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('使用目的')
                  .fontWeight(FontWeight.Medium)
                Text('让服务器知晓推送通知到哪个设备')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('收集时机')
                  .fontWeight(FontWeight.Medium)
                Text('开启通知位时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('删除时机')
                  .fontWeight(FontWeight.Medium)
                Text('关闭全部通知位')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('信息内容')
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
              .onHover((isHover) => {
                if (!isHover) {
                  this.hoverId = -1
                }
                if (isHover) {
                  this.hoverId = 0
                }
              })
              .onClick(async () => {
                try {
                  const pushToken = await pushService.getToken()
                  const promptAction = this.getUIContext().getPromptAction()
                  await promptAction.showDialog({
                    title: 'PushToken',
                    message: pushToken,
                    buttons: [
                      {
                        text: '确定',
                        color: $r('sys.color.font_emphasize')
                      }
                    ]
                  })
                } catch (err) {
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code
                  })
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
            Text('故障日志')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Column() {
                Text('使用场景')
                  .fontWeight(FontWeight.Medium)
                Text('开发者分析故障时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('使用目的')
                  .fontWeight(FontWeight.Medium)
                Text('让开发者知晓故障，以便尽快修复，保障应用稳定运行')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('收集时机')
                  .fontWeight(FontWeight.Medium)
                Text('发生故障时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('删除时机')
                  .fontWeight(FontWeight.Medium)
                Text('对应故障处理完成后、联系客服申请')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Column() {
                  Text('信息内容')
                    .fontWeight(FontWeight.Medium)
                  Text('应用名称、应用版本号、故障日志、联系方式')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
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
            Text('意见反馈')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Column() {
                Text('使用场景')
                  .fontWeight(FontWeight.Medium)
                Text('开发者处理意见反馈时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('使用目的')
                  .fontWeight(FontWeight.Medium)
                Text('让开发者知晓意见反馈，以处理')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('收集时机')
                  .fontWeight(FontWeight.Medium)
                Text('提交意见反馈时')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('删除时机')
                  .fontWeight(FontWeight.Medium)
                Text('意见反馈处理完成后、联系客服申请')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Column() {
                Text('信息内容')
                  .fontWeight(FontWeight.Medium)
                Text('应用名称 (WebDAV助手)、内容、联系方式 (可选)')
                  .enableAutoSpacing(true)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical')
                  })
              }
              .alignItems(HorizontalAlign.Start)
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
          mainTitle: '已收集个人信息清单'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady((context) => {
      this.pageInfos = context.pathStack
    })
  }
}