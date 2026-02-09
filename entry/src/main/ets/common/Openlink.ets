import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'

export default async function openLink(context: common.UIAbilityContext, link: string) {
  const commonSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'commonSetting'
  })
  const openLinkType = commonSettingDataPreferences.getSync('openLinkType', 0)
  if (openLinkType === 0) {
    await context.openLink(link)
  }
  if (openLinkType === 1) {
    await context.openLink(link, {
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    })
  }
}