@ComponentV2
export default struct Player {
  @Consumer() isShowPlayerSheet: boolean = false
  @Param src: string = ''
  @Local progressRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @Local progressRateIndex: number = 1
  @Local progressRateValue: string = '1x'
  @Local muted: boolean = false
  @Local loop: boolean = false

  build() {
    List() {
      ListItem() {
        //用AVPlayer实现
      }
      .height('30%')

      ListItem() {
        Column() {
          Row() {
            Text('倍速')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Select([
              { value: '0.75x' },
              { value: '1x' },
              { value: '1.25x' },
              { value: '1.75x' },
              { value: '2x' }
            ])
              .selected(this.progressRateIndex!!)
              .value(this.progressRateValue!!)
              .onSelect((index) => {
                if (index === 0) {
                  this.progressRate = PlaybackSpeed.Speed_Forward_0_75_X
                }
                if (index === 1) {
                  this.progressRate = PlaybackSpeed.Speed_Forward_1_00_X
                }
                if (index === 2) {
                  this.progressRate = PlaybackSpeed.Speed_Forward_1_25_X
                }
                if (index === 3) {
                  this.progressRate = PlaybackSpeed.Speed_Forward_1_75_X
                }
                if (index === 4) {
                  this.progressRate = PlaybackSpeed.Speed_Forward_2_00_X
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
            Text('静音')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Toggle({
              type: ToggleType.Switch,
              isOn: this.muted!!
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
            Text('循环')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Toggle({
              type: ToggleType.Switch,
              isOn: this.loop!!
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
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
  }
}