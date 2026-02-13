import { common } from '@kit.AbilityKit'
import { LengthMetrics, promptAction, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { fileUri } from '@kit.CoreFileKit'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'
import { getAccountInfo } from '../common/Account'
import { BackupTask, deleteBackupTask, getBackupTaskList, startBackupTask } from '../common/Backup'

@Builder
export function BackuptaskBuilder() {
  Backuptask()
}

@ComponentV2
struct Backuptask {
  @Local selectedIndex: number = 0
  @Local backupTaskArray: BackupTask[] = []
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          TabSegmentButtonV2({
            items: new SegmentButtonV2Items([
              { text: '等待中' },
              { text: '完成' },
              { text: '失败' }
            ]),
            selectedIndex: this.selectedIndex!!
          })
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          List() {
            if (this.selectedIndex === 0) {
              if (this.backupTaskArray.filter(item => item.status === 'pending').length === 0) {
                ListItem() {
                  Text('无数据')
                }
                .margin({
                  top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                })
                .width('100%')
              }
              ListItem() {
                Column() {
                  ForEach(this.backupTaskArray.filter(item => item.status === 'pending'), (item: BackupTask, index) => {
                    if (index !== 0) {
                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                    }
                    Row() {
                      Text(new fileUri.FileUri(item.srcFileUri).path)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                    }
                    .borderRadius(12)
                    .padding(12)
                    .width('100%')
                  })
                }
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                .padding($r('sys.float.ohos_id_corner_radius_mark'))
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
            }
            if (this.selectedIndex === 1) {
              if (this.backupTaskArray.filter(item => item.status === 'success').length === 0) {
                ListItem() {
                  Text('无数据')
                }
                .margin({
                  top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                })
                .width('100%')
              }
              ListItem() {
                Column() {
                  ForEach(this.backupTaskArray.filter(item => item.status === 'success'), (item: BackupTask, index) => {
                    if (index !== 0) {
                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                    }
                    Row() {
                      Text(new fileUri.FileUri(item.srcFileUri).path)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                      Image($r('app.media.delete'))
                        .height(24)
                        .onClick(async () => {
                          const accountInfo = await getAccountInfo()
                          await deleteBackupTask(this.context, accountInfo, item.id)
                          await promptAction.openToast({
                            message: '删除成功'
                          })
                          this.backupTaskArray = await getBackupTaskList(this.context)
                        })
                    }
                    .borderRadius(12)
                    .padding(12)
                    .width('100%')
                  })
                }
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                .padding($r('sys.float.ohos_id_corner_radius_mark'))
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
            }
            if (this.selectedIndex === 2) {
              if (this.backupTaskArray.filter(item => item.status === 'fail').length === 0) {
                ListItem() {
                  Text('无数据')
                }
                .margin({
                  top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                })
                .width('100%')
              }
              ListItem() {
                Column() {
                  ForEach(this.backupTaskArray.filter(item => item.status === 'fail'), (item: BackupTask, index) => {
                    if (index !== 0) {
                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                    }
                    Row() {
                      Text(new fileUri.FileUri(item.srcFileUri).path)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                      Image($r('app.media.reboot'))
                        .height(24)
                        .onClick(async () => {
                          await startBackupTask(this.context, item.id)
                          await promptAction.openToast({
                            message: '开始成功'
                          })
                          this.backupTaskArray = await getBackupTaskList(this.context)
                        })
                    }
                    .borderRadius(12)
                    .padding(12)
                    .width('100%')
                  })
                }
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                .padding($r('sys.float.ohos_id_corner_radius_mark'))
              }
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
            }
          }
          .layoutWeight(1)
        }
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
          mainTitle: '备份任务'
        }
      },
      enableComponentSafeArea: true
    })
    .onAppear(async () => {
      this.backupTaskArray = await getBackupTaskList(this.context)
    })
  }
}