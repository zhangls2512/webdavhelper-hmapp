import { common } from '@kit.AbilityKit'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { read, write } from '../common/File'

export interface AddressGroupItem {
  name: string,
  list: string[]
}

@Builder
export function AddressgroupBuilder() {
  Addressgroup()
}

@ComponentV2
struct Addressgroup {
  @Local addressGroup: AddressGroupItem[] = []
  @Local addressGroupName: string = ''
  @Local addressGroupListItemInput: string[] = []
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Text('系统认为同一地址组内的多个地址对应相同的服务器，用于自动选择最佳地址加速网络连接。建议将同一服务器的公网、内网地址添加到同一地址组。')
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            TextInput({
              placeholder: '请输入地址组名称',
              text: this.addressGroupName!!
            })
              .enableAutoSpacing(true)
            Button('添加')
              .enabled(this.addressGroupName !== '' ? true : false)
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
              .onClick(async () => {
                if (this.addressGroup.find(item => item.name === this.addressGroupName)) {
                  await promptAction.openToast({
                    message: '名称已存在'
                  })
                  return
                }
                this.addressGroup.push({
                  name: this.addressGroupName,
                  list: []
                })
                this.addressGroupListItemInput.push('')
                await write(this.context.filesDir + '/addressgroup.txt', JSON.stringify(this.addressGroup))
                this.addressGroupName = ''
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ForEach(this.addressGroup, (item: AddressGroupItem, index) => {
          ListItem() {
            Row() {
              Text(item.name)
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Button('删除')
                .role(ButtonRole.ERROR)
                .onClick(async () => {
                  this.addressGroup.splice(index, 1)
                  this.addressGroupListItemInput.splice(index, 1)
                  await write(this.context.filesDir + '/addressgroup.txt', JSON.stringify(this.addressGroup))
                })
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_l')
          })

          ListItem() {
            Column() {
              TextInput({
                placeholder: '请输入地址',
                text: this.addressGroupListItemInput[index]!!
              })
                .enableAutoSpacing(true)
              Button('添加')
                .enabled(this.addressGroupListItemInput[index] !== '' ? true : false)
                .margin({
                  top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                })
                .width('100%')
                .onClick(async () => {
                  if (Array.from(new Set(this.addressGroup.flatMap(item => item.list)))
                    .find(item => item === this.addressGroupListItemInput[index])) {
                    await promptAction.openToast({
                      message: '地址已存在'
                    })
                    return
                  }
                  const addressGroup = [...this.addressGroup]
                  addressGroup[index].list.push(this.addressGroupListItemInput[index])
                  this.addressGroup = addressGroup
                  await write(this.context.filesDir + '/addressgroup.txt', JSON.stringify(this.addressGroup))
                  this.addressGroupListItemInput[index] = ''
                })
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })

          ForEach(item.list, (listItem: string, listIndex) => {
            ListItem() {
              Column() {
                Row() {
                  Text(listItem)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Image($r('app.media.delete'))
                    .height(24)
                    .onClick(async () => {
                      const addressGroup = [...this.addressGroup]
                      addressGroup[index].list.splice(listIndex, 1)
                      this.addressGroup = addressGroup
                      await write(this.context.filesDir + '/addressgroup.txt', JSON.stringify(this.addressGroup))
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              .padding($r('sys.float.ohos_id_corner_radius_mark'))
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          })
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
          mainTitle: '地址组'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      const filestring = await read(this.context.filesDir + '/addressgroup.txt', true)
      if (filestring !== 'fail') {
        this.addressGroup = JSON.parse(filestring)
      }
    })
  }
}