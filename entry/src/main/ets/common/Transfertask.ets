import { sendablePreferences } from '@kit.ArkData'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { netBoost } from '@kit.NetworkBoostKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { getDnsServer } from './Dnsserver'
import { getFlushPreference } from './Preference'
import { addFilePathIndex } from './Stringformat'
import { encodePath } from './Webdav'
import { TransferTaskItem } from '../pages/Index'

@Concurrent
export async function download(context: Context, id: string) {
  const transferTaskDataPreferences = sendablePreferences.getPreferencesSync(context, {
    name: 'transferTask'
  })
  const transferTaskString = transferTaskDataPreferences.getSync(id, '{}') as string
  const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
  transferTask.status = 'processing'
  transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
  let filePath = transferTask.destDownloadPath
  if (getFlushPreference(context, 'commonSetting', 'operationWhenDownloadConflict', 0) === 0) {
    let index = 0
    let fileExist = fileIo.accessSync(filePath)
    while (fileExist) {
      index++
      filePath = addFilePathIndex(transferTask.destDownloadPath, index)
      fileExist = fileIo.accessSync(filePath)
    }
  }
  try {
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    const fileStream = fileIo.fdopenStreamSync(file.fd, 'w+')
    netBoost.setSceneDesc({
      scene: 'download',
      sceneEvent: netBoost.SceneEvent.SCENE_EVENT_ENTER
    })
    let lastUpdateTime = 0
    let lastTransferredSize = 0
    const session = rcp.createSession({
      requestConfiguration: {
        transfer: {
          timeout: {
            transferMs: 0
          }
        },
        tracing: {
          httpEventsHandler: {
            onDataReceive: async (incomingData) => {
              await fileStream.write(incomingData)
            },
            onDownloadProgress: async (totalSize, transferredSize) => {
              const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(context)
              if (continuousTasks.length === 0) {
                session.cancel()
              }
              transferTask.transferredSize = transferredSize
              transferTask.totalSize = totalSize
              const currentTime = Date.now()
              if (currentTime - lastUpdateTime >= 1000) {
                transferTask.speed = transferredSize - lastTransferredSize
                lastUpdateTime = currentTime
                lastTransferredSize = transferredSize
              }
              transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
            },
            onDataEnd: () => {
              session.close()
              netBoost.setSceneDesc({
                scene: 'download',
                sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
              })
              fileStream.closeSync()
            }
          }
        },
        dns: {
          dnsRules: getDnsServer(context)
        },
        security: {
          remoteValidation: getFlushPreference(context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav',
            'system') as 'system' | 'skip',
          tlsRange: {
            min: 'TlsV1.2'
          }
        }
      },
      headers: {
        Authorization: transferTask.authorization
      }
    })
    try {
      const response = await session.get(transferTask.accountInfo.path + '/' + transferTask.path)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transferTask.status = 'success'
      } else {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
      }
    } catch (err) {
      session.close()
      netBoost.setSceneDesc({
        scene: 'download',
        sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
      })
      fileStream.closeSync()
      if (err.code !== 1007900992) {
        transferTask.status = 'fail'
        transferTask.errCode = err.code
      }
      if (err.code === 1007900992) {
        transferTask.status = 'cancel'
      }
    }
  } catch (err) {
    transferTask.status = 'fail'
    transferTask.errCode = err.code
  }
  transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
}

@Concurrent
export async function upload(context: Context, id: string) {
  const transferTaskDataPreferences = sendablePreferences.getPreferencesSync(context, {
    name: 'transferTask'
  })
  const transferTaskString = transferTaskDataPreferences.getSync(id, '{}') as string
  const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
  transferTask.status = 'processing'
  transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
  try {
    netBoost.setSceneDesc({
      scene: 'upload',
      sceneEvent: netBoost.SceneEvent.SCENE_EVENT_ENTER
    })
    let lastUpdateTime = 0
    let lastTransferredSize = 0
    const session = rcp.createSession({
      requestConfiguration: {
        transfer: {
          timeout: {
            transferMs: 0
          }
        },
        tracing: {
          httpEventsHandler: {
            onUploadProgress: async (totalSize, transferredSize) => {
              const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(context)
              if (continuousTasks.length === 0) {
                session.cancel()
              }
              transferTask.transferredSize = transferredSize
              transferTask.totalSize = totalSize
              const currentTime = Date.now()
              if (currentTime - lastUpdateTime >= 1000) {
                transferTask.speed = transferredSize - lastTransferredSize
                lastUpdateTime = currentTime
                lastTransferredSize = transferredSize
              }
              transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
            },
            onDataEnd: () => {
              session.close()
              netBoost.setSceneDesc({
                scene: 'upload',
                sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
              })
            }
          }
        },
        dns: {
          dnsRules: getDnsServer(context)
        },
        security: {
          remoteValidation: getFlushPreference(context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav',
            'system') as 'system' | 'skip',
          tlsRange: {
            min: 'TlsV1.2'
          }
        }
      },
      headers: {
        Authorization: transferTask.authorization
      }
    })
    const intervalId = setInterval(async () => {
      const continuousTasks = await backgroundTaskManager.getAllContinuousTasks(context)
      if (continuousTasks.length === 0) {
        session.cancel()
      }
    }, 1000)
    try {
      const response =
        await session.put(transferTask.accountInfo.path + '/' + encodePath(transferTask.path + '/' + transferTask.name),
          new rcp.UploadFromFile(fileUri.getUriFromPath(transferTask.srcFileUri)))
      clearInterval(intervalId)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transferTask.status = 'success'
      } else {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
      }
    } catch (err) {
      clearInterval(intervalId)
      session.close()
      netBoost.setSceneDesc({
        scene: 'upload',
        sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
      })
      if (err.code !== 1007900992) {
        transferTask.status = 'fail'
        transferTask.errCode = err.code ?? err.message
      }
      if (err.code === 1007900992) {
        transferTask.status = 'cancel'
      }
    }
  } catch (err) {
    transferTask.status = 'fail'
    transferTask.errCode = err.code
  }
  transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
}