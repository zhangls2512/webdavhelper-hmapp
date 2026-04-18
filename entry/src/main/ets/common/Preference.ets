import { preferences } from '@kit.ArkData'
import { fileIo } from '@kit.CoreFileKit'

export interface PreferenceItem {
  name: string,
  kvs: KvItem[]
}

export interface KvItem {
  key: string,
  value: string
}

export function getTempPreference(context: Context, preference: string, key: string,
  defaultValue: preferences.ValueType) {
  const dataPreferences = preferences.getPreferencesSync(context, {
    name: preference
  })
  return dataPreferences.getSync(key, defaultValue)
}

export function setTempPreference(context: Context, preference: string, key: string, value: preferences.ValueType) {
  const dataPreferences = preferences.getPreferencesSync(context, {
    name: preference
  })
  dataPreferences.putSync(key, value)
}

export function getFlushPreference(context: Context, preference: string, key: string,
  defaultValue: preferences.ValueType) {
  const dataPreferences = preferences.getPreferencesSync(context, {
    name: preference,
    storageType: preferences.StorageType.GSKV
  })
  return dataPreferences.getSync(key, defaultValue)
}

export function setFlushPreference(context: Context, preference: string, key: string, value: preferences.ValueType) {
  const dataPreferences = preferences.getPreferencesSync(context, {
    name: preference,
    storageType: preferences.StorageType.GSKV
  })
  dataPreferences.putSync(key, value)
}

export function deleteFlushPreferenceKey(context: Context, preference: string, key: string) {
  const dataPreferences = preferences.getPreferencesSync(context, {
    name: preference,
    storageType: preferences.StorageType.GSKV
  })
  dataPreferences.deleteSync(key)
}

export async function getFlushPreferences(context: Context) {
  const filenames = await fileIo.listFile(context.preferencesDir)
  const names: string[] = []
  filenames.forEach(item => {
    if (item.endsWith('.db')) {
      names.push(item.replace('.db', ''))
    }
  })
  return names.map(name => {
    const dataPreferences = preferences.getPreferencesSync(context, {
      name: name,
      storageType: preferences.StorageType.GSKV
    })
    const kvsobject = dataPreferences.getAllSync() as object
    return {
      name: name,
      kvs: Object.keys(kvsobject).map(key => {
        return {
          key: key,
          value: kvsobject[key]
        } as KvItem
      })
    } as PreferenceItem
  })
}