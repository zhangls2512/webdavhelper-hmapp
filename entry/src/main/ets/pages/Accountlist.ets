import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { hdsEffect } from '@kit.UIDesignKit'
import { AccountInfo, getAccountList, removeAccount, setAccount, setAccountBz } from '../common/Account'
import { getDnsServer } from '../common/Dnsserver'
import copy from '../common/Pasteboard'
import { getFlushPreference } from '../common/Preference'

@ComponentV2
export default struct Accountlist {
  @Consumer() isShowAccountlistSheet: boolean = false
  @Local accountArray: AccountInfo[] = []
  @Local pathConnectionStatusArray: string[] = []
  @Local bzId: string = ''
  @Local bz: string = ''
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  @Builder
  MenuBuilder(item: AccountInfo) {
    Menu() {
      MenuItem({
        startIcon: $r('app.media.copytext'),
        content: '复制地址'
      })
        .onClick(async () => {
          await copy(this.context, this.UIContext, item.path)
        })
      MenuItem({
        startIcon: $r('app.media.edit'),
        content: '编辑备注'
      })
        .onClick(() => {
          this.bzId = item.id
          this.bz = item.bz
        })
      MenuItem({
        startIcon: $r('app.media.delete'),
        content: '删除'
      })
        .onClick(async () => {
          const promptAction = this.UIContext.getPromptAction()
          const data = await promptAction.showDialog({
            title: '提示',
            message: '删除成功后无法恢复，确定删除？',
            buttons: [
              {
                text: '取消',
                color: $r('sys.color.font_primary')
              },
              {
                text: '删除',
                color: $r('sys.color.warning')
              }
            ]
          })
          if (data.index === 1) {
            await removeAccount(this.context, item.id)
            this.accountArray = await getAccountList(this.context)
            if (item.isLogin === 'true') {
              this.context.eventHub.emit('refreshMe')
              this.isShowAccountlistSheet = false
            }
          }
        })
    }
  }

  build() {
    List() {
      ListItem() {
        Row() {
          Text('切换账号')
            .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Column() {
            Image($r('app.media.new'))
          }
          .borderRadius(20)
          .height(40)
          .margin({
            right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
          })
          .padding(11)
          .stateStyles({
            normal: {
              .backgroundColor($r('sys.color.interactive_hover'))
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            }
          })
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .pointLight({
              sourceType: hdsEffect.PointLightSourceType.SOFT,
              illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
            })
            .buildEffect())
          .width(40)
          .onClick(() => {
            this.context.eventHub.emit('login')
            this.isShowAccountlistSheet = false
          })

          Column() {
            Image($r('app.media.cancel'))
          }
          .borderRadius(20)
          .height(40)
          .padding(11)
          .stateStyles({
            normal: {
              .backgroundColor($r('sys.color.interactive_hover'))
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            }
          })
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .pointLight({
              sourceType: hdsEffect.PointLightSourceType.SOFT,
              illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
            })
            .buildEffect())
          .width(40)
          .onClick(() => {
            this.isShowAccountlistSheet = false
          })
        }
      }
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_l')
      })
      .padding({
        left: $r('sys.float.ohos_id_default_padding_start'),
        right: $r('sys.float.ohos_id_default_padding_end')
      })

      if (!this.bzId) {
        if (this.accountArray.length === 0) {
          ListItem() {
            Text('无数据')
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_l')
          })
          .padding({
            left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
            right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
          })
          .width('100%')
        }
        ListItem() {
          Column() {
            ForEach(this.accountArray, (item: AccountInfo, index) => {
              if (index !== 0) {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
              }
              Row() {
                if (this.pathConnectionStatusArray[index] === 'connecting') {
                  Circle({
                    height: 16,
                    width: 16
                  })
                    .fill(Color.Orange)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                }
                if (this.pathConnectionStatusArray[index] === 'connected') {
                  Circle({
                    height: 16,
                    width: 16
                  })
                    .fill(Color.Green)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                }
                if (this.pathConnectionStatusArray[index] === 'disconnected') {
                  Circle({
                    height: 16,
                    width: 16
                  })
                    .fill(Color.Red)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                }
                Column() {
                  Text(item.name)
                    .fontWeight(FontWeight.Medium)
                  Text(item.path)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                  if (item.bz) {
                    Text('备注：' + item.bz)
                      .enableAutoSpacing(true)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .margin({
                        top: $r('sys.float.ohos_id_text_margin_vertical')
                      })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
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
              .onHover(isHover => {
                if (!isHover) {
                  this.hoverId = -1
                }
                if (isHover) {
                  this.hoverId = 0
                }
              })
              .onClick(async () => {
                if (item.isLogin === 'true') {
                  this.isShowAccountlistSheet = false
                  return
                }
                await setAccount(this.context, {
                  path: item.path,
                  name: item.name,
                  password: item.password,
                  bz: item.bz,
                  isLogin: 'true'
                })
                await promptAction.openToast({
                  message: '登录成功'
                })
                this.context.eventHub.emit('refreshFilelist')
                this.context.eventHub.emit('refreshMe')
                this.isShowAccountlistSheet = false
              })
              .bindContextMenu(this.MenuBuilder(item), ResponseType.LongPress, {
                hapticFeedbackMode: HapticFeedbackMode.AUTO
              })
              .bindContextMenu(this.MenuBuilder(item), ResponseType.RightClick, {
                hapticFeedbackMode: HapticFeedbackMode.AUTO
              })
            })
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
        .padding({
          left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
          right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
        })
      }
      if (this.bzId) {
        ListItem() {
          Column() {
            TextInput({
              placeholder: '请输入备注',
              text: this.bz!!
            })
              .enableAutoSpacing(true)
              .maxLength(20)
            Row() {
              Button('取消')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .layoutWeight(1)
                .onClick(() => {
                  this.bzId = ''
                  this.bz = ''
                })
              Blank()
                .width($r('sys.float.ohos_id_elements_margin_horizontal_m'))
              Button('保存')
                .layoutWeight(1)
                .onClick(async () => {
                  await setAccountBz(this.bzId, this.bz)
                  await promptAction.openToast({
                    message: '保存成功'
                  })
                  this.bzId = ''
                  this.bz = ''
                  this.accountArray = await getAccountList(this.context)
                })
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
        .padding({
          left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
          right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
        })
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed')
    })
    .onAppear(async () => {
      this.accountArray = await getAccountList(this.context)
      this.pathConnectionStatusArray = Array(this.accountArray.length).fill('connecting')
      const promises = this.accountArray.map(async (item, index) => {
        const session = rcp.createSession({
          requestConfiguration: {
            dns: {
              dnsRules: getDnsServer(this.context)
            },
            security: {
              remoteValidation: getFlushPreference(this.context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav',
                'system') as 'system' | 'skip',
              tlsRange: {
                min: 'TlsV1.2'
              }
            }
          }
        })
        try {
          await session.get(item.path)
          session.close()
          this.pathConnectionStatusArray[index] = 'connected'
        } catch {
          session.close()
          this.pathConnectionStatusArray[index] = 'disconnected'
        }
      })
      await Promise.all(promises)
    })
  }
}