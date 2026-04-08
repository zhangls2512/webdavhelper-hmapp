import { common } from '@kit.AbilityKit'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { notificationManager } from '@kit.NotificationKit'
import { pushService } from '@kit.PushKit'
import { developerRequest } from '../common/Request'

interface NoticeItem {
  _id: string,
  name: string,
  desc: string,
  status: boolean
}

@ComponentV2
export default struct Notice {
  @Local noticeArray: NoticeItem[] = []
  @Local pushToken: string = ''
  @Local loading: boolean = false
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    List() {
      ListItem() {
        Column() {
          Column() {
            Row() {
              Text('允许接收')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Toggle({
                type: ToggleType.Switch,
                isOn: notificationManager.isNotificationEnabledSync()
              })
                .enabled(false)
            }
            .borderRadius(12)
            .padding(12)
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))

          Text() {
            Span('请前往')
              .fontColor($r('sys.color.font_secondary'))
            Span('系统设置')
              .fontColor($r('sys.color.font_emphasize'))
              .fontWeight(FontWeight.Medium)
              .onClick(async () => {
                await notificationManager.openNotificationSettings(this.context)
              })
            Span('管理此开关。')
              .fontColor($r('sys.color.font_secondary'))
          }
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

      if (this.loading) {
        ListItem() {
          LoadingProgress()
            .height(20)
            .width(20)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
      }
      if (!this.loading && this.noticeArray.length > 0) {
        ListItem() {
          Column() {
            Text('通知位')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              ForEach(this.noticeArray, (item: NoticeItem, index) => {
                if (index !== 0) {
                  Divider()
                    .padding({
                      left: 12,
                      right: 12
                    })
                }
                Row() {
                  Column() {
                    Text(item.name)
                      .fontWeight(FontWeight.Medium)
                    Text(item.desc)
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

                  Toggle({
                    type: ToggleType.Switch,
                    isOn: item.status
                  })
                    .onChange(async () => {
                      const dialogControllerProgress = new CustomDialogController({
                        builder: LoadingDialog({
                          content: '请求中...'
                        })
                      })
                      dialogControllerProgress.open()
                      const res = await developerRequest(this.context, '/product/updatePushStatus', {
                        id: item._id,
                        pushToken: this.pushToken
                      })
                      dialogControllerProgress.close()
                      if (res !== 'fail') {
                        await promptAction.openToast({
                          message: '设置成功'
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)
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
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
    .onAppear(async () => {
      try {
        this.pushToken = await pushService.getToken()
      } catch (err) {
        await promptAction.openToast({
          message: '发生错误，错误码：' + err.code
        })
      }
      this.loading = true
      const res = await developerRequest(this.context, '/product/getPushList', {
        product: 'webdavhelper',
        pushToken: this.pushToken
      })
      this.loading = false
      if (res !== 'fail') {
        this.noticeArray = JSON.parse(res).data
      }
    })
  }
}