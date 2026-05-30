import { UIAbility } from '@kit.AbilityKit'
import { commonEventManager } from '@kit.BasicServicesKit'

export default class BackgroundAbility extends UIAbility {
  onPrepareToTerminate() {
    commonEventManager.publish('BACKGROUNDABILITY_EVENT_PREPARETOTERMINATE', {
      bundleName: 'com.zhuzx.webdavhelper'
    }, () => {
    })
    return false
  }
}