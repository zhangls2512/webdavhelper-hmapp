import { rcp } from '@kit.RemoteCommunicationKit'
import { getFlushPreference } from './Preference'

export function getDnsServer(context: Context) {
  const ip = getFlushPreference(context, 'debugSetting', 'dnsserverip', '')
  if (!ip) {
    return undefined
  } else {
    return [{
      ip: ip,
      port: getFlushPreference(context, 'debugSetting', 'dnsserverport', 53)
    }] as rcp.DnsServers
  }
}