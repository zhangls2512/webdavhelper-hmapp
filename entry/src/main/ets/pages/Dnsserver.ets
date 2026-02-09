import { preferences } from '@kit.ArkData'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { HdsNavDestination } from '@kit.UIDesignKit'

@Builder
export function DnsserverBuilder() {
  Dnsserver()
}

@ComponentV2
struct Dnsserver {
  @Local ip: string = ''
  @Local port: string = '53'
  @Local focus: boolean = false
  context = this.getUIContext().getHostContext()
  pageInfos = new NavPathStack()
  debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'debugSetting'
  })

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Row() {
              Text('IP地址')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              TextInput({
                placeholder: '请输入IP地址',
                text: this.ip!!
              })
                .defaultFocus(this.focus)
                .enableAutoSpacing(true)
                .layoutWeight(1)
                .maxLength(39)
            }

            Row() {
              Text('端口')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              TextInput({
                placeholder: '请输入端口',
                text: this.port!!
              })
                .type(InputType.Number)
                .layoutWeight(1)
                .maxLength(5)
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })

            Button('保存')
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                if (!this.ip) {
                  this.debugSettingDataPreferences.deleteSync('dnsserverip')
                  this.debugSettingDataPreferences.deleteSync('dnsserverport')
                }
                if (this.ip) {
                  if (!this.port) {
                    await promptAction.openToast({
                      message: '请输入端口'
                    })
                    return
                  }
                  const port = Number(this.port)
                  if (!Number.isInteger(port) || port <= 0 || port > 65535) {
                    await promptAction.openToast({
                      message: '请输入有效的端口'
                    })
                    return
                  }
                  this.debugSettingDataPreferences.putSync('dnsserverip', this.ip)
                  this.debugSettingDataPreferences.putSync('dnsserverport', port)
                }
                this.debugSettingDataPreferences.flushSync()
                await promptAction.openToast({
                  message: '保存成功'
                })
                this.pageInfos.pop()
              })
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
          mainTitle: '自定义 DNS 服务器'
        }
      },
      enableComponentSafeArea: true
    })
    .onReady((context) => {
      this.pageInfos = context.pathStack
      this.ip = this.debugSettingDataPreferences.getSync('dnsserverip', '') as string
      if (this.ip === '') {
        this.focus = true
      }
      this.port = String(this.debugSettingDataPreferences.getSync('dnsserverport', 53))
    })
  }
}