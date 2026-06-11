import { UIAbility } from '@kit.AbilityKit'
import { commonEventManager } from '@kit.BasicServicesKit'

export default class BackgroundAbility extends UIAbility {
  onDestroy() {
    commonEventManager.publish('BACKGROUNDABILITY_EVENT_DESTROY', {
      bundleName: 'com.zhuzx.webdavhelper'
    }, () => {
    })
  }
}