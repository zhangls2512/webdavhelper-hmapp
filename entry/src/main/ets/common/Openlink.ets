import { common } from '@kit.AbilityKit'
import { getFlushPreference } from './Preference'

export default async function openLink(context: common.UIAbilityContext, link: string) {
  const openLinkType = getFlushPreference(context, 'commonSetting', 'openLinkType', 0)
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