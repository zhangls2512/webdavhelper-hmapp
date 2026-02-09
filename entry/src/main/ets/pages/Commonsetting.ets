import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { LengthMetrics, window } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { HdsNavDestination } from '@kit.UIDesignKit'
import { checkPermission, getPermission } from '../common/Permission'

@Builder
export function CommonsettingBuilder() {
  Commonsetting()
}

@ComponentV2
struct Commonsetting {
  @Local allowContinue: boolean = false
  @Local exitAfterContinue: boolean = false
  @Local allowRestore: boolean = false
  @Local acceptCollaborate: boolean = false
  @Local destroyWhenBackPressed: boolean = false
  @Local statusBar: boolean = false
  @Local colorModeIndex: number = 0
  @Local colorModeValue: string = '跟随系统'
  @Local windowRectAutoSave: boolean = false
  @Local windowTopmost: boolean = false
  @Local keepScreenOn: boolean = false
  @Local downloadDirectoryIndex: number = 0
  @Local downloadDirectoryValue: string = '应用'
  @Local filePreviewTypeIndex: number = 0
  @Local filePreviewTypeValue: string = '系统预览'
  @Local onlinePreviewMedia: boolean = false
  @Local selectFileDownloadPath: boolean = false
  @Local showAccountlistSheetAfterAppLaunch: boolean = false
  @Local cellularDataUseRemindIndex: number = 0
  @Local cellularDataUseRemindValue: string = '始终'
  @Local checkVersionUpdateIndex: number = 1
  @Local checkVersionUpdateValue: string = '非流量下'
  @Local openLinkTypeIndex: number = 0
  @Local openLinkTypeValue: string = '系统默认'
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()
  commonSettingDataPreferences = preferences.getPreferencesSync(this.context, {
    name: 'commonSetting'
  })

