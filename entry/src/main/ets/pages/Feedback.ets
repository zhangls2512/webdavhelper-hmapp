import { common } from '@kit.AbilityKit'
import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { developerRequest } from '../common/Request'

@Builder
export function FeedbackBuilder() {
  Feedback()
}

@ComponentV2
struct Feedback {
  @Local content: string = ''
  @Local contactType: string = '邮箱'
  @Local contactTypeIndex: number = 0
  @Local contactValue: string = ''
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            TextArea({
              placeholder: '请输入内容',
              text: this.content!!
            })
              .defaultFocus(true)
              .enableAutoSpacing(true)
              .maxLength(200)
              .showCounter(true)
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

            Button('提交')
              .enabled(this.content !== '')
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
                const res = await developerRequest(this.context, '/product/sendFeedbackEmail', {
                  product: 'webdavhelper',
                  version: '1.0.1.2',
                  content: this.content,
                  contactType: this.contactType,
                  contactValue: this.contactValue
                })
                dialogControllerProgress.close()
                if (res !== 'fail') {
                  await promptAction.openToast({
                    message: '提交成功'
                  })
                  this.pageInfos.pop()
                }
              })
            Text('建议填写联系方式，以便开发人员在需要时联系您。')
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
          mainTitle: '意见反馈'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady(context => {
      this.pageInfos = context.pathStack
    })
  }
}