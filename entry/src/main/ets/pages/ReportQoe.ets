import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { netQuality } from '@kit.NetworkBoostKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

@Builder
export function ReportQoeBuilder() {
  ReportQoe()
}

@ComponentV2
struct ReportQoe {
  pageInfos = new NavPathStack()
  serviceType: netQuality.ServiceType = 'default'
  qoeType: netQuality.QoeType = 'good'

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
                Text('业务类型')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Column() {
                  Select([
                    { value: '默认' },
                    { value: '后台' },
                    { value: '实时语音' },
                    { value: '实时视频' },
                    { value: '语音信令' },
                    { value: '实时游戏' },
                    { value: '普通游戏' },
                    { value: '短视频' },
                    { value: '长视频' },
                    { value: '直播主播' },
                    { value: '直播观看' },
                    { value: '下载' },
                    { value: '上传' },
                    { value: '浏览页面' },
                    { value: '交易支付、扫码' },
                    { value: '购物' },
                    { value: '探测' },
                    { value: '云业务、云游戏' },
                    { value: '语音会议' },
                    { value: '视频会议' },
                    { value: '音乐、音频' },
                    { value: '导航定位' },
                    { value: '秒杀' },
                    { value: '登录' }
                  ])
                    .selected(0)
                    .value('默认')
                    .onSelect((index) => {
                      if (index === 0) {
                        this.serviceType = 'default'
                      }
                      if (index === 1) {
                        this.serviceType = 'background'
                      }
                      if (index === 2) {
                        this.serviceType = 'realtimeVoice'
                      }
                      if (index === 3) {
                        this.serviceType = 'realtimeVideo'
                      }
                      if (index === 4) {
                        this.serviceType = 'default'
                      }
                      if (index === 5) {
                        this.serviceType = 'realtimeGame'
                      }
                      if (index === 6) {
                        this.serviceType = 'normalGame'
                      }
                      if (index === 7) {
                        this.serviceType = 'shortVideo'
                      }
                      if (index === 8) {
                        this.serviceType = 'longVideo'
                      }
                      if (index === 9) {
                        this.serviceType = 'livestreamingAnchor'
                      }
                      if (index === 10) {
                        this.serviceType = 'livestreamingWatcher'
                      }
                      if (index === 11) {
                        this.serviceType = 'download'
                      }
                      if (index === 12) {
                        this.serviceType = 'upload'
                      }
                      if (index === 13) {
                        this.serviceType = 'browser'
                      }
                      if (index === 14) {
                        this.serviceType = 'transaction'
                      }
                      if (index === 15) {
                        this.serviceType = 'shopping'
                      }
                      if (index === 16) {
                        this.serviceType = 'detection'
                      }
                      if (index === 17) {
                        this.serviceType = 'cloudService'
                      }
                      if (index === 18) {
                        this.serviceType = 'voiceConference'
                      }
                      if (index === 19) {
                        this.serviceType = 'videoConference'
                      }
                      if (index === 20) {
                        this.serviceType = 'audio'
                      }
                      if (index === 21) {
                        this.serviceType = 'navigation'
                      }
                      if (index === 22) {
                        this.serviceType = 'seckillService'
                      }
                      if (index === 23) {
                        this.serviceType = 'login'
                      }
                    })
                }
                .alignItems(HorizontalAlign.End)
                .layoutWeight(1)
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
                Text('体验类型')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '良好' },
                  { value: '未知原因' },
                  { value: '服务器异常' },
                  { value: '无数据' },
                  { value: '丢包' },
                  { value: '乱序' },
                  { value: '高抖动' },
                  { value: '高时延' }
                ])
                  .selected(0)
                  .value('良好')
                  .onSelect((index) => {
                    if (index === 0) {
                      this.qoeType = 'good'
                    }
                    if (index === 1) {
                      this.qoeType = 'unknown'
                    }
                    if (index === 2) {
                      this.qoeType = 'serverErr'
                    }
                    if (index === 3) {
                      this.qoeType = 'noData'
                    }
                    if (index === 4) {
                      this.qoeType = 'packetLost'
                    }
                    if (index === 5) {
                      this.qoeType = 'packetOutOfOrder'
                    }
                    if (index === 6) {
                      this.qoeType = 'highJitter'
                    }
                    if (index === 7) {
                      this.qoeType = 'highLatency'
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Button('反馈')
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                netQuality.reportQoe({
                  serviceType: this.serviceType,
                  qoeType: this.qoeType
                })
                await promptAction.openToast({
                  message: '反馈成功'
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
          mainTitle: '反馈网络传输体验'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady((context) => {
      this.pageInfos = context.pathStack
    })
  }
}