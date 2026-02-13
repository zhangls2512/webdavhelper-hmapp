import { common, wantConstant } from '@kit.AbilityKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { filePreview } from '@kit.PreviewKit'
import { systemShare } from '@kit.ShareKit'
import { HdsNavDestination } from '@kit.UIDesignKit'
import { getFileTypeIcon } from '../common/File'
import { getTimeString, getSizeString } from '../common/Stringformat'

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
  @Local fileArray: FileItem[] = []
  @Local dirnames: string[] = []
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  getPath() {
    let path = ''
    this.dirnames.forEach((item, index) => {
      if (index !== 0) {
        path += '/' + item
      }
      if (index === 0) {
        if (item === 'bundle') {
          path += this.context.bundleCodeDir
        }
        if (item === 'base') {
          path += this.context.tempDir.slice(0, -5)
        }
        if (item === 'database') {
          path += this.context.databaseDir
        }
        if (item === 'distributedfiles') {
          path += this.context.distributedFilesDir
        }
        if (item === 'preferences') {
          path += this.context.preferencesDir
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
          path: this.context.bundleCodeDir,
          name: 'bundle',
          isdir: true,
          size: -1,
          mtime: -1
        },
        {
          path: this.context.tempDir.slice(0, -5),
          name: 'base',
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
        },
        {
          path: this.context.preferencesDir,
          name: 'preferences',
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
        const promises = files.map(item => {
          const itemPath = path + '/' + item
          const isDir = fileIo.statSync(itemPath).isDirectory()
          if (!isDir) {
            this.fileArray.push({
              path: itemPath,
              name: item,
              isdir: false,
              size: fileIo.statSync(itemPath).size,
              mtime: fileIo.statSync(itemPath).mtime
            })
          }
          if (isDir) {
            this.fileArray.push({
              path: itemPath,
              name: item,
              isdir: true,
              size: -1,
              mtime: -1
            })
          }
        })
        await Promise.all(promises)
      } catch (err) {
        if (err.code !== 13900012) {
          await promptAction.openToast({
            message: '发生错误，错误码：' + err.code
          })
        }
        if (err.code === 13900012) {
          await promptAction.openToast({
            message: '无权限'
          })
        }
        this.dirnames.pop()
        await this.get()
      }
    }
  }

  @Builder
  MenuBuilder(item: FileItem) {
    Menu() {
      if (!item.isdir) {
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
              if (err.code !== 13900012) {
                await promptAction.openToast({
                  message: '发生错误，错误码：' + err.code
                })
              }
              if (err.code === 13900012) {
                await promptAction.openToast({
                  message: '无权限'
                })
              }
            }
          }
        })
    }
  }

  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          if (this.dirnames.length > 0) {
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
          }
          List() {
            if (this.fileArray.length === 0) {
              ListItem() {
                Text('无数据')
              }
              .width('100%')
            }
            ForEach(this.fileArray, (item: FileItem, index) => {
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
                    if (!item.isdir) {
                      Image(getFileTypeIcon(item.name))
                        .fillColor($r('sys.color.icon_secondary'))
                        .height(24)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                        .width(24)
                    }
                    if (item.isdir) {
                      Image($r('app.media.foldericon'))
                        .height(24)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                        .width(24)
                    }
                    Column() {
                      Text(item.name)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .width('85%')
                      Text() {
                        Span(item.mtime !== -1 ? getTimeString(item.mtime) : '')
                        if (!item.isdir) {
                          Span(item.size !== -1 ? ' - ' + getSizeString(item.size) : '')
                        }
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
                      .backgroundColor(this.hoverId === index ? $r('sys.color.interactive_hover') :
                        $r('app.color.sheet_background'))
                    },
                    pressed: {
                      .backgroundColor($r('sys.color.comp_background_secondary'))
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
                    if (!item.isdir) {
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
                    }
                    if (item.isdir) {
                      this.dirnames.push(item.name)
                      await this.get()
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
          }
          .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
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
          mainTitle: '沙箱文件管理器'
        }
      },
      enableComponentSafeArea: true
    })
    .onAppear(async () => {
      await this.get()
    })
  }
}