import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { HdsNavDestination } from '@kit.UIDesignKit'
import { getDnsServer } from '../common/Dnsserver'

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
        ListItem() {
          Column() {
            Button('测试')
              .width('100%')
              .onClick(async () => {
                const dialogControllerProgress = new CustomDialogController({
                  builder: LoadingDialog({
                    content: '测试中...'
                  })
                })
                dialogControllerProgress.open()
                const session = rcp.createSession({
                  requestConfiguration: {
                    dns: {
                      dnsRules: getDnsServer(this.context)
                    },
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
                  if (response.statusCode === 200) {
                    let body = ''
                    if (response.toString()) {
                      body = response.toString() as string
                    }
                    const res = JSON.parse(body) as Response
                    this.errCode = res.errCode
                    this.errMsg = res.errMsg
                    this.requestIp = res.requestIp
                    this.timeStamp = res.timeStamp
                    this.httpVersion = String(response.httpVersion)
                    this.totalTimeMs = Date.now() - startTime
                    await promptAction.openToast({
                      message: '测试完成'
                    })
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
              .width('100%')

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
              .width('100%')

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
              .width('100%')

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
              .width('100%')

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
              .width('100%')

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
              .width('100%')

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
              .width('100%')
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
          mainTitle: '网络测试'
        }
      },
      enableComponentSafeArea: true
    })
  }
}