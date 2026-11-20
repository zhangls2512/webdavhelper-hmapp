import { common, wantConstant } from '@kit.AbilityKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { zlib } from '@kit.BasicServicesKit'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { filePreview } from '@kit.PreviewKit'
import { systemShare } from '@kit.ShareKit'
import {
  hdsEffect,
  hdsMaterial,
  HdsNavDestination,
  HdsNavDestinationTitleMode,
  ScrollEffectType
} from '@kit.UIDesignKit'
import { getFileTypeIcon } from '../common/File'
import { getPreferType } from '../common/Prefertype'
import { getSizeString, getTimeStringFromSecond } from '../common/Stringformat'
import Newsandboxfolder from './Newsandboxfolder'
import Renamesandboxfile from './Renamesandboxfile'

interface FileItem {
  path: string,
  name: string,
  isdir: boolean,
  size: number,
  mtime: number
}

@Builder
export function SandboxfilelistBuilder() {
  Sandboxfilelist()
}

@ComponentV2
struct Sandboxfilelist {
  @Provider() isShowNewsandboxfolderSheet: boolean = false
  @Provider() isShowRenamesandboxfileSheet: boolean = false
  @Local preferType: SheetType = SheetType.CENTER
  @Local fileArray: FileItem[] = []
  @Local dirnames: string[] = []
  @Local copyMovePath: string = ''
  @Local remove: boolean | undefined = undefined
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  editPath = ''
  dialogControllerProgress = new CustomDialogController({
    builder: LoadingDialog({
      content: '加载中...'
    })
  })

  getPath() {
    let path = ''
    this.dirnames.forEach((item, index) => {
      if (index !== 0) {
        path += '/' + item
      }
      if (index === 0) {
        if (item === 'proc') {
          path += '/proc/self'
        }
        if (item === 'bundlecode') {
          path += this.context.bundleCodeDir
        }
        if (item === 'data') {
          path += this.context.tempDir.split('/')
            .slice(0, -3)
            .join('/')
        }
        if (item === 'database') {
          path += this.context.databaseDir
        }
        if (item === 'distributedfiles') {
          path += this.context.distributedFilesDir
        }
      }
    })
    return path
  }

  async get() {
    const path = this.getPath()
    if (!path) {
      this.fileArray = [
        {
          path: '/proc/self',
          name: 'proc',
          isdir: true,
          size: -1,
          mtime: -1
        },
        {
          path: this.context.bundleCodeDir,
          name: 'bundlecode',
          isdir: true,
          size: -1,
          mtime: -1
        },
        {
          path: this.context.tempDir.split('/')
            .slice(0, -3)
            .join('/'),
          name: 'data',
          isdir: true,
          size: -1,
          mtime: -1
        },
        {
          path: this.context.databaseDir,
          name: 'database',
          isdir: true,
          size: -1,
          mtime: -1
        },
        {
          path: this.context.distributedFilesDir,
          name: 'distributedfiles',
          isdir: true,
          size: -1,
          mtime: -1
        }
      ]
    }
    if (path) {
      this.fileArray = []
      try {
        const files = await fileIo.listFile(path)
        const fileArray: FileItem[] = []
        const promises = files.map(item => {
          const itemPath = path + '/' + item
          const isDir = fileIo.statSync(itemPath).isDirectory()
          if (!isDir) {
            fileArray.push({
              path: itemPath,
              name: item,
              isdir: false,
              size: fileIo.statSync(itemPath).size,
              mtime: fileIo.statSync(itemPath).mtime
            })
          }
          if (isDir) {
            fileArray.push({
              path: itemPath,
              name: item,
              isdir: true,
              size: -1,
              mtime: -1
            })
          }
        })
        await Promise.all(promises)
        this.fileArray = fileArray.sort((a, b) => a.name.localeCompare(b.name))
      } catch (err) {
        await promptAction.openToast({
          message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
        })
        this.dirnames.pop()
        await this.get()
      }
    }
  }

  @Builder
  NewsandboxfolderSheetBuilder() {
    Newsandboxfolder({
      editPath: this.editPath
    })
  }

  @Builder
  RenamesandboxfileSheetBuilder() {
    Renamesandboxfile({
      editPath: this.editPath
    })
  }

