import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { display, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { getPreferType } from '../common/Prefertype'
import { getSizeString } from '../common/Stringformat'
import { TransferTaskItem } from './Index'

@ComponentV2
export default struct Transfer {
  @Local selectedIndex: number = 0
  @Local transferTaskArray: TransferTaskItem[] = []
  @Local preferType: number = 1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  intervalId = -1

  build() {
    Scroll() {
      Column() {
        TabSegmentButtonV2({
          items: new SegmentButtonV2Items([
            { text: '下载' },
            { text: '上传' }
          ]),
          selectedIndex: this.selectedIndex!!
        })
          .margin({
            bottom: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        List() {
          if (this.selectedIndex === 0) {
            if (this.transferTaskArray.filter(item => item.type === 'download').length === 0) {
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
                ForEach(this.transferTaskArray.filter(item => item.type === 'download'),
                  (item: TransferTaskItem, index) => {
                    if (index !== 0) {
                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                    }
                    Column() {
                      Text(item.name)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .width('85%')
                      if (item.status === 'pending') {
                        Text('等待中')
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'processing') {
                        Text(Number((item.transferredSize / item.totalSize).toFixed(2)) * 100 + '%(' +
                          getSizeString(item.transferredSize) + '/' + getSizeString(item.totalSize) + ')')
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'success') {
                        Text('完成')
                          .fontColor(Color.Green)
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'fail') {
                        Text('失败，错误码：' + item.errCode)
                          .fontColor($r('sys.color.warning'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'cancel') {
                        Text('取消')
                          .fontColor($r('sys.color.warning'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
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
            if (this.transferTaskArray.filter(item => item.type === 'upload').length === 0) {
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
                ForEach(this.transferTaskArray.filter(item => item.type === 'upload'),
                  (item: TransferTaskItem, index) => {
                    if (index !== 0) {
                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                    }
                    Column() {
                      Text(item.name)
                        .enableAutoSpacing(true)
                        .fontWeight(FontWeight.Medium)
                        .width('85%')
                      if (item.status === 'pending') {
                        Text('等待中')
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'processing') {
                        Text(Number((item.transferredSize / item.totalSize).toFixed(2)) * 100 + '%(' +
                          getSizeString(item.transferredSize) + '/' + getSizeString(item.totalSize) + ')')
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'success') {
                        Text('完成')
                          .fontColor(Color.Green)
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'fail') {
                        Text('失败，错误码：' + item.errCode)
                          .fontColor($r('sys.color.warning'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                      if (item.status === 'cancel') {
                        Text('取消')
                          .fontColor($r('sys.color.warning'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .margin({
                            top: $r('sys.float.ohos_id_text_margin_vertical')
                          })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
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
          ListItem()
            .margin({
              bottom: this.preferType === 0 ? 80 : 0
            })
        }
        .layoutWeight(1)
      }
    }
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      top: this.preferType === 0 ? 0 : $r('sys.float.ohos_id_default_padding_top')
    })
    .onAppear(() => {
      this.preferType = getPreferType(this.UIContext)
      display.on('change', () => {
        setTimeout(() => {
          this.preferType = getPreferType(this.UIContext)
        }, 200)
      })
      this.intervalId = setInterval(() => {
        const transferTaskArray: TransferTaskItem[] = []
        const transferTaskDataPreferences = preferences.getPreferencesSync(this.context, {
          name: 'transferTask'
        })
        const transferTaskObject = transferTaskDataPreferences.getAllSync() as object
        const transferTaskIdArray = Object.keys(transferTaskObject)
        transferTaskIdArray.forEach(item => {
          const transferTaskString = transferTaskObject[item] as string
          const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
          transferTaskArray.push(transferTask)
        })
        this.transferTaskArray = transferTaskArray
      }, 100)
    })
    .onDisAppear(() => {
      if (this.intervalId !== -1) {
        clearInterval(this.intervalId)
      }
      display.off('change')
    })
  }
}