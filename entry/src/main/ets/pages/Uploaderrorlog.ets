import { common } from '@kit.AbilityKit'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { developerRequest } from '../common/Request'

@ComponentV2
export default struct Uploaderrorlog {
  @Consumer() isShowUploaderrorlogSheet: boolean = false
  @Param errorType: string = ''
  @Param errorObject: string = ''
  @Local contactType: string = '邮箱'
  @Local contactTypeIndex: number = 0
  @Local contactValue: string = ''
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Text('故障类型')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Text(this.errorType)
          }

          Text('联系方式 (可选)')
            .fontWeight(FontWeight.Medium)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          Row() {
            Select([
              { value: '邮箱' },
              { value: '微信' },
              { value: 'QQ' }
            ])
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .selected(this.contactTypeIndex!!)
              .value(this.contactType!!)
              .onSelect((index) => {
                if (index === 0) {
                  this.contactType = '邮箱'
                }
                if (index === 1) {
                  this.contactType = '微信'
                }
                if (index === 2) {
                  this.contactType = 'QQ'
                }
              })
            if (this.contactType === '邮箱') {
              TextInput({
                placeholder: '请输入邮箱',
                text: this.contactValue!!
              })
                .contentType(ContentType.EMAIL_ADDRESS)
                .enableAutoSpacing(true)
                .layoutWeight(1)
                .type(InputType.Email)
            }
            if (this.contactType === '微信') {
              TextInput({
                placeholder: '请输入微信号',
                text: this.contactValue!!
              })
                .enableAutoSpacing(true)
                .layoutWeight(1)
                .maxLength(30)
            }
            if (this.contactType === 'QQ') {
              TextInput({
                placeholder: '请输入QQ号',
                text: this.contactValue!!
              })
                .enableAutoSpacing(true)
                .layoutWeight(1)
                .maxLength(20)
                .type(InputType.Number)
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Button('上传')
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .width('100%')
            .onClick(async () => {
              const dialogControllerProgress = new CustomDialogController({
                builder: LoadingDialog({
                  content: '请求中...'
                })
              })
              dialogControllerProgress.open()
              const res = await developerRequest(this.context, '/product/newErrorLog', {
                product: 'webdavhelper',
                version: '1.0.1.2',
                errorObject: JSON.parse(this.errorObject),
                contactType: this.contactType,
                contactValue: this.contactValue
              })
              dialogControllerProgress.close()
              if (res !== 'fail') {
                await promptAction.openToast({
                  message: '上传成功'
                })
                this.isShowUploaderrorlogSheet = false
              }
            })
          Text('建议填写联系方式，便于开发者排查、处理问题。')
            .fontWeight(FontWeight.Medium)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
        }
        .alignItems(HorizontalAlign.Start)
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