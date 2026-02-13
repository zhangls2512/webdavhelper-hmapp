import { common } from '@kit.AbilityKit'
import { bookParser, readerCore, ReadPageComponent } from '@kit.ReaderKit'

@ComponentV2
export default struct Reader {
  @Param src: string = ''
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  readerComponentController = new readerCore.ReaderComponentController()

  build() {
    Column() {
      ReadPageComponent({
        controller: this.readerComponentController
      })
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
    .onAppear(async () => {
      const bookParserHandler = await bookParser.getDefaultHandler(this.src)
      await this.readerComponentController.init(this.context)
      this.readerComponentController.registerBookParser(bookParserHandler)
      await this.readerComponentController.startPlay(0, '')
    })
    .onDisAppear(() => {
      this.readerComponentController.releaseBook()
    })
  }
}