import { getSizeString } from '../common/Stringformat'

@ComponentV2
export default struct Progresssheet {
  @Consumer() isShowProgressSheet: boolean = false
  @Consumer() transferredSize: number = 0
  @Consumer() totalSize: number = 0
  @Local oneSecondTransferredSize: number = 0
  oneSecondBeforeTransferredSize = 0
  intervalId = -1

  getSizeString(size: number) {
    if (size < Math.pow(1024, 1)) {
      return size + ' B'
    }
    if (size >= Math.pow(1024, 1) && size < Math.pow(1024, 2)) {
      return (size / Math.pow(1024, 1)).toFixed(2) + ' KB'
    }
    if (size >= Math.pow(1024, 2) && size < Math.pow(1024, 3)) {
      return (size / Math.pow(1024, 2)).toFixed(2) + ' MB'
    }
    if (size >= Math.pow(1024, 3) && size < Math.pow(1024, 4)) {
      return (size / Math.pow(1024, 3)).toFixed(2) + ' GB'
    }
    if (size >= Math.pow(1024, 4)) {
      return (size / Math.pow(1024, 4)).toFixed(2) + ' TB'
    }
    return ''
  }

  build() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Progress({
              value: Number((this.transferredSize / this.totalSize).toFixed(2)) * 100,
              total: 100,
              type: ProgressType.Ring
            })
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .width(40)
            Column() {
              Text('进度：' + Number((this.transferredSize / this.totalSize).toFixed(2)) * 100 + '%')
                .fontWeight(FontWeight.Medium)
              Text(getSizeString(this.transferredSize) + '/' + getSizeString(this.totalSize) + ' (' +
                getSizeString(this.oneSecondTransferredSize) + '/s)')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .margin({
                  top: $r('sys.float.ohos_id_text_margin_vertical')
                })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }

          Button('取消')
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_l')
            })
            .role(ButtonRole.ERROR)
            .width('100%')
            .onClick(async () => {
              const promptAction = this.getUIContext().getPromptAction()
              const data = await promptAction.showDialog({
                title: '提示',
                message: '取消会导致已下载到本地的文件不完整，确定取消？',
                buttons: [
                  {
                    text: '取消',
                    color: $r('sys.color.font_primary')
                  },
                  {
                    text: '确定',
                    color: $r('sys.color.warning')
                  }
                ]
              })
              if (data.index === 1) {
                this.isShowProgressSheet = false
              }
            })
        }
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
    .onAppear(() => {
      this.intervalId = setInterval(() => {
        this.oneSecondTransferredSize = this.transferredSize - this.oneSecondBeforeTransferredSize
        this.oneSecondBeforeTransferredSize = this.transferredSize
      }, 1000)
    })
    .onDisAppear(() => {
      if (this.intervalId !== -1) {
        clearInterval(this.intervalId)
      }
    })
  }
}