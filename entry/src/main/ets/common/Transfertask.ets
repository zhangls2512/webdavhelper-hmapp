import { wantAgent } from '@kit.AbilityKit'
import { sendablePreferences } from '@kit.ArkData'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { Environment, fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { netBoost } from '@kit.NetworkBoostKit'
import { notificationManager } from '@kit.NotificationKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { getDnsServer } from './Dnsserver'
import { getPermission } from './Permission'
import { getFlushPreference } from './Preference'
import { getSizeString } from './Stringformat'
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
  try {
    let filePath = ''
    const downloadDirectory = getFlushPreference(context, 'commonSetting', 'downloadDirectory', 0)
    if (downloadDirectory === 1 && getPermission('ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY') &&
      deviceInfo.deviceType !== 'phone') {
      filePath = Environment.getUserDownloadDir() + '/' + transferTask.name
    } else {
      const documentSaveOptions = new picker.DocumentSaveOptions()
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD
      const documentViewPicker = new picker.DocumentViewPicker(context)
      const uris = await documentViewPicker.save(documentSaveOptions)
      if (uris.length === 1) {
        filePath = new fileUri.FileUri(uris[0] + '/' + transferTask.name).path
      }
    }
    const wandAgent = await wantAgent.getWantAgent({
      wants: [
        {
          bundleName: 'com.zhuzx.webdavhelper',
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    })
    const continuousTaskNotificationInfo =
      await backgroundTaskManager.startBackgroundRunning(context, ['dataTransfer'], wandAgent)
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    const fileStream = fileIo.fdopenStreamSync(file.fd, 'w+')
    netBoost.setSceneDesc({
      scene: 'download',
      sceneEvent: netBoost.SceneEvent.SCENE_EVENT_ENTER
    })
    let lastUpdateTime = 0
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
              const currentTime = Date.now()
              if (currentTime - lastUpdateTime >= 50) {
                transferTask.transferredSize = transferredSize
                transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
                try {
                  await notificationManager.publish({
                    content: {
                      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
                      systemLiveView: {
                        typeCode: 8,
                        title: '正在下载文件：' + transferTask.name,
                        text: '进度：' + Number((transferredSize / totalSize).toFixed(2)) * 100 + '% (' +
                          getSizeString(transferredSize) + '/' + getSizeString(totalSize) + ')'
                      }
                    },
                    id: continuousTaskNotificationInfo.notificationId,
                    notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
                    template: {
                      name: 'downloadTemplate',
                      data: {
                        title: '正在下载文件，进度：' + Number((transferredSize / totalSize).toFixed(2)) * 100 + '%',
                        fileName: transferTask.name,
                        progressValue: Number((transferredSize / totalSize).toFixed(2)) * 100
                      }
                    }
                  })
                } catch {
                }
              }
              lastUpdateTime = currentTime
            },
            onDataEnd: async () => {
              session.close()
              netBoost.setSceneDesc({
                scene: 'download',
                sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
              })
              fileStream.closeSync()
              await backgroundTaskManager.stopBackgroundRunning(context,
                continuousTaskNotificationInfo.continuousTaskId)
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
    backgroundTaskManager.on('continuousTaskCancel', () => {
      session.cancel()
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
    const wandAgent = await wantAgent.getWantAgent({
      wants: [
        {
          bundleName: 'com.zhuzx.webdavhelper',
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    })
    const continuousTaskNotificationInfo =
      await backgroundTaskManager.startBackgroundRunning(context, ['dataTransfer'], wandAgent)
    netBoost.setSceneDesc({
      scene: 'upload',
      sceneEvent: netBoost.SceneEvent.SCENE_EVENT_ENTER
    })
    let lastUpdateTime = 0
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
              const currentTime = Date.now()
              if (currentTime - lastUpdateTime >= 50) {
                transferTask.transferredSize = transferredSize
                transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
                try {
                  await notificationManager.publish({
                    content: {
                      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
                      systemLiveView: {
                        typeCode: 8,
                        title: '正在上传文件：' + transferTask.name,
                        text: '进度：' + Number((transferredSize / totalSize).toFixed(2)) * 100 + '% (' +
                          getSizeString(transferredSize) + '/' + getSizeString(totalSize) + ')'
                      }
                    },
                    id: continuousTaskNotificationInfo.notificationId,
                    notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
                    template: {
                      name: 'downloadTemplate',
                      data: {
                        title: '正在上传文件，进度：' + Number((transferredSize / totalSize).toFixed(2)) * 100 + '%',
                        fileName: transferTask.name,
                        progressValue: Number((transferredSize / totalSize).toFixed(2)) * 100
                      }
                    }
                  })
                } catch {
                }
              }
              lastUpdateTime = currentTime
            },
            onDataEnd: async () => {
              session.close()
              netBoost.setSceneDesc({
                scene: 'upload',
                sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
              })
              await backgroundTaskManager.stopBackgroundRunning(context,
                continuousTaskNotificationInfo.continuousTaskId)
              if (transferTask.srcFileUri.endsWith('.mv.png')) {
                await fileIo.unlink(new fileUri.FileUri(transferTask.srcFileUri).path)
              }
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
    backgroundTaskManager.on('continuousTaskCancel', () => {
      session.cancel()
    })
    try {
      const response =
        await session.put(transferTask.accountInfo.path + '/' + encodePath(transferTask.path + '/' + transferTask.name),
          new rcp.UploadFromFile(fileUri.getUriFromPath(transferTask.srcFileUri)))
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transferTask.status = 'success'
      } else {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
      }
    } catch (err) {
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