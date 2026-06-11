import { AccountInfo, getAccountList } from './Account'
import { read, write } from './File'

interface FavouritePathItem {
  accountId: string,
  path: string
}

export interface FavouritePath {
  accountId: string,
  accountInfo: AccountInfo,
  path: string,
  name: string
}

export async function newFavouritePath(context: Context, accountId: string, path: string) {
  const filePath = context.filesDir + '/favouritepath.txt'
  const res = await read(filePath, true)
  if (res !== 'fail') {
    const array = JSON.parse(res) as FavouritePathItem[]
    const exist = array.find(item => accountId === item.accountId && path === item.path)
    if (!exist) {
      array.push({
        accountId: accountId,
        path: path
      })
      await write(filePath, JSON.stringify(array))
      return 'success'
    }
  }
  if (res === 'fail') {
    await write(filePath, JSON.stringify([{
      accountId: accountId,
      path: path
    }]))
    return 'success'
  }
  return 'fail'
}

export async function getFavouritePathList(context: Context) {
  const res = await read(context.filesDir + '/favouritepath.txt', true)
  if (res !== 'fail') {
    const result: FavouritePath[] = []
    const array = JSON.parse(res) as FavouritePathItem[]
    const accountArray = await getAccountList(context)
    array.forEach(item => {
      const accountInfo = accountArray.find(inItem => inItem.id === item.accountId)
      if (accountInfo) {
        result.push({
          accountId: item.accountId,
          accountInfo: accountInfo,
          path: item.path,
          name: item.path.substring(item.path.lastIndexOf('/') + 1)
        })
      }
    })
    return result
  }
  return []
}

export async function deleteFavouritePath(context: Context, accountId: string, path: string) {
  const filePath = context.filesDir + '/favouritepath.txt'
  const res = await read(filePath, true)
  if (res !== 'fail') {
    const array = JSON.parse(res) as FavouritePathItem[]
    const index = array.findIndex(item => accountId === item.accountId && path === item.path)
    if (index !== -1) {
      array.splice(index, 1)
      await write(filePath, JSON.stringify(array))
    }
  }
}