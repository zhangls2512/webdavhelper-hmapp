import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'

@ComponentV2
export default struct Renamesandboxfile {
  @Consumer() isShowRenamesandboxfileSheet: boolean = false
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
          Button('重命名')
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
                await fileIo.rename(this.editPath,
                  this.editPath.slice(0, this.editPath.lastIndexOf('/') + 1) + this.name)
                await promptAction.openToast({
                  message: '重命名成功'
                })
                this.context.eventHub.emit('refreshSandboxfilelist')
                this.isShowRenamesandboxfileSheet = false
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
    .onAppear(() => {
      this.name = this.editPath.slice(this.editPath.lastIndexOf('/') + 1)
    })
  }
}