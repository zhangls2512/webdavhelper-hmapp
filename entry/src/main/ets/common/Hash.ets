import { util } from '@kit.ArkTS'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'

export function sha256hash(data: string) {
  const md = cryptoFramework.createMd('SHA256')
  md.updateSync({
    data: new util.TextEncoder().encodeInto(data)
  })
  return Array.from(md.digestSync().data).map(byte => byte.toString(16).padStart(2, '0')).join('')
}