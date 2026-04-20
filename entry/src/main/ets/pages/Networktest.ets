import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

interface Response {
  errCode: number,
  errMsg: string,
  requestIp: string,
  timeStamp: number
}

@Builder
export function NetworktestBuilder() {
  Networktest()
}

@ComponentV2
struct Networktest {
  @Local errCode: number = -1
  @Local errMsg: string = ''
  @Local requestIp: string = ''
  @Local timeStamp: number = -1
  @Local httpVersion: string = ''
  @Local totalTimeMs: number = -1
  context = this.getUIContext().getHostContext()

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Button('测试')
              .width('100%')
              .onClick(async () => {
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
                  const startTime = Date.now()
                  const response = await session.get('https://api.zhangls2512.cn/test')
                  session.close()
                  dialogControllerProgress.close()
                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    const res = response.toJSON() as Response
                    this.errCode = res.errCode
                    this.errMsg = res.errMsg
                    this.requestIp = res.requestIp
                    this.timeStamp = res.timeStamp
                    this.httpVersion = String(response.httpVersion)
                    this.totalTimeMs = Date.now() - startTime
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
            Column() {
              Row() {
                Text('请求地址')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text('https://api.zhangls2512.cn/test')
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
                Text('错误码')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(String(this.errCode))
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
                Text('错误信息')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(this.errMsg)
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
                Text('请求IP')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(this.requestIp)
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
                Text('请求时间戳')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(String(this.timeStamp))
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
                Text('HTTP版本')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(this.httpVersion)
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
                Text('请求总耗时')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(String(this.totalTimeMs) + ' ms')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
              }
              .borderRadius(12)
              .padding(12)
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
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
          mainTitle: '网络测试'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
  }
}