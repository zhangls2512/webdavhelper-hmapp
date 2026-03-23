import { bundleManager, common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { webview } from '@kit.ArkWeb'
import { fileIo } from '@kit.CoreFileKit'
import { getDirectorySize, getFileSize } from '../common/File'
import { getSizeString } from '../common/Stringformat'

@ComponentV2
export default struct Cleardata {
  @Local setting: string[] = []
  @Local allSetting: boolean = false
  @Local commonSetting: boolean = false
  @Local commonSettingSize: string = ''
  @Local permissionSetting: boolean = false
  @Local permissionSettingSize: string = ''
  @Local debugSetting: boolean = false
  @Local debugSettingSize: string = ''
  @Local cache: string[] = []
  @Local allCache: boolean = false
  @Local appCache: boolean = false
  @Local appCacheSize: string = ''
  @Local webviewCache: boolean = false
  @Local log: string[] = []
  @Local allLog: boolean = false
  @Local errorLog: boolean = false
  @Local errorLogSize: string = ''
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  async getSize() {
    this.commonSettingSize = getSizeString(getFileSize(this.context.preferencesDir + '/commonSetting'))
    this.permissionSettingSize = getSizeString(getFileSize(this.context.preferencesDir + '/permissionSetting'))
    this.debugSettingSize = getSizeString(getFileSize(this.context.preferencesDir + '/debugSetting'))
    const appCacheSize = await getDirectorySize(this.context.cacheDir)
    this.appCacheSize = getSizeString(appCacheSize)
    const errorLogSize = await getDirectorySize(this.context.filesDir + '/log/error')
    this.errorLogSize = getSizeString(errorLogSize)
  }

  build() {
    List() {
      ListItem() {
        Column() {
          Text('设置')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
            .margin({
              bottom: 6,
              left: 12,
              right: 12
            })
          Column() {
            Row() {
              Text('全部')
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              CheckboxGroup({
                group: 'setting'
              })
                .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
                .selectAll(this.allSetting!!)
                .onChange((itemName) => {
                  this.setting = itemName.name
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
              Text('通用')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.commonSettingSize)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Checkbox({
                name: 'commonSetting',
                group: 'setting'
              })
                .select(this.commonSetting!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
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
              Text('权限')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.permissionSettingSize)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Checkbox({
                name: 'permissionSetting',
                group: 'setting'
              })
                .select(this.permissionSetting!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
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
              Text('调试')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.debugSettingSize)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Checkbox({
                name: 'debugSetting',
                group: 'setting'
              })
                .select(this.debugSetting!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))

          Button('清理设置')
            .enabled(this.setting.length > 0)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .role(ButtonRole.ERROR)
            .width('100%')
            .onClick(async () => {
              const promptAction = this.UIContext.getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '清理成功后将恢复所选设置为默认，无法恢复。确定清理？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '清理',
                    color: $r('sys.color.warning')
                  }
                ]
              })
              if (data.index === 1) {
                this.setting.forEach((item) => {
                  const dataPreferences = preferences.getPreferencesSync(this.context, {
                    name: item
                  })
                  dataPreferences.clearSync()
                  dataPreferences.flushSync()
                })
                await this.getSize()
                const res = await promptAction.showDialog({
                  title: '提示',
                  message: '清理成功，需重启应用生效，是否重启？',
                  buttons: [
                    {
                      text: '取消',
                      color: $r('sys.color.font_primary')
                    },
                    {
                      text: '重启',
                      color: $r('sys.color.font_emphasize')
                    }
                  ]
                })
                if (res.index === 1) {
                  const applicationContext = this.context.getApplicationContext()
                  applicationContext.restartApp({
                    bundleName: 'com.zhuzx.webdavhelper',
                    abilityName: 'EntryAbility'
                  })
                }
              }
            })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_m')
      })

      ListItem() {
        Column() {
          Text('缓存')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
            .margin({
              bottom: 6,
              left: 12,
              right: 12
            })
          Column() {
            Row() {
              Text('全部')
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              CheckboxGroup({
                group: 'cache'
              })
                .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
                .selectAll(this.allCache!!)
                .onChange((itemName) => {
                  this.cache = itemName.name
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
              Text('应用')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.appCacheSize)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Checkbox({
                name: 'appCache',
                group: 'cache'
              })
                .select(this.appCache!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
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
              Text('Webview')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Checkbox({
                name: 'webviewCache',
                group: 'cache'
              })
                .select(this.webviewCache!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))

          Button('清理缓存')
            .enabled(this.cache.length > 0)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .role(ButtonRole.ERROR)
            .width('100%')
            .onClick(async () => {
              const promptAction = this.UIContext.getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '清理成功后性能可能略微降低，但不会影响正常使用。确定清理？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '清理',
                    color: $r('sys.color.warning')
                  }
                ]
              })
              if (data.index === 1) {
                const promises = this.cache.map(async (item) => {
                  if (item === 'appCache') {
                    await bundleManager.cleanBundleCacheFilesForSelf()
                  }
                  if (item === 'webviewCache') {
                    webview.WebviewController.removeAllCache(true)
                  }
                })
                await Promise.all(promises)
                await promptAction.openToast({
                  message: '清理成功'
                })
                await this.getSize()
              }
            })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_l')
      })

      ListItem() {
        Column() {
          Text('日志')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
            .margin({
              bottom: 6,
              left: 12,
              right: 12
            })
          Column() {
            Row() {
              Text('全部')
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              CheckboxGroup({
                group: 'log'
              })
                .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
                .selectAll(this.allLog!!)
                .onChange((itemName) => {
                  this.log = itemName.name
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
              Text('故障')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.errorLogSize)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
              Checkbox({
                name: 'errorLog',
                group: 'log'
              })
                .select(this.errorLog!!)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))

          Button('清理日志')
            .enabled(this.log.length > 0)
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .role(ButtonRole.ERROR)
            .width('100%')
            .onClick(async () => {
              const promptAction = this.UIContext.getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '日志有助于开发者定位问题。清理成功后无法恢复，确定清理？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '清理',
                    color: $r('sys.color.warning')
                  }
                ]
              })
              if (data.index === 1) {
                const promises = this.log.map(async (item) => {
                  if (item === 'errorLog') {
                    const errorLogDir = this.context.filesDir + '/log/error/'
                    if (fileIo.accessSync(errorLogDir)) {
                      const fileNames = await fileIo.listFile(errorLogDir)
                      const promises = fileNames.map(async (item) => {
                        await fileIo.unlink(errorLogDir + item)
                      })
                      await Promise.all(promises)
                    }
                  }
                })
                await Promise.all(promises)
                await promptAction.openToast({
                  message: '清理成功'
                })
                await this.getSize()
              }
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
    .onAppear(async () => {
      await this.getSize()
    })
    .onDisAppear(() => {
      this.context.eventHub.emit('refreshSetting')
    })
  }
}