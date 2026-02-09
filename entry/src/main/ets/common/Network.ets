import { connection } from '@kit.NetworkKit'

export function getCurrentNetworkBearerType() {
  const netHandle = connection.getDefaultNetSync()
  if (netHandle.netId !== 0) {
    return connection.getNetCapabilitiesSync(netHandle).bearerTypes[0]
  } else {
    return -1
  }
}