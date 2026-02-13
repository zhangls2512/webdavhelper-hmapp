import { appRecovery } from '@kit.AbilityKit'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'

@Builder
export function RecoverysettingBuilder() {
  Recoverysetting()
}

@ComponentV2
struct Recoverysetting {
  pageInfos = new NavPathStack()
  restart: appRecovery.RestartFlag = appRecovery.RestartFlag.RESTART_WHEN_APP_FREEZE
  saveOccasion: appRecovery.SaveOccasionFlag = appRecovery.SaveOccasionFlag.SAVE_WHEN_ERROR
  saveMode: appRecovery.SaveModeFlag = appRecovery.SaveModeFlag.SAVE_WITH_FILE

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('重启时机')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '总是' },
                  { value: 'JS_CRASH' },
                  { value: 'APP_FREEZE' },
                  { value: '从不' }
                ])
                  .selected(2)
                  .value('APP_FREEZE')
                  .onSelect((index) => {
                    if (index === 0) {
                      this.restart = appRecovery.RestartFlag.ALWAYS_RESTART
                    }
                    if (index === 1) {
                      this.restart = appRecovery.RestartFlag.RESTART_WHEN_JS_CRASH
                    }
                    if (index === 2) {
                      this.restart = appRecovery.RestartFlag.RESTART_WHEN_APP_FREEZE
                    }
                    if (index === 3) {
                      this.restart = appRecovery.RestartFlag.NO_RESTART
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('状态保存时机')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '发生故障' },
                  { value: '切入后台' }
                ])
                  .selected(0)
                  .value('发生故障')
                  .onSelect((index) => {
                    if (index === 0) {
                      this.saveOccasion = appRecovery.SaveOccasionFlag.SAVE_WHEN_ERROR
                    }
                    if (index === 1) {
                      this.saveOccasion = appRecovery.SaveOccasionFlag.SAVE_WHEN_BACKGROUND
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('状态保存方式')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Column() {
                  Select([
                    { value: '写入到本地文件缓存' },
                    { value: '先保存在内存中，故障退出时写入到本地文件缓存' }
                  ])
                    .selected(0)
                    .value('写入到本地文件缓存')
                    .onSelect((index) => {
                      if (index === 0) {
                        this.saveMode = appRecovery.SaveModeFlag.SAVE_WITH_FILE
                      }
                      if (index === 1) {
                        this.saveMode = appRecovery.SaveModeFlag.SAVE_WITH_SHARED_MEMORY
                      }
                    })
                }
                .alignItems(HorizontalAlign.End)
                .layoutWeight(1)
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Button('保存')
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                appRecovery.enableAppRecovery(this.restart, this.saveOccasion, this.saveMode)
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
      style: {
        thermoCtrl: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      },
      content: {
        title: {
          mainTitle: '应用恢复设置'
        }
      },
      enableComponentSafeArea: true
    })
    .onReady((context) => {
      this.pageInfos = context.pathStack
    })
  }
}