  @Builder
  MenuBuilder(item: FileItem) {
    if (this.dirnames.length > 0) {
      Menu() {
        if (!item.isdir) {
          if (item.name.endsWith('.zip')) {
            MenuItem({
              startIcon: $r('app.media.compress'),
              content: '解压缩'
            })
              .onClick(async () => {
                this.dialogControllerProgress.open()
                try {
                  const destDir = this.getPath() + '/' + item.name.slice(0, -4)
                  if (!fileIo.accessSync(destDir)) {
                    await fileIo.mkdir(destDir)
                  }
                  await zlib.decompressFile(item.path, destDir)
                  this.dialogControllerProgress.close()
                  await promptAction.openToast({
                    message: '解压缩成功'
                  })
                  await this.get()
                } catch (err) {
                  this.dialogControllerProgress.close()
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                  })
                }
              })
          }
          MenuItem({
            startIcon: $r('app.media.share'),
            content: '分享'
          })
            .onClick(async () => {
              const shareData = new systemShare.SharedData({
                utd: uniformTypeDescriptor.UniformDataType.FILE,
                title: item.name,
                description: getSizeString(item.size),
                uri: fileUri.getUriFromPath(item.path)
              })
              const shareController = new systemShare.ShareController(shareData)
              await shareController.show(this.context, {})
            })
        }
        if (item.isdir) {
          MenuItem({
            startIcon: $r('app.media.compress'),
            content: '压缩'
          })
            .onClick(async () => {
              this.dialogControllerProgress.open()
              try {
                await zlib.compressFile(item.path, this.getPath() + '/' + item.name + '.zip', {})
                this.dialogControllerProgress.close()
                await promptAction.openToast({
                  message: '压缩成功'
                })
                await this.get()
              } catch (err) {
                this.dialogControllerProgress.close()
                await promptAction.openToast({
                  message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                })
              }
            })
        }
        if (!this.copyMovePath) {
          MenuItem({
            startIcon: $r('app.media.copy'),
            content: '复制'
          })
            .onClick(() => {
              this.copyMovePath = item.path
              this.remove = false
            })
          MenuItem({
            startIcon: $r('app.media.move'),
            content: '移动'
          })
            .onClick(() => {
              this.copyMovePath = item.path
              this.remove = true
            })
          MenuItem({
            startIcon: $r('app.media.rename'),
            content: '重命名'
          })
            .onClick(() => {
              this.editPath = item.path
              this.isShowRenamesandboxfileSheet = true
            })
          MenuItem({
            startIcon: $r('app.media.delete'),
            content: '删除'
          })
            .onClick(async () => {
              const promptAction = this.UIContext.getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '删除成功后无法恢复，确定删除？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '删除',
                    color: $r('sys.color.warning')
                  }
                ]
              })
              if (data.index === 1) {
                try {
                  if (!item.isdir) {
                    await fileIo.unlink(item.path)
                  }
                  if (item.isdir) {
                    await fileIo.rmdir(item.path)
                  }
                  await promptAction.openToast({
                    message: '删除成功'
                  })
                  await this.get()
                } catch (err) {
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                  })
                }
              }
            })
        }
      }
    }
  }

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          Text() {
            Span(' / ')
              .fontColor($r('sys.color.font_emphasize'))
              .onClick(async () => {
                this.dirnames = []
                await this.get()
              })
            ForEach(this.dirnames, (item: string, index) => {
              if (index !== 0) {
                Span('/ ')
              }
              Span(item + ' ')
                .fontColor($r('sys.color.font_emphasize'))
                .onClick(async () => {
                  this.dirnames = this.dirnames.slice(0, index + 1)
                  await this.get()
                })
            })
          }
          .enableAutoSpacing(true)
          .margin({
            bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          Row() {
            if (this.dirnames.length > 0) {
              Column() {
                Image($r('app.media.newfolder'))
              }
              .bindTips('新建文件夹')
              .borderRadius(20)
              .height(40)
              .keyboardShortcut('N', [ModifierKey.CTRL, ModifierKey.SHIFT])
              .padding(11)
              .stateStyles({
                normal: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .visualEffect(new hdsEffect.HdsEffectBuilder()
                .pointLight({
                  sourceType: hdsEffect.PointLightSourceType.SOFT,
                  illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
                })
                .buildEffect())
              .width(40)
              .onClick(() => {
                this.editPath = this.getPath()
                this.isShowNewsandboxfolderSheet = true
              })
              .bindSheet(this.isShowNewsandboxfolderSheet!!, this.NewsandboxfolderSheetBuilder(), {
                height: SheetSize.FIT_CONTENT,
                preferType: this.preferType,
                title: {
                  title: '新建文件夹'
                },
                onDisappear: () => {
                  this.editPath = ''
                }
              })

              if (!this.copyMovePath) {
                Blank()
                Column() {
                  Image($r('app.media.upload'))
                }
                .bindTips('上传')
                .borderRadius(20)
                .height(40)
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .visualEffect(new hdsEffect.HdsEffectBuilder()
                  .pointLight({
                    sourceType: hdsEffect.PointLightSourceType.SOFT,
                    illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
                  })
                  .buildEffect())
                .width(40)
                .onClick(async () => {
                  const documentViewPicker = new picker.DocumentViewPicker(this.context)
                  const uris = await documentViewPicker.select()
                  if (uris.length > 0) {
                    this.dialogControllerProgress.open()
                    try {
                      for (let i = 0; i < uris.length; i++) {
                        const item = uris[i]
                        const srcFile = fileIo.openSync(item)
                        const destFilePath =
                          this.getPath() + '/' + decodeURIComponent(item.slice(item.lastIndexOf('/') + 1))
                        await fileIo.copyFile(srcFile.fd, destFilePath)
                        fileIo.closeSync(srcFile)
                      }
                      this.dialogControllerProgress.close()
                      await promptAction.openToast({
                        message: '上传成功'
                      })
                      await this.get()
                    } catch (err) {
                      this.dialogControllerProgress.close()
                      await promptAction.openToast({
                        message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                      })
                    }
                  }
                })
              }
            }
            if (this.copyMovePath) {
              Blank()
              Column() {
                Image($r('app.media.close'))
              }
              .bindTips('取消')
              .borderRadius(20)
              .height(40)
              .keyboardShortcut(FunctionKey.ESC, [])
              .padding(11)
              .stateStyles({
                normal: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .visualEffect(new hdsEffect.HdsEffectBuilder()
                .pointLight({
                  sourceType: hdsEffect.PointLightSourceType.SOFT,
                  illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
                })
                .buildEffect())
              .width(40)
              .onClick(() => {
                this.copyMovePath = ''
                this.remove = undefined
              })

              if (this.dirnames.length > 0) {
                Column() {
                  Image($r('app.media.confirm'))
                }
                .bindTips('确定')
                .borderRadius(20)
                .height(40)
                .margin({
                  left: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .visualEffect(new hdsEffect.HdsEffectBuilder()
                  .pointLight({
                    sourceType: hdsEffect.PointLightSourceType.SOFT,
                    illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
                  })
                  .buildEffect())
                .width(40)
                .onClick(async () => {
                  let text = ''
                  if (!this.remove) {
                    text = '复制'
                  }
                  if (this.remove) {
                    text = '移动'
                  }
                  this.dialogControllerProgress.open()
                  try {
                    const isDirectory = fileIo.statSync(this.copyMovePath).isDirectory()
                    if (!isDirectory) {
                      const destFilePath =
                        this.getPath() + '/' + this.copyMovePath.slice(this.copyMovePath.lastIndexOf('/') + 1)
                      if (!this.remove) {
                        await fileIo.copyFile(this.copyMovePath, destFilePath)
                      }
                      if (this.remove) {
                        await fileIo.moveFile(this.copyMovePath, destFilePath)
                      }
                    }
                    if (isDirectory) {
                      const destPath = this.getPath()
                      if (!this.remove) {
                        await fileIo.copyDir(this.copyMovePath, destPath)
                      }
                      if (this.remove) {
                        await fileIo.moveDir(this.copyMovePath, destPath)
                      }
                    }
                    this.dialogControllerProgress.close()
                    await promptAction.openToast({
                      message: text + '成功'
                    })
                    await this.get()
                  } catch (err) {
                    this.dialogControllerProgress.close()
                    await promptAction.openToast({
                      message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                    })
                  }
                  this.copyMovePath = ''
                  this.remove = undefined
                })
              }
            }
          }
          .margin({
            bottom: this.dirnames.length > 0 || this.copyMovePath ? $r('sys.float.ohos_id_elements_margin_vertical_m') :
              0
          })
          .width('100%')

          List() {
            if (this.fileArray.length === 0) {
              ListItem() {
                Text('无数据')
              }
              .width('100%')
            }
            ForEach(this.fileArray.filter(item => item.isdir), (item: FileItem, index) => {
              ListItem() {
                Column() {
                  if (index !== 0) {
                    Divider()
                      .padding({
                        left: 6,
                        right: 6
                      })
                  }
                  Row() {
                    Image($r('app.media.foldericon'))
                      .height(24)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                      .width(24)
                    Column() {
                      Text(item.name)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .width('85%')
                      Text(item.mtime !== -1 ? getTimeStringFromSecond(item.mtime) : '')
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

                    Image($r('app.media.right'))
                      .fillColor($r('sys.color.icon_fourth'))
                      .height(12)
                      .width(12)
                  }
                  .borderRadius(12)
                  .padding({
                    bottom: 12,
                    left: 6,
                    right: 5,
                    top: 12
                  })
                  .stateStyles({
                    normal: {
                      .backgroundColor($r('app.color.sheet_background'))
                    },
                    hovered: {
                      .backgroundColor($r('sys.color.interactive_hover'))
                    },
                    pressed: {
                      .backgroundColor($r('sys.color.interactive_pressed'))
                    }
                  })
                  .onClick(async () => {
                    this.dirnames.push(item.name)
                    await this.get()
                  })
                  .bindContextMenu(this.MenuBuilder(item), ResponseType.LongPress, {
                    hapticFeedbackMode: HapticFeedbackMode.AUTO
                  })
                  .bindContextMenu(this.MenuBuilder(item), ResponseType.RightClick, {
                    hapticFeedbackMode: HapticFeedbackMode.AUTO
                  })
                }
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              }
            })
            ForEach(this.fileArray.filter(item => !item.isdir), (item: FileItem, index) => {
              ListItem() {
                Column() {
                  if (this.fileArray.find(item => item.isdir) || index !== 0) {
                    Divider()
                      .padding({
                        left: 6,
                        right: 6
                      })
                  }
                  Row() {
                    Image(getFileTypeIcon(item.name))
                      .height(24)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                      .width(24)
                    Column() {
                      Text(item.name)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .width('85%')
                      Text() {
                        Span(item.mtime !== -1 ? getTimeStringFromSecond(item.mtime) : '')
                        Span(item.size !== -1 ? ' - ' + getSizeString(item.size) : '')
                      }
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

                    Image($r('app.media.right'))
                      .fillColor($r('sys.color.icon_fourth'))
                      .height(12)
                      .width(12)
                  }
                  .borderRadius(12)
                  .padding({
                    bottom: 12,
                    left: 6,
                    right: 5,
                    top: 12
                  })
                  .stateStyles({
                    normal: {
                      .backgroundColor($r('app.color.sheet_background'))
                    },
                    hovered: {
                      .backgroundColor($r('sys.color.interactive_hover'))
                    },
                    pressed: {
                      .backgroundColor($r('sys.color.interactive_pressed'))
                    }
                  })
                  .onClick(async () => {
                    const uri = fileUri.getUriFromPath(item.path)
                    const canPreview = await filePreview.canPreview(this.context, uri)
                    if (!canPreview) {
                      await this.context.startAbility({
                        action: 'ohos.want.action.viewData',
                        uri: uri,
                        parameters: {
                          'ohos.ability.params.showDefaultPicker': true
                        },
                        flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
                      })
                    }
                    if (canPreview) {
                      await filePreview.openPreview(this.context, {
                        title: item.name,
                        uri: uri,
                        mimeType: ''
                      })
                    }
                  })
                  .bindContextMenu(this.MenuBuilder(item), ResponseType.LongPress, {
                    hapticFeedbackMode: HapticFeedbackMode.AUTO
                  })
                  .bindContextMenu(this.MenuBuilder(item), ResponseType.RightClick, {
                    hapticFeedbackMode: HapticFeedbackMode.AUTO
                  })
                }
                .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              }
            })
            ListItem()
              .margin({
                bottom: 28
              })
          }
          .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          top: 64
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
          mainTitle: '沙箱文件管理器'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      this.preferType = getPreferType(this.UIContext)
      this.context.eventHub.on('refreshSandboxfilelist', async () => {
        await this.get()
      })
      await this.get()
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshSandboxfilelist')
    })
    .bindSheet(this.isShowRenamesandboxfileSheet!!, this.RenamesandboxfileSheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      preferType: this.preferType,
      title: {
        title: '重命名'
      },
      onDisappear: () => {
        this.editPath = ''
      }
    })
  }
}