  build() {
    HdsNavDestination() {
      List() {
        ListItem() {
          Column() {
            Text('应用')
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
                Text('接续')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.allowContinue!!
                })
                  .onChange(async (isOn) => {
                    this.commonSettingDataPreferences.putSync('allowContinue', isOn)
                    this.commonSettingDataPreferences.flushSync()
                    const promptAction = this.UIContext.getPromptAction()
                    const data = await promptAction.showDialog({
                      title: '提示',
                      message: '设置成功，需重启应用生效，是否重启？',
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
                    if (data.index === 1) {
                      const applicationContext = this.context.getApplicationContext()
                      applicationContext.restartApp({
                        bundleName: 'com.zhuzx.webdavhelper',
                        abilityName: 'EntryAbility'
                      })
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
                Text('接续成功后退出')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.exitAfterContinue!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('exitAfterContinue', isOn)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('备份恢复')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.allowRestore!!
                })
                  .onChange(async (isOn) => {
                    this.commonSettingDataPreferences.putSync('allowRestore', isOn)
                    this.commonSettingDataPreferences.flushSync()
                    const promptAction = this.UIContext.getPromptAction()
                    const data = await promptAction.showDialog({
                      title: '提示',
                      message: '设置成功，需重启应用生效，是否重启？',
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
                    if (data.index === 1) {
                      const applicationContext = this.context.getApplicationContext()
                      applicationContext.restartApp({
                        bundleName: 'com.zhuzx.webdavhelper',
                        abilityName: 'EntryAbility'
                      })
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
                Text('接受协同')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.acceptCollaborate!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('acceptCollaborate', isOn)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('侧滑返回时退出')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.destroyWhenBackPressed!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('destroyWhenBackPressed', isOn)
                    this.commonSettingDataPreferences.flushSync()
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')

              if (deviceInfo.deviceType === '2in1') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('状态栏')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.statusBar!!
                  })
                    .onChange(async (isOn) => {
                      this.commonSettingDataPreferences.putSync('statusBar', isOn)
                      this.commonSettingDataPreferences.flushSync()
                      const promptAction = this.UIContext.getPromptAction()
                      const data = await promptAction.showDialog({
                        title: '提示',
                        message: '设置成功，需重启应用生效，是否重启？',
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
                      if (data.index === 1) {
                        const applicationContext = this.context.getApplicationContext()
                        applicationContext.restartApp({
                          bundleName: 'com.zhuzx.webdavhelper',
                          abilityName: 'EntryAbility'
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)
                .width('100%')
              }
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('防窥保护')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text('去设置')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
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
                await this.context.startAbility({
                  bundleName: 'com.huawei.hmos.settings',
                  abilityName: 'com.huawei.hmos.settings.MainAbility',
                  uri: 'privacy_settings',
                  parameters: {
                    pushParams: 'com.zhuzx.webdavhelper'
                  }
                })
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
            Text('界面')
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
                Column() {
                  Text('深色模式')
                    .fontWeight(FontWeight.Medium)
                  Text('不对卡片生效')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })

                Select([
                  { value: '跟随系统' },
                  { value: '浅色模式' },
                  { value: '深色模式' }
                ])
                  .selected(this.colorModeIndex!!)
                  .value(this.colorModeValue!!)
                  .onSelect((index) => {
                    const applicationContext = this.context.getApplicationContext()
                    if (index === 0) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
                    }
                    if (index === 1) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
                    }
                    if (index === 2) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
                    }
                    this.commonSettingDataPreferences.putSync('colorMode', index)
                    this.commonSettingDataPreferences.flushSync()
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')

              if (deviceInfo.deviceType === '2in1') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('记忆主窗口尺寸')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.windowRectAutoSave!!
                  })
                    .onChange(async (isOn) => {
                      this.commonSettingDataPreferences.putSync('windowRectAutoSave', isOn)
                      this.commonSettingDataPreferences.flushSync()
                      const promptAction = this.UIContext.getPromptAction()
                      const data = await promptAction.showDialog({
                        title: '提示',
                        message: '设置成功，需重启应用生效，是否重启？',
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
                      if (data.index === 1) {
                        const applicationContext = this.context.getApplicationContext()
                        applicationContext.restartApp({
                          bundleName: 'com.zhuzx.webdavhelper',
                          abilityName: 'EntryAbility'
                        })
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
                  Text('窗口置顶')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.windowTopmost!!
                  })
                    .onChange(async (isOn) => {
                      const lastWindow = await window.getLastWindow(this.context)
                      await lastWindow.setWindowTopmost(isOn)
                      this.commonSettingDataPreferences.putSync('windowTopmost', isOn)
                      this.commonSettingDataPreferences.flushSync()
                    })
                }
                .borderRadius(12)
                .padding(12)
                .width('100%')
              }
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Column() {
                  Text('屏幕常亮')
                    .fontWeight(FontWeight.Medium)
                  Text('仅在本次使用期间生效')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })

                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.keepScreenOn!!
                })
                  .onChange(async (isOn) => {
                    const lastWindow = await window.getLastWindow(this.context)
                    await lastWindow.setWindowKeepScreenOn(isOn)
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
                Text('背景图')
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
                  .backgroundColor(this.hoverId === 1 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 1
                }
              })
              .onClick(async () => {
                const backgroundImagePath = this.context.filesDir + '/media/backgroundimage.png'
                const res = fileIo.accessSync(backgroundImagePath)
                if (!res) {
                  try {
                    const photoPicker = new photoAccessHelper.PhotoViewPicker()
                    const pickerres = await photoPicker.select({
                      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                      maxSelectNumber: 1,
                      isOriginalSupported: false
                    })
                    const fileSource = fileIo.openSync(pickerres.photoUris[0])
                    const imageSource = image.createImageSource(fileSource.fd)
                    const imagePixelMap = await imageSource.createPixelMap()
                    await imageSource.release()
                    if (!fileIo.accessSync(this.context.filesDir + '/media')) {
                      await fileIo.mkdir(this.context.filesDir + '/media')
                    }
                    const file =
                      fileIo.openSync(backgroundImagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
                    const imagePacker = image.createImagePacker()
                    await imagePacker.packToFile(imagePixelMap, file.fd, {
                      format: 'image/png',
                      quality: 100
                    })
                    await imagePacker.release()
                    await imagePixelMap.release()
                    fileIo.closeSync(file)
                    this.context.eventHub.emit('refreshIndex')
                  } catch {
                  }
                  return
                }
                if (res) {
                  const promptAction = this.UIContext.getPromptAction()
                  const data = await promptAction.showActionMenu({
                    title: '设置背景图',
                    buttons: [
                      {
                        text: '从图库中选择',
                        color: $r('sys.color.font_primary')
                      },
                      {
                        text: '恢复默认',
                        color: $r('sys.color.font_primary')
                      }
                    ]
                  })
                  if (data.index === 0) {
                    try {
                      const photoPicker = new photoAccessHelper.PhotoViewPicker()
                      const pickerres = await photoPicker.select({
                        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                        maxSelectNumber: 1,
                        isOriginalSupported: false
                      })
                      const fileSource = fileIo.openSync(pickerres.photoUris[0])
                      const imageSource = image.createImageSource(fileSource.fd)
                      const imagePixelMap = await imageSource.createPixelMap()
                      await imageSource.release()
                      const file =
                        fileIo.openSync(backgroundImagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
                      const imagePacker = image.createImagePacker()
                      await imagePacker.packToFile(imagePixelMap, file.fd, {
                        format: 'image/png',
                        quality: 100
                      })
                      await imagePacker.release()
                      await imagePixelMap.release()
                      fileIo.closeSync(file)
                      this.context.eventHub.emit('refreshIndex')
                    } catch {
                    }
                  }
                  if (data.index === 1) {
                    await fileIo.unlink(backgroundImagePath)
                    this.context.eventHub.emit('refreshIndex')
                  }
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

        if (deviceInfo.deviceType !== 'phone') {
          ListItem() {
            Column() {
              Text('传输')
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
                  Column() {
                    Text('下载目录')
                      .fontWeight(FontWeight.Medium)
                    Text('新下载的文件会覆盖下载前下载目录中已有的同名文件')
                      .fontColor($r('sys.color.font_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .margin({
                        top: $r('sys.float.ohos_id_text_margin_vertical')
                      })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })

                  Select([
                    { value: '应用' },
                    { value: '系统' }
                  ])
                    .selected(this.downloadDirectoryIndex!!)
                    .value(this.downloadDirectoryValue!!)
                    .onSelect(async (index) => {
                      if (index === 1) {
                        const res = await checkPermission(this.context, this.UIContext,
                          'ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY')
                        if (!res) {
                          this.downloadDirectoryIndex = 0
                          this.downloadDirectoryValue = '应用'
                          return
                        }
                      }
                      this.commonSettingDataPreferences.putSync('downloadDirectory', index)
                      this.commonSettingDataPreferences.flushSync()
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
            .alignItems(HorizontalAlign.Start)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_l')
          })
        }
        ListItem() {
          Column() {
            Text('文件')
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
                Text('预览方式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '系统预览' },
                  { value: '自行选择' }
                ])
                  .selected(this.filePreviewTypeIndex!!)
                  .value(this.filePreviewTypeValue!!)
                  .onSelect((index) => {
                    this.commonSettingDataPreferences.putSync('filePreviewType', index)
                    this.commonSettingDataPreferences.flushSync()
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
                Column() {
                  Text('在线预览音、视频')
                    .fontWeight(FontWeight.Medium)
                  Text('目前仅支持mp4、mkv、m4a、aac、mp3、ogg、wav、flac、amr、ape格式')
                    .enableAutoSpacing(true)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })

                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.onlinePreviewMedia!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('onlinePreviewMedia', isOn)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('自定义下载位置')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.selectFileDownloadPath!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('selectFileDownloadPath', isOn)
                    this.commonSettingDataPreferences.flushSync()
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
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('更多')
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
                Text('应用启动后拉起切换账号弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showAccountlistSheetAfterAppLaunch!!
                })
                  .onChange((isOn) => {
                    this.commonSettingDataPreferences.putSync('showAccountlistSheetAfterAppLaunch', isOn)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('流量使用提醒')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '始终' },
                  { value: '大于 200 MB' },
                  { value: '从不' }
                ])
                  .selected(this.cellularDataUseRemindIndex!!)
                  .value(this.cellularDataUseRemindValue!!)
                  .onSelect((index) => {
                    this.commonSettingDataPreferences.putSync('cellularDataUseRemind', index)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('启动时检查更新')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '从不' },
                  { value: '非流量下' },
                  { value: '始终' }
                ])
                  .selected(this.checkVersionUpdateIndex!!)
                  .value(this.checkVersionUpdateValue!!)
                  .onSelect((index) => {
                    this.commonSettingDataPreferences.putSync('checkVersionUpdate', index)
                    this.commonSettingDataPreferences.flushSync()
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
                Text('链接打开方式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '系统默认' },
                  { value: '自行选择' }
                ])
                  .selected(this.openLinkTypeIndex!!)
                  .value(this.openLinkTypeValue!!)
                  .onSelect((index) => {
                    this.commonSettingDataPreferences.putSync('openLinkType', index)
                    this.commonSettingDataPreferences.flushSync()
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
      content: {
        title: {
          mainTitle: '通用'
        }
      },
      enableComponentSafeArea: true
    })
    .onReady(async (context) => {
      this.pageInfos = context.pathStack
      this.allowContinue = this.commonSettingDataPreferences.getSync('allowContinue', true) as boolean
      this.exitAfterContinue = this.commonSettingDataPreferences.getSync('exitAfterContinue', true) as boolean
      this.allowRestore = this.commonSettingDataPreferences.getSync('allowRestore', true) as boolean
      this.acceptCollaborate = this.commonSettingDataPreferences.getSync('acceptCollaborate', true) as boolean
      this.destroyWhenBackPressed =
        this.commonSettingDataPreferences.getSync('destroyWhenBackPressed', false) as boolean
      this.statusBar = this.commonSettingDataPreferences.getSync('statusBar', false) as boolean
      const colorMode = this.commonSettingDataPreferences.getSync('colorMode', 0)
      this.colorModeIndex = colorMode as number
      if (colorMode === 0) {
        this.colorModeValue = '跟随系统'
      }
      if (colorMode === 1) {
        this.colorModeValue = '浅色模式'
      }
      if (colorMode === 2) {
        this.colorModeValue = '深色模式'
      }
      this.windowRectAutoSave = this.commonSettingDataPreferences.getSync('windowRectAutoSave', false) as boolean
      this.windowTopmost = this.commonSettingDataPreferences.getSync('windowTopmost', false) as boolean
      const lastWindow = await window.getLastWindow(this.context)
      this.keepScreenOn = lastWindow.getWindowProperties().isKeepScreenOn
      const downloadDirectory = this.commonSettingDataPreferences.getSync('downloadDirectory', 0)
      this.downloadDirectoryIndex = downloadDirectory as number
      if (downloadDirectory === 0) {
        this.downloadDirectoryValue = '应用'
      }
      if (downloadDirectory === 1 && getPermission('ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY')) {
        this.downloadDirectoryValue = '系统'
      }
      const filePreviewType = this.commonSettingDataPreferences.getSync('filePreviewType', 0)
      this.filePreviewTypeIndex = filePreviewType as number
      if (filePreviewType === 0) {
        this.filePreviewTypeValue = '系统预览'
      }
      if (filePreviewType === 1) {
        this.filePreviewTypeValue = '自行选择'
      }
      this.onlinePreviewMedia = this.commonSettingDataPreferences.getSync('onlinePreviewMedia', true) as boolean
      this.selectFileDownloadPath =
        this.commonSettingDataPreferences.getSync('selectFileDownloadPath', false) as boolean
      const cellularDataUseRemind = this.commonSettingDataPreferences.getSync('cellularDataUseRemind', 0)
      this.cellularDataUseRemindIndex = cellularDataUseRemind as number
      if (cellularDataUseRemind === 0) {
        this.cellularDataUseRemindValue = '始终'
      }
      if (cellularDataUseRemind === 1) {
        this.cellularDataUseRemindValue = '大于 200 MB'
      }
      if (cellularDataUseRemind === 2) {
        this.cellularDataUseRemindValue = '从不'
      }
      const checkVersionUpdate = this.commonSettingDataPreferences.getSync('checkVersionUpdate', 1)
      this.checkVersionUpdateIndex = checkVersionUpdate as number
      if (checkVersionUpdate === 0) {
        this.checkVersionUpdateValue = '从不'
      }
      if (checkVersionUpdate === 1) {
        this.checkVersionUpdateValue = '非流量下'
      }
      if (checkVersionUpdate === 2) {
        this.checkVersionUpdateValue = '始终'
      }
      const openLinkType = this.commonSettingDataPreferences.getSync('openLinkType', 0)
      this.openLinkTypeIndex = openLinkType as number
      if (openLinkType === 0) {
        this.openLinkTypeValue = '系统默认'
      }
      if (openLinkType === 1) {
        this.openLinkTypeValue = '自行选择'
      }
    })
  }
}