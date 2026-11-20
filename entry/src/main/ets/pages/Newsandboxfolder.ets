import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'

@ComponentV2
export default struct Newsandboxfolder {
  @Consumer() isShowNewsandboxfolderSheet: boolean = false
  @Param editPath: string = ''
  @Local name: string = ''
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    List() {
      ListItem() {
        Column() {
          TextInput({
            placeholder: '请输入名称',
            text: this.name!!
          })
            .defaultFocus(true)
            .enableAutoSpacing(true)
          Button('新建')
            .keyboardShortcut('S', [ModifierKey.CTRL])
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .width('100%')
            .onClick(async () => {
              if (!this.name) {
                await promptAction.openToast({
                  message: '请输入名称'
                })
                return
              }
              try {
                await fileIo.mkdir(this.editPath + '/' + this.name)
                await promptAction.openToast({
                  message: '新建成功'
                })
                this.context.eventHub.emit('refreshSandboxfilelist')
                this.isShowNewsandboxfolderSheet = false
              } catch (err) {
                await promptAction.openToast({
                  message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                })
              }
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