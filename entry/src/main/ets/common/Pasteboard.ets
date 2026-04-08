import { promptAction } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'
import { getFlushPreference, setFlushPreference } from './Preference'

async function writePasteBoard(text: string) {
  const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
  const systemPasteboard = pasteboard.getSystemPasteboard()
  await systemPasteboard.setData(pasteData)
  await promptAction.openToast({
    message: '内容已复制到剪贴板'
  })
}

export default async function copy(context: Context, UIContext: UIContext, text: string) {
  const canWritePasteBoard = getFlushPreference(context, 'permissionSetting', 'writePasteBoard', false)
  if (canWritePasteBoard) {
    await writePasteBoard(text)
  }
  if (!canWritePasteBoard) {
    const promptAction = UIContext.getPromptAction()
    const data = await promptAction.showDialog({
      title: '允许“WebDAV 助手”写入剪贴板？',
      message: $r('app.string.WRITE_PASTEBOARD_reason'),
      buttons: [
        {
          text: '禁止',
          color: $r('sys.color.warning')
        },
        {
          text: '允许',
          color: $r('sys.color.font_emphasize')
        }
      ]
    })
    if (data.index === 1) {
      setFlushPreference(context, 'permissionSetting', 'writePasteBoard', true)
      await writePasteBoard(text)
    }
  }
}