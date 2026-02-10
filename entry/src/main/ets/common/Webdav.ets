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
    Authorization: await getAccountAuthorization(),
    Depth: '1'
  })
  if (res !== 'fail') {
    const files: FileItem[] = []
    Array.from(res.matchAll(/<D:response[^>]*>([\s\S]*?)<\/D:response>/g))
      .map(item => item[1])
      .forEach((item, index) => {
        const hrefMatch = item.match(/<D:href[^>]*>(.*?)<\/D:href>/)
        if (hrefMatch) {
          if (index !== 0) {
            const isdir = /<[^:]+:resourcetype>[\s\S]*?<[^:]+:collection\s*\/>/.test(item)
            let size = -1
            if (!isdir) {
              const sizeMatch = item.match(/<lp1:getcontentlength[^>]*>(\d+)<\/lp1:getcontentlength>/i)
              if (sizeMatch) {
                size = Number(sizeMatch[1])
              }
            }
            const modifyTimeMatch = item.match(/<lp1:getlastmodified[^>]*>(.*?)<\/lp1:getlastmodified>/i)
            if (modifyTimeMatch) {
              const name = hrefMatch[1].replace(/^\/+|\/+$/g, '')
              files.push({
                path: name,
                name: decodeURIComponent(name).substring(decodeURIComponent(name).lastIndexOf('/') + 1),
                isdir: isdir,
                size: size,
                modifyTime: Date.parse(modifyTimeMatch[1]) / 1000,
                type: name.substring(name.lastIndexOf('.') + 1)
              })
            }
          }
        }
      })
    return files
  }
  return []
}

export async function mkdir(context: Context, path: string, name: string) {
  return await webdavRequest(context, encodePath(path + '/' + name), 'MKCOL', {
    Authorization: await getAccountAuthorization()
  })
}

export async function cp(context: Context, srcPath: string, destPath: string) {
  const accountInfo = await getAccountInfo()
  return await webdavRequest(context, encodePath(srcPath), 'COPY', {
    Authorization: await getAccountAuthorization(),
    Destination: accountInfo.path + '/' + encodePath(destPath + '/' + srcPath.substring(srcPath.lastIndexOf('/'))),
    Depth: 'infinity'
  })
}

export async function mv(context: Context, srcPath: string, destPath: string) {
  const accountInfo = await getAccountInfo()
  return await webdavRequest(context, encodePath(srcPath), 'MOVE', {
    Authorization: await getAccountAuthorization(),
    Destination: accountInfo.path + '/' + encodePath(destPath + '/' + srcPath.substring(srcPath.lastIndexOf('/')))
  })
}

export async function rn(context: Context, path: string, name: string) {
  const accountInfo = await getAccountInfo()
  return await webdavRequest(context, encodePath(path), 'MOVE', {
    Authorization: await getAccountAuthorization(),
    Destination: accountInfo.path + '/' + encodePath(path.substring(0, path.lastIndexOf('/')) + '/' + name)
  })
}

export async function rm(context: Context, path: string) {
  return await webdavRequest(context, encodePath(path), 'DELETE', {
    Authorization: await getAccountAuthorization()
  })
}