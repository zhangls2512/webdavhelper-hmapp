import { common } from '@kit.AbilityKit'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { filePreview } from '@kit.PreviewKit'
import { write } from '../common/File'
import { developerRequest } from '../common/Request'

@ComponentV2
export default struct Uploaderrorlog {
  @Consumer() isShowUploaderrorlogSheet: boolean = false
  @Param errorType: string = ''
  @Param errorObject: string = ''
  @Local errorDesc: string = ''
  @Local contactType: string = '邮箱'
  @Local contactTypeIndex: number = 0
  @Local contactValue: string = ''
  @Local uploadErrorObject: boolean = true
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  errorObjectFilePath = this.context.tempDir + '/log/error/' + Date.now() + '.txt'

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

          TextArea({
            placeholder: '请输入故障描述',
            text: this.errorDesc!!
          })
            .defaultFocus(true)
            .enableAutoSpacing(true)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .maxLength(500)
            .showCounter(true)
          Text('联系方式')
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
              .onSelect(index => {
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

          Row() {
            Toggle({
              type: ToggleType.Checkbox,
              isOn: this.uploadErrorObject!!
            })
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Text() {
              Span('上传')
              Span('故障日志')
                .fontColor($r('sys.color.font_emphasize'))
                .onClick(async () => {
                  await filePreview.openPreview(this.context, {
                    title: this.errorObjectFilePath.substring(this.errorObjectFilePath.lastIndexOf('/') + 1),
                    uri: fileUri.getUriFromPath(this.errorObjectFilePath),
                    mimeType: ''
                  })
                })
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
              if (!this.errorDesc) {
                await promptAction.openToast({
                  message: '请输入故障描述'
                })
                return
              }
              if (!this.contactValue) {
                await promptAction.openToast({
                  message: '请输入联系方式'
                })
                return
              }
              const dialogControllerProgress = new CustomDialogController({
                builder: LoadingDialog({
                  content: '请求中...'
                })
              })
              dialogControllerProgress.open()
              const res = await developerRequest(this.context, '/product/newErrorLog', {
                product: 'webdavhelper',
                version: '1.0.1.6',
                errorDesc: this.errorDesc,
                errorObject: this.uploadErrorObject ? this.errorObject : false,
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
    .onAppear(async () => {
      await write(this.errorObjectFilePath, this.errorObject)
    })
    .onDisAppear(async () => {
      await fileIo.unlink(this.errorObjectFilePath)
    })
  }
}