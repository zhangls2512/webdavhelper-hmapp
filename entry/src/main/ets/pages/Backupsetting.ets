import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { HdsNavDestination } from '@kit.UIDesignKit'
import { getAccountHash, getAccountInfo } from '../common/Account'
import { generateBackupTaskList } from '../common/Backup'
import { read, write } from '../common/File'
import { checkPermission } from '../common/Permission'

export interface BackupSetting {
  autoTypes: string[]
}

@Builder
export function BackupsettingBuilder() {
  Backupsetting()
}

@ComponentV2
struct Backupsetting {
  @Local autoTypes: string[] = []
  @Local deleteAfterSuccess: boolean = false
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()
  typeArray: string[] = ['相册', '文档', '桌面']
  backupSettingDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'backupSetting'
  })

  async getSetting() {
    const accountInfo = await getAccountInfo()
    const filePath = this.context.filesDir + '/backupsetting/' + getAccountHash(accountInfo) + '.txt'
    const filestring = await read(filePath, true)
    if (filestring !== 'fail') {
      this.autoTypes = (JSON.parse(filestring) as BackupSetting).autoTypes
    }
    this.deleteAfterSuccess = this.backupSettingDataPreferences.getSync('deleteAfterSuccess', true) as boolean
  }

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Text('自动')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              ForEach(this.typeArray, (item: string, index) => {
                if (index !== 0 && deviceInfo.deviceType !== 'phone') {
                  Divider()
                    .padding({
                      left: 12,
                      right: 12
                    })
                }
                if (index === 0 || (index > 0 && deviceInfo.deviceType !== 'phone')) {
                  Row() {
                    Text(item)
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                    Toggle({
                      type: ToggleType.Switch,
                      isOn: this.autoTypes.includes(item)
                    })
                      .onChange(async (isOn) => {
                        if (!isOn) {
                          this.autoTypes = this.autoTypes.filter(inItem => inItem !== item)
                        }
                        if (isOn) {
                          this.autoTypes = Array.from(new Set([...this.autoTypes, item]))
                          let res = true
                          if (item === '相册') {
                            res = await checkPermission(this.context, this.UIContext, 'ohos.permission.READ_IMAGEVIDEO')
                            await checkPermission(this.context, this.UIContext, 'ohos.permission.MEDIA_LOCATION')
                          }
                          if (item === '文档') {
                            res = await checkPermission(this.context, this.UIContext,
                              'ohos.permission.READ_WRITE_DOCUMENTS_DIRECTORY')
                          }
                          if (item === '桌面') {
                            res = await checkPermission(this.context, this.UIContext,
                              'ohos.permission.READ_WRITE_DESKTOP_DIRECTORY')
                          }
                          if (!res) {
                            this.autoTypes = this.autoTypes.filter(inItem => inItem !== item)
                          }
                        }
                        const accountInfo = await getAccountInfo()
                        await write(this.context.filesDir + '/backupsetting/' + getAccountHash(accountInfo) + '.txt',
                          JSON.stringify({
                            autoTypes: this.autoTypes
                          }))
                      })
                  }
                  .borderRadius(12)
                  .padding(12)
                  .width('100%')
                }
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Text('手动')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              ForEach(this.typeArray, (item: string, index) => {
                if (index !== 0 && deviceInfo.deviceType !== 'phone') {
                  Divider()
                    .padding({
                      left: 12,
                      right: 12
                    })
                }
                if (index === 0 || (index > 0 && deviceInfo.deviceType !== 'phone')) {
                  Row() {
                    Text(item)
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
                      .backgroundColor(this.hoverId === index ? $r('sys.color.interactive_hover') :
                        $r('sys.color.ohos_id_color_card_bg'))
                    },
                    pressed: {
                      .backgroundColor($r('sys.color.interactive_pressed'))
                    }
                  })
                  .width('100%')
                  .onHover((isHover) => {
                    if (!isHover) {
                      this.hoverId = -1
                    }
                    if (isHover) {
                      this.hoverId = index
                    }
                  })
                  .onClick(async () => {
                    let res = false
                    if (item === '相册') {
                      res = await checkPermission(this.context, this.UIContext, 'ohos.permission.READ_IMAGEVIDEO')
                      await checkPermission(this.context, this.UIContext, 'ohos.permission.MEDIA_LOCATION')
                    }
                    if (item === '文档') {
                      res = await checkPermission(this.context, this.UIContext,
                        'ohos.permission.READ_WRITE_DOCUMENTS_DIRECTORY')
                    }
                    if (item === '桌面') {
                      res = await checkPermission(this.context, this.UIContext,
                        'ohos.permission.READ_WRITE_DESKTOP_DIRECTORY')
                    }
                    if (res) {
                      const dialogControllerProgress = new CustomDialogController({
                        builder: LoadingDialog({
                          content: '备份准备中...'
                        })
                      })
                      dialogControllerProgress.open()
                      await generateBackupTaskList(this.context, item)
                      dialogControllerProgress.close()
                      await promptAction.openToast({
                        message: '备份已开始'
                      })
                    }
                  })
                }
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Row() {
              Text('备份成功后自动删除备份任务')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Toggle({
                type: ToggleType.Switch,
                isOn: this.deleteAfterSuccess!!
              })
                .onChange((isOn) => {
                  this.backupSettingDataPreferences.putSync('deleteAfterSuccess', isOn)
                  this.backupSettingDataPreferences.flushSync()
                })
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Row() {
              Text('备份任务')
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
                .backgroundColor(this.hoverId === 3 ? $r('sys.color.interactive_hover') :
                  $r('sys.color.ohos_id_color_card_bg'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              }
            })
            .width('100%')
            .onHover((isHover) => {
              if (!isHover) {
                this.hoverId = -1
              }
              if (isHover) {
                this.hoverId = 3
              }
            })
            .onClick(() => {
              this.pageInfos.pushPath({
                name: 'Backuptask'
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
      content: {
        title: {
          mainTitle: '备份'
        }
      },
      enableComponentSafeArea: true
    })
    .onReady(async (context) => {
      this.pageInfos = context.pathStack
      await this.getSetting()
    })
  }
}