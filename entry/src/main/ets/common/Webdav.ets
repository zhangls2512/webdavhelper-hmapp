import { getAccountAuthorization, getAccountInfo } from './Account'
import { webdavRequest } from './Request'

export interface FileItem {
  path: string,
  name: string,
  isdir: boolean,
  size: number,
  modifyTime: number,
  type: string
}

export function encodePath(path: string) {
  return decodeURIComponent(path).split('/').map(item => encodeURIComponent(item)).join('/')
}

export async function ls(context: Context, path: string) {
  const res = await webdavRequest(context, encodePath(path), 'PROPFIND', {
    Authorization: await getAccountAuthorization(context),
    Depth: '1'
  })
  if (res !== 'fail') {
    const files: FileItem[] = []
    Array.from(res.matchAll(/<[^:]+:response[^>]*>([\s\S]*?)<\/[^:]+:response>/g))
      .map(item => item[1])
      .forEach((item, index) => {
        const hrefMatch = item.match(/<[^:]+:href[^>]*>(.*?)<\/[^:]+:href>/)
        if (hrefMatch && index !== 0) {
          const isdir = /<[^:]+:collection\b[^>]*\/?>/.test(item)
          let size = -1
          if (!isdir) {
            const sizeMatch = item.match(/<[^:]+:getcontentlength[^>]*>(\d+)<\/[^:]+:getcontentlength>/)
            if (sizeMatch) {
              size = Number(sizeMatch[1])
            }
          }
          const modifyTimeMatch = item.match(/<[^:]+:getlastmodified[^>]*>(.*?)<\/[^:]+:getlastmodified>/)
          if (modifyTimeMatch) {
            const name = hrefMatch[1].replace(/^\/+|\/+$/g, '')
            files.push({
              path: name,
              name: decodeURIComponent(name.substring(name.lastIndexOf('/') + 1)),
              isdir: isdir,
              size: size,
              modifyTime: Date.parse(modifyTimeMatch[1]),
              type: name.substring(name.lastIndexOf('.') + 1)
            })
          }
        }
      })
    return files
  }
  return []
}

export async function mkdir(context: Context, path: string, name: string) {
  return await webdavRequest(context, encodePath(path + '/' + name), 'MKCOL', {
    Authorization: await getAccountAuthorization(context)
  })
}

export async function cp(context: Context, srcPath: string, destPath: string) {
  const accountInfo = await getAccountInfo(context)
  return await webdavRequest(context, encodePath(srcPath), 'COPY', {
    Authorization: await getAccountAuthorization(context),
    Destination: accountInfo.path + '/' + encodePath(destPath + '/' + srcPath.substring(srcPath.lastIndexOf('/'))),
    Depth: 'infinity'
  })
}

export async function mv(context: Context, srcPath: string, destPath: string) {
  const accountInfo = await getAccountInfo(context)
  return await webdavRequest(context, encodePath(srcPath), 'MOVE', {
    Authorization: await getAccountAuthorization(context),
    Destination: accountInfo.path + '/' + encodePath(destPath + '/' + srcPath.substring(srcPath.lastIndexOf('/')))
  })
}

export async function rn(context: Context, path: string, name: string) {
  const accountInfo = await getAccountInfo(context)
  return await webdavRequest(context, encodePath(path), 'MOVE', {
    Authorization: await getAccountAuthorization(context),
    Destination: accountInfo.path + '/' + encodePath(path.substring(0, path.lastIndexOf('/')) + '/' + name)
  })
}

export async function rm(context: Context, path: string) {
  return await webdavRequest(context, encodePath(path), 'DELETE', {
    Authorization: await getAccountAuthorization(context)
  })
}