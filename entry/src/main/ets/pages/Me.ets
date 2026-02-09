import { common } from '@kit.AbilityKit'
import { display, promptAction } from '@kit.ArkUI'
import { exitAccount, getAccountInfo } from '../common/Account'
import { getPreferType } from '../common/Prefertype'
import Accountlist from './Accountlist'
import Login from './Login'
import Setting from './Setting'

@ComponentV2
export default struct Me {
  @Provider() isShowLoginSheet: boolean = false
  @Provider() isShowAccountlistSheet: boolean = false
  @Local isShowSettingSheet: boolean = false
  @Local preferType: number = 1
  @Local name: string = ''
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  async get() {
    const accountInfo = await getAccountInfo()
    this.name = accountInfo.name
  }

  @Builder
  LoginSheetBuilder() {
    Login()
  }

  @Builder
  AccountlistSheetBuilder() {
    Accountlist()
  }

  @Builder
  SettingSheetBuilder() {
    Setting()
  }

  build() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Image($r('app.media.foreground'))
              .height(40)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .width(40)
            if (!this.name) {
              Text('登录')
                .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
            }
            if (this.name) {
              Text(this.name)
                .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
            }
          }
          .borderRadius(12)
          .padding(12)
          .stateStyles({
            normal: {
              .backgroundColor(this.hoverId === 0 ? $r('sys.color.interactive_hover') :
                $r('sys.color.comp_background_primary'))
            },
            pressed: {
              .backgroundColor($r('sys.color.comp_background_secondary'))
            }
          })
          .width('100%')
          .onHover((isHover) => {
            if (!isHover) {
              this.hoverId = -1
            }
            if (isHover) {
              this.hoverId = 0
            }
          })
          .onClick(() => {
            if (!this.name) {
              this.isShowLoginSheet = true
            }
          })
          .bindSheet(this.isShowLoginSheet!!, this.LoginSheetBuilder(), {
            height: SheetSize.FIT_CONTENT,
            preferType: this.preferType,
            title: {
              title: '登录'
            },
            onDisappear: async () => {
              await this.get()
            }
          })

          Divider()
            .padding({
              left: 12,
              right: 12
            })
          Row() {
            Image($r('app.media.users'))
              .fillColor($r('sys.color.icon_primary'))
              .height(24)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .width(24)
            Text('切换账号')
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
              .backgroundColor(this.hoverId === 1 ? $r('sys.color.interactive_hover') :
                $r('sys.color.comp_background_primary'))
            },
            pressed: {
              .backgroundColor($r('sys.color.comp_background_secondary'))
            }
          })
          .width('100%')
          .onHover((isHover) => {
            if (!isHover) {
              this.hoverId = -1
            }
            if (isHover) {
              this.hoverId = 1
            }
          })
          .onClick(() => {
            this.isShowAccountlistSheet = true
          })
          .bindSheet(this.isShowAccountlistSheet!!, this.AccountlistSheetBuilder(), {
            height: SheetSize.FIT_CONTENT,
            preferType: this.preferType,
            showClose: false
          })
        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
        .padding($r('sys.float.ohos_id_corner_radius_mark'))
      }

      ListItem() {
        Column() {
          Row() {
            Image($r('app.media.setting'))
              .fillColor($r('sys.color.icon_primary'))
              .height(24)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .width(24)
            Text('设置')
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
              .backgroundColor(this.hoverId === 2 ? $r('sys.color.interactive_hover') :
                $r('sys.color.comp_background_primary'))
            },
            pressed: {
              .backgroundColor($r('sys.color.comp_background_secondary'))
            }
          })
          .width('100%')
          .onHover((isHover) => {
            if (!isHover) {
              this.hoverId = -1
            }
            if (isHover) {
              this.hoverId = 2
            }
          })
          .onClick(() => {
            this.isShowSettingSheet = true
          })
          .bindSheet(this.isShowSettingSheet!!, this.SettingSheetBuilder(), {
            preferType: this.preferType,
            onDisappear: async () => {
              await this.get()
            }
          })
        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
        .padding($r('sys.float.ohos_id_corner_radius_mark'))
      }
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_l')
      })

      if (this.name) {
        ListItem() {
          Button('退出登录')
            .role(ButtonRole.ERROR)
            .width('100%')
            .onClick(async () => {
              await exitAccount()
              await promptAction.openToast({
                message: '退出成功'
              })
              this.name = ''
            })
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
      }
    }
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      top: this.preferType === 0 ? 0 : $r('sys.float.ohos_id_default_padding_top')
    })
    .onAppear(async () => {
      this.preferType = getPreferType(this.UIContext)
      display.on('change', () => {
        setTimeout(() => {
          this.preferType = getPreferType(this.UIContext)
        }, 200)
      })
      this.context.eventHub.on('login', () => {
        this.isShowLoginSheet = true
      })
      this.context.eventHub.on('refreshMe', async () => {
        await this.get()
      })
      await this.get()
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshMe')
      this.context.eventHub.off('login')
      display.off('change')
    })
  }
}