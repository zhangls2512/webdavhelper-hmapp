@Entry
@Component
struct EntranceCard {
  build() {
    Row() {
      Column() {
        Image($r('app.media.file_form'))
          .height('50%')
        Text('文件')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Medium)
          .height('30%')
      }
      .width('50%')
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            shortcutId: 'file'
          }
        })
      })

      Column() {
        Image($r('app.media.transfer_form'))
          .height('50%')
        Text('传输')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Medium)
          .height('30%')
      }
      .width('50%')
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            shortcutId: 'transfer'
          }
        })
      })
    }
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .height('100%')
  }
}