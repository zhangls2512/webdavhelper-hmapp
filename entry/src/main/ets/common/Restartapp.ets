import { common, Want } from '@kit.AbilityKit'

export async function restartApp(context: common.UIAbilityContext, UIContext: UIContext) {
  const want: Want = {
    bundleName: 'com.zhuzx.webdavhelper',
    abilityName: 'EntryAbility'
  }
  const promptAction = UIContext.getPromptAction()
  const data = await promptAction.showActionMenu({
    title: '是否保留应用窗口？',
    buttons: [
      {
        text: '是',
        color: $r('sys.color.font_primary')
      },
      {
        text: '否',
        color: $r('sys.color.font_primary')
      }
    ]
  })
  if (data.index === 0) {
    await context.restartApp(want)
  }
  if (data.index === 1) {
    context.getApplicationContext().restartApp(want)
  }
}