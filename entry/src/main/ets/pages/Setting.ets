import { common } from '@kit.AbilityKit'
import { privacyManager } from '@kit.AppGalleryKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { appAccount } from '@kit.BasicServicesKit'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { formProvider } from '@kit.FormKit'
import { harmonyShare, systemShare } from '@kit.ShareKit'
import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { getAccountInfo, getAccountList, getLoginStatus, importAccounts } from '../common/Account'
import { write, writeUri } from '../common/File'
import openLink from '../common/Openlink'
import { checkPermission } from '../common/Permission'
import { getFlushPreference } from '../common/Preference'
import { getSizeString } from '../common/Stringformat'
import { Param } from './Webview'

@ComponentV2
export default struct Setting {
  @Local allService: boolean = false
  @Local agreedPrivacyAgreement: number | undefined = undefined
  @Local accountDataSyncEnabled: boolean = false
  @Local isLogin: boolean = false
  @Local accountCount: number = -1
  @Local accountDataSync: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()

  async getSetting() {
    this.allService = getFlushPreference(this.context, 'commonSetting', 'allService', true) as boolean
    try {
      const appPrivacyResults: privacyManager.AppPrivacyResult[] = privacyManager.getAppPrivacyResult()
      this.agreedPrivacyAgreement =
        appPrivacyResults.find(item => item.type === privacyManager.AppPrivacyType.PRIVACY_AGREEMENT)?.result
    } catch (err) {
      await promptAction.openToast({
        message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
      })
    }
    this.isLogin = await getLoginStatus(this.context)
    if (this.isLogin) {
      const accountInfo = await getAccountInfo(this.context)
      const appAccountManager = appAccount.createAppAccountManager()
      const res = await checkPermission(this.context, this.UIContext, 'ohos.permission.DISTRIBUTED_DATASYNC')
      this.accountDataSyncEnabled = res
      if (this.accountDataSyncEnabled) {
        this.accountDataSync = await appAccountManager.checkDataSyncEnabled(accountInfo.id)
      }
    }
    const accounts = await getAccountList(this.context)
    this.accountCount = accounts.length
  }

