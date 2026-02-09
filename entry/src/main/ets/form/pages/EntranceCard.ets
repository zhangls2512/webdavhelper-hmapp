@Entry
@Component
struct EntranceCard {
  build() {
    Row() {
      Image($r('app.media.file_form'))
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
      Image($r('app.media.transfer_form'))
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
  }
}