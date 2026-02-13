import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { LengthMetrics } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { policy } from '@kit.NetworkKit'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'
import { getPermission } from '../common/Permission'

@Builder
export function PermissionsettingBuilder() {
  Permissionsetting()
}

@ComponentV2
struct Permissionsetting {
  @Local writePasteBoard: boolean = false
  @Local hoverId: number = -1
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  dataSync = getPermission('ohos.permission.DISTRIBUTED_DATASYNC')
  readWriteDownloadDirectory = getPermission('ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY')
  permissionSettingDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'permissionSetting'
  })

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('系统授权')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: true
                })
                  .enabled(false)
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Text('系统自动开启此权限，无法手动管理。本应用使用此权限获取并根据指定类型文件图标、网络、Wi-Fi等信息，使用互联网、在后台持续运行、应用关闭前执行自定义的预关闭动作、振动、窗口置顶等能力优化使用体验。通过此权限获取的信息不上传到本应用开发者服务器。')
              .enableAutoSpacing(true)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
              .margin({
                top: 6,
                left: 12,
                right: 12
              })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Row() {
              Text('联网')
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
                .backgroundColor(this.hoverId === 0 ? $r('sys.color.interactive_hover') :
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
                this.hoverId = 0
              }
            })
            .onClick(async () => {
              await policy.showAppNetPolicySettings(this.context)
            })
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
            Column() {
              Row() {
                Text('设备发现和连接')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.dataSync
                })
                  .enabled(false)
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Text() {
              Span($r('app.string.DISTRIBUTED_DATASYNC_reason'))
                .fontColor($r('sys.color.font_secondary'))
              Span('请前往')
                .fontColor($r('sys.color.font_secondary'))
              Span('系统设置')
                .fontColor($r('sys.color.font_emphasize'))
                .fontWeight(FontWeight.Medium)
                .onClick(async () => {
                  await this.context.startAbility({
                    bundleName: 'com.huawei.hmos.settings',
                    abilityName: 'com.huawei.hmos.settings.MainAbility',
                    uri: 'application_info_entry',
                    parameters: {
                      pushParams: 'com.zhuzx.webdavhelper'
                    }
                  })
                })
              Span('管理此权限。')
                .fontColor($r('sys.color.font_secondary'))
            }
            .fontSize($r('sys.float.ohos_id_text_size_body3'))
            .margin({
              top: 6,
              left: 12,
              right: 12
            })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        if (deviceInfo.deviceType !== 'phone') {
          ListItem() {
            Column() {
              Column() {
                Row() {
                  Text('访问公共下载目录')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.readWriteDownloadDirectory
                  })
                    .enabled(false)
                }
                .borderRadius(12)
                .padding(12)
                .width('100%')
              }
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              .padding($r('sys.float.ohos_id_corner_radius_mark'))

              Text() {
                Span($r('app.string.READ_WRITE_DOWNLOAD_DIRECTORY_reason'))
                  .fontColor($r('sys.color.font_secondary'))
                Span('请前往')
                  .fontColor($r('sys.color.font_secondary'))
                Span('系统设置')
                  .fontColor($r('sys.color.font_emphasize'))
                  .fontWeight(FontWeight.Medium)
                  .onClick(async () => {
                    await this.context.startAbility({
                      bundleName: 'com.huawei.hmos.settings',
                      abilityName: 'com.huawei.hmos.settings.MainAbility',
                      uri: 'application_info_entry',
                      parameters: {
                        pushParams: 'com.zhuzx.webdavhelper'
                      }
                    })
                  })
                Span('管理此权限。')
                  .fontColor($r('sys.color.font_secondary'))
              }
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
              .margin({
                top: 6,
                left: 12,
                right: 12
              })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_l')
          })
        }
        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('写入剪贴板')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.writePasteBoard!!
                })
                  .onChange((isOn) => {
                    this.permissionSettingDataPreferences.putSync('writePasteBoard', isOn)
                    this.permissionSettingDataPreferences.flushSync()
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Text($r('app.string.WRITE_PASTEBOARD_reason'))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
              .margin({
                top: 6,
                left: 12,
                right: 12
              })
          }
          .alignItems(HorizontalAlign.Start)
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
      style: {
        thermoCtrl: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      },
      content: {
        title: {
          mainTitle: '权限管理'
        }
      },
      enableComponentSafeArea: true
    })
    .onAppear(() => {
      this.writePasteBoard = this.permissionSettingDataPreferences.getSync('writePasteBoard', false) as boolean
    })
  }
}