  build() {
    HdsNavigation(this.pageInfos) {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Text('账号')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              if (this.isLogin) {
                Row() {
                  Text('设备间同步')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.accountDataSync!!
                  })
                    .enabled(this.accountDataSyncEnabled)
                    .onChange(async (isOn) => {
                      try {
                        const accountInfo = await getAccountInfo(this.context)
                        const appAccountManager = appAccount.createAppAccountManager()
                        await appAccountManager.setDataSyncEnabled(accountInfo.id, isOn)
                      } catch (err) {
                        this.accountDataSync = false
                        await promptAction.openToast({
                          message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)

                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
              }
              if (this.accountCount === 0) {
                Row() {
                  Text('导入')
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
                    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                  },
                  hovered: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .onClick(async () => {
                  const documentSelectOptions = new picker.DocumentSelectOptions()
                  documentSelectOptions.maxSelectNumber = 1
                  documentSelectOptions.fileSuffixFilters = ['.txt']
                  const documentViewPicker = new picker.DocumentViewPicker(this.context)
                  const uris = await documentViewPicker.select(documentSelectOptions)
                  if (uris.length === 1) {
                    const uri = uris[0]
                    await importAccounts(this.context, uri)
                    await this.getSetting()
                    this.context.eventHub.emit('refreshMe')
                  }
                })

                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
              }
              Row() {
                Text('导出')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(async () => {
                const documentSaveOptions = new picker.DocumentSaveOptions()
                documentSaveOptions.newFileNames = ['webdavhelperaccounts']
                documentSaveOptions.fileSuffixChoices = ['.txt']
                const documentViewPicker = new picker.DocumentViewPicker(this.context)
                const uris = await documentViewPicker.save(documentSaveOptions)
                if (uris.length === 1) {
                  const filePath = uris[0]
                  const array = await getAccountList(this.context)
                  await writeUri(filePath, JSON.stringify(array))
                  await promptAction.openToast({
                    message: '导出成功'
                  })
                }
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('碰一碰/隔空传送同步到邻近设备')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(async () => {
                const array = await getAccountList(this.context)
                const filePath = this.context.tempDir + '/webdavhelperaccounts.txt'
                await write(filePath, JSON.stringify(array))
                const shareData = new systemShare.SharedData({
                  utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
                  title: 'webdavhelperaccounts.txt',
                  description: getSizeString(fileIo.statSync(filePath).size),
                  uri: fileUri.getUriFromPath(filePath)
                })
                harmonyShare.on('knockShare', async (sharableTarget) => {
                  await sharableTarget.share(shareData)
                })
                harmonyShare.on('gesturesShare', async (sharableTarget) => {
                  await sharableTarget.share(shareData)
                })
                const promptAction = this.UIContext.getPromptAction()
                await promptAction.showDialog({
                  title: '提示',
                  message: '碰一碰/隔空传送邻近设备即可同步，关闭此弹窗后停止同步',
                  buttons: [
                    {
                      text: '关闭',
                      color: $r('sys.color.warning')
                    }
                  ],
                  onDidDisappear: async () => {
                    await fileIo.unlink(filePath)
                    harmonyShare.off('knockShare')
                    harmonyShare.off('gesturesShare')
                  }
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('地址组')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Addressgroup'
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
            Text('通用')
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
                Text('通用')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Commonsetting'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('卡片')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                formProvider.openFormManager({
                  bundleName: 'com.zhuzx.webdavhelper'
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
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Row() {
              Text('消息通知')
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
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              },
              hovered: {
                .backgroundColor($r('sys.color.interactive_hover'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              }
            })
            .onClick(() => {
              this.context.eventHub.emit('notice')
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
            Text('数据与隐私')
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
                Text('权限管理')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Permissionsetting'
                })
              })

              if (typeof (this.agreedPrivacyAgreement) === 'number') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
              }
              if (this.agreedPrivacyAgreement === 0 || this.agreedPrivacyAgreement === 2) {
                Row() {
                  if (this.agreedPrivacyAgreement === 0 || this.agreedPrivacyAgreement === 2) {
                    Text('阅读并签署隐私协议')
                      .fontColor($r('sys.color.font_emphasize'))
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)
                      .margin({
                        right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                      })
                  }
                  Image($r('app.media.right'))
                    .fillColor($r('sys.color.icon_fourth'))
                    .height(12)
                    .width(12)
                }
                .borderRadius(12)
                .padding(12)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                  },
                  hovered: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .onClick(async () => {
                  await privacyManager.requestAppPrivacyConsent(this.context)
                  await this.getSetting()
                })
              }
              if (this.agreedPrivacyAgreement === 1) {
                Row() {
                  Text('撤回同意隐私协议')
                    .fontColor($r('sys.color.warning'))
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
                    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                  },
                  hovered: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .onClick(async () => {
                  privacyManager.disableService()
                  await this.context.terminateSelf()
                })
              }
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
            Text('了解我们如何使用您的数据')
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
                Text('业务与隐私的声明')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(async () => {
                try {
                  const appPrivacyLink = privacyManager.getAppPrivacyMgmtInfo().privacyInfo
                    .find(item => item.type === privacyManager.AppPrivacyLinkType.PRIVACY_STATEMENT_LINK)
                  this.pageInfos.pushPath({
                    name: 'Webview',
                    param: {
                      url: appPrivacyLink?.url,
                      trust: false
                    } as Param
                  })
                } catch (err) {
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                  })
                }
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('第三方SDK列表')
                  .enableAutoSpacing(true)
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(async () => {
                await openLink(this.context, 'https://docs.qq.com/doc/p/c2689c9cff59261fe4d102415fc6910394efad0b')
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('已收集个人信息清单')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Infolist'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('隐私声明摘要')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(async () => {
                await openLink(this.context, 'https://docs.qq.com/doc/p/e047630338229f7a0114ffa89a6070f66c3d9262')
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
                Text('应用服务模式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(this.allService ? '全量模式' : '基本模式')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Servicemode'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('其他')
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
                  .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                },
                hovered: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Moresetting'
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
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Row() {
              Text('关于')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text('版本 ')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
              Text($r('app.string.app_version'))
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
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              },
              hovered: {
                .backgroundColor($r('sys.color.interactive_hover'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              }
            })
            .onClick(() => {
              this.pageInfos.pushPath({
                name: 'About'
              })
            })

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('服务协议与规则')
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
                .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              },
              hovered: {
                .backgroundColor($r('sys.color.interactive_hover'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              }
            })
            .onClick(() => {
              this.pageInfos.pushPath({
                name: 'Agreements'
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
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
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
          mainTitle: '设置'
        }
      }
    })
    .titleMode(HdsNavigationTitleMode.MODAL)
    .onAppear(async () => {
      this.context.eventHub.on('refreshSetting', async () => {
        await this.getSetting()
      })
      await this.getSetting()
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshSetting')
    })
  }
}