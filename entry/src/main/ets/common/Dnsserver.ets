import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'

export function getDnsServer(context: Context) {
  const debugSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'debugSetting'
  })
  const ip = debugSettingDataPreferences.getSync('dnsserverip', '')
  if (!ip) {
    return undefined
  } else {
    return [{
      ip: ip,
      port: debugSettingDataPreferences.getSync('dnsserverport', 53)
    }] as rcp.DnsServers
  }
}