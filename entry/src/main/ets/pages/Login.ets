import { common } from '@kit.AbilityKit'
import { privacyManager } from '@kit.AppGalleryKit'
import { preferences } from '@kit.ArkData'
import { util } from '@kit.ArkTS'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { setAccount } from '../common/Account'
import { autoBackup } from '../common/Backup'
import { getDnsServer } from '../common/Dnsserver'
import openLink from '../common/Openlink'

@ComponentV2
export default struct Login {
  @Consumer() isShowLoginSheet: boolean = false
  @Local scheme: string = 'https'
  @Local host: string = ''
  @Local port: string = '443'
  @Local name: string = ''
  @Local password: string = ''
  @Local bz: string = ''
  @Local agree: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  build() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Text('协议')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Row() {
              Radio({
                value: 'http',
                group: 'scheme'
              })
                .checked(this.scheme === 'http' ? true : false)
                .onChange(async (isChecked) => {
                  if (isChecked) {
                    this.scheme = 'http'
                    if (!this.port || this.port === '443') {
                      this.port = '80'
                    }
                    const promptAction = this.UIContext.getPromptAction()
                    await promptAction.showDialog({
                      title: '提示',
                      message: '因账号、密码在网络传输过程中可被转换成明文，在公网环境下请务必使用 HTTPS 协议，防止账号、密码泄露',
                      buttons: [
                        {
                          text: '确定',
                          color: $r('sys.color.warning')
                        }
                      ]
                    })
                  }
                })
              Text('http')
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Radio({
                value: 'https',
                group: 'scheme'
              })
                .checked(this.scheme === 'https' ? true : false)
                .onChange((isChecked) => {
                  if (isChecked) {
                    this.scheme = 'https'
                    if (!this.port || this.port === '80') {
                      this.port = '443'
                    }
                  }
                })
              Text('https')
            }
            .layoutWeight(1)
          }

          Row() {
            Text('主机')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            TextInput({
              placeholder: '请输入主机',
              text: this.host!!
            })
              .enableAutoSpacing(true)
              .layoutWeight(1)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

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
              .enableAutoSpacing(true)
              .layoutWeight(1)
              .maxLength(5)
              .type(InputType.Number)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Row() {
            Text('账号')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            TextInput({
              placeholder: '请输入账号',
              text: this.name!!
            })
              .contentType(ContentType.USER_NAME)
              .enableAutoSpacing(true)
              .layoutWeight(1)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Row() {
            Text('密码')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            TextInput({
              placeholder: '请输入密码',
              text: this.password!!
            })
              .contentType(ContentType.PASSWORD)
              .enableAutoSpacing(true)
              .layoutWeight(1)
              .maxLength(30)
              .type(InputType.Password)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Row() {
            Text('备注')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            TextInput({
              placeholder: '请输入备注 (可选)',
              text: this.bz!!
            })
              .enableAutoSpacing(true)
              .layoutWeight(1)
              .maxLength(20)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Button('登录')
            .enabled(this.agree)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .width('100%')
            .onClick(async () => {
              if (!this.host) {
                await promptAction.openToast({
                  message: '请输入主机'
                })
                return
              }
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
              if (!this.name && this.password) {
                await promptAction.openToast({
                  message: '请输入账号'
                })
                return
              }
              if (this.name && !this.password) {
                await promptAction.openToast({
                  message: '请输入密码'
                })
                return
              }
              let path = ''
              let host = this.host
              let route = ''
              const index = this.host.indexOf('/')
              if (index !== -1) {
                host = this.host.substring(0, index)
                route = '/' + this.host.substring(index + 1)
              }
              path = this.scheme + '://' + host + ':' + this.port + route
              const debugSettingDataPreferences = preferences.getPreferencesSync(this.context, {
                name: 'debugSetting'
              })
              const session = rcp.createSession({
                requestConfiguration: {
                  dns: {
                    dnsRules: getDnsServer(this.context)
                  },
                  security: {
                    remoteValidation: debugSettingDataPreferences.getSync('closeRemoteValidationWhenLinkWebdav',
                      'system') as 'system' | 'skip',
                    tlsRange: {
                      min: 'TlsV1.2'
                    }
                  }
                },
                headers: {
                  Authorization: 'Basic ' +
                  new util.Base64Helper().encodeToStringSync(new util.TextEncoder().encodeInto(this.name + ':' +
                  this.password)),
                  Depth: '0'
                }
              })
              const dialogControllerProgress = new CustomDialogController({
                builder: LoadingDialog({
                  content: '请求中...'
                })
              })
              dialogControllerProgress.open()
              try {
                const response = await session.fetch(new rcp.Request(path + '/', 'PROPFIND'))
                session.close()
                dialogControllerProgress.close()
                if (response.statusCode >= 200 && response.statusCode < 300) {
                  await setAccount(this.context, {
                    path: path,
                    name: this.name,
                    password: this.password,
                    bz: this.bz,
                    isLogin: 'true'
                  })
                  await promptAction.openToast({
                    message: '登录成功'
                  })
                  this.context.eventHub.emit('refreshFilelist')
                  this.context.eventHub.emit('refreshMe')
                  this.isShowLoginSheet = false
                  await autoBackup(this.context)
                } else {
                  if (response.statusCode !== 401) {
                    await promptAction.openToast({
                      message: 'HTTP 请求失败，状态码：' + response.statusCode
                    })
                  }
                  if (response.statusCode === 401) {
                    await promptAction.openToast({
                      message: '登录失败，原因：账号密码错误'
                    })
                  }
                }
              } catch (err) {
                session.close()
                dialogControllerProgress.close()
                await promptAction.openToast({
                  message: '发生错误，错误码：' + err.code
                })
              }
            })
          Row() {
            Toggle({
              type: ToggleType.Checkbox,
              isOn: this.agree!!
            })
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Text() {
              Span('已阅读并同意')
              Span('《WebDAV助手用户服务条款与条件》')
                .fontColor($r('sys.color.font_emphasize'))
                .onClick(async () => {
                  try {
                    const appPrivacyLink = privacyManager.getAppPrivacyMgmtInfo().privacyInfo
                      .find(item => item.type === privacyManager.AppPrivacyLinkType.USER_AGREEMENT_LINK)
                    await openLink(this.context, appPrivacyLink?.url as string)
                  } catch (err) {
                    await promptAction.openToast({
                      message: '发生错误，错误码：' + err.code + '，错误信息：' + err.message
                    })
                  }
                })
              Span('《关于WebDAV助手与隐私的声明》')
                .fontColor($r('sys.color.font_emphasize'))
                .onClick(async () => {
                  try {
                    const appPrivacyLink = privacyManager.getAppPrivacyMgmtInfo().privacyInfo
                      .find(item => item.type === privacyManager.AppPrivacyLinkType.PRIVACY_STATEMENT_LINK)
                    await openLink(this.context, appPrivacyLink?.url as string)
                  } catch (err) {
                    await promptAction.openToast({
                      message: '发生错误，错误码：' + err.code + '，错误信息：' + err.message
                    })
                  }
                })
              Span('。')
            }
            .enableAutoSpacing(true)
            .fontSize($r('sys.float.ohos_id_text_size_body3'))
            .layoutWeight(1)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_l')
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
}