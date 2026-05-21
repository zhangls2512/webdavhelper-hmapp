import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit'

export function getPermission(permission: Permissions) {
  const atManager = abilityAccessCtrl.createAtManager()
  const status = atManager.getSelfPermissionStatus(permission)
  if (status === abilityAccessCtrl.PermissionStatus.GRANTED) {
    return true
  }
  return false
}

export async function checkPermission(context: Context, UIContext: UIContext, permission: Permissions) {
  const atManager = abilityAccessCtrl.createAtManager()
  const status = atManager.getSelfPermissionStatus(permission)
  if (status === abilityAccessCtrl.PermissionStatus.GRANTED) {
    return true
  }
  if (status === abilityAccessCtrl.PermissionStatus.NOT_DETERMINED) {
    const res = await atManager.requestPermissionsFromUser(context, [permission])
    const authResult = res.authResults[0]
    if (authResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true
    }
  }
  if (status === abilityAccessCtrl.PermissionStatus.DENIED) {
    const res = await atManager.requestPermissionOnSetting(context, [permission])
    const authResult = res[0]
    if (authResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true
    }
  }
  const promptAction = UIContext.getPromptAction()
  await promptAction.showDialog({
    title: '提示',
    message: '请允许授权以使用此功能',
    buttons: [
      {
        text: '确定',
        color: $r('sys.color.font_emphasize')
      }
    ]
  })
  return false
}