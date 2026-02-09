import { UIAbility } from '@kit.AbilityKit'
import { commonEventManager } from '@kit.BasicServicesKit'

export default class BackGroundAbility extends UIAbility {
  async onCreate() {
    const subscriber = commonEventManager.createSubscriberSync({
      events: ['ENTRYABILITY_EVENT_REQUESTTERMINATEBACKGROUNDABILITY']
    })
    await commonEventManager.subscribeToEvent(subscriber, async (data) => {
      if (data.event === 'ENTRYABILITY_EVENT_REQUESTTERMINATEBACKGROUNDABILITY') {
        await this.context.terminateSelf()
      }
    })
  }

  onPrepareToTerminate(): boolean {
    commonEventManager.publish('BACKGROUNDABILITY_EVENT_PREPARETOTERMINATE', {
      bundleName: 'com.zhuzx.webdavhelper'
    }, () => {
    })
    return false
  }
}