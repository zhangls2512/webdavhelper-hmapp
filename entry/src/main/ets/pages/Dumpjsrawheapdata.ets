import { common } from '@kit.AbilityKit'
import { LengthMetrics } from '@kit.ArkUI'
import { fileIo, picker } from '@kit.CoreFileKit'
import { hidebug } from '@kit.PerformanceAnalysisKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'

@Builder
export function DumpjsrawheapdataBuilder() {
  Dumpjsrawheapdata()
}

@ComponentV2
struct Dumpjsrawheapdata {
  @Local needGC: boolean = false
  @Local needClean: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('GC')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.needGC!!
                })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('清除nodeId')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.needClean!!
                })
                  .enabled(false)
              }
              .borderRadius(12)
              .padding(12)
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Button('开始')
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                const promptAction = this.UIContext.getPromptAction()
                const data = await promptAction.showDialog({
                  title: '提示',
                  message: '此操作会消耗大量系统资源，开始后不能操作本应用直至完成。确定开始？',
                  buttons: [
                    {
                      text: '取消',
                      color: $r('sys.color.font_primary')
                    },
                    {
                      text: '开始',
                      color: $r('sys.color.font_emphasize')
                    }
                  ]
                })
                if (data.index === 1) {
                  try {
                    const res = await hidebug.dumpJsRawHeapData(this.needGC)
                    const documentSaveOptions = new picker.DocumentSaveOptions()
                    documentSaveOptions.newFileNames = [res.substring(res.lastIndexOf('/') + 1).slice(0, -8)]
                    documentSaveOptions.fileSuffixChoices = ['.rawheap']
                    const documentViewPicker = new picker.DocumentViewPicker(this.context)
                    const uris = await documentViewPicker.save(documentSaveOptions)
                    if (uris.length === 1) {
                      const destFile = fileIo.openSync(uris[0],
                        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
                      await fileIo.copyFile(res, destFile.fd)
                      fileIo.closeSync(destFile)
                      await promptAction.openToast({
                        message: '转储成功'
                      })
                    }
                    await fileIo.unlink(res)
                  } catch (err) {
                    await promptAction.openToast({
                      message: '发生错误，错误码：' + err.code
                    })
                  }
                }
              })
          }
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
          mainTitle: '转储当前线程虚拟机原始堆快照'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
  }
}