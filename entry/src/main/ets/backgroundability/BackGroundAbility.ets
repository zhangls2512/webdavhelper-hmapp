import { UIAbility } from '@kit.AbilityKit'
import { commonEventManager } from '@kit.BasicServicesKit'

export default class BackGroundAbility extends UIAbility {
  onPrepareToTerminate(): boolean {
    commonEventManager.publish('BACKGROUNDABILITY_EVENT_PREPARETOTERMINATE', {
      bundleName: 'com.zhuzx.webdavhelper'
    }, () => {
    })
    return false
  }
}