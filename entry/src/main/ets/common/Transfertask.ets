import { wantAgent } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { Environment, fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { netBoost } from '@kit.NetworkBoostKit'
import { notificationManager } from '@kit.NotificationKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { deleteBackupTask, updateBackupTaskStatus } from './Backup'
import { getDnsServer } from './Dnsserver'
import { getPermission } from './Permission'
import { getSizeString } from './Stringformat'
import { TransferTaskItem } from '../pages/Index'

@Concurrent
export async function download(context: Context, id: string) {
  const transferTaskDataPreferences = preferences.getPreferencesSync(context, {
    name: 'transferTask'
  })
  const debugSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'debugSetting'
  })
  const transferTaskString = transferTaskDataPreferences.getSync(id, '{}') as string
  const transferTask = JSON.parse(transferTaskString) as TransferTaskItem
  transferTask.status = 'processing'
  transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
  try {
    let filePath = ''
    const commonSettingDataPreferences = preferences.getPreferencesSync(context, {
      name: 'commonSetting'
    })
    const downloadDirectory = commonSettingDataPreferences.getSync('downloadDirectory', 0)
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
              transferTask.status = 'success'
              transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
            }
          }
        },
        dns: {
          dnsRules: getDnsServer(context)
        },
        security: {
          remoteValidation: debugSettingDataPreferences.getSync('closeRemoteValidationWhenLinkWebdav',
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
      if (response.statusCode !== 200) {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
      }
    } catch (err) {
      if (err.code !== 1007900992) {
        transferTask.status = 'fail'
        transferTask.errCode = err.code
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
      }
      if (err.code === 1007900992) {
        transferTask.status = 'cancel'
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
      }
    }
  } catch (err) {
    transferTask.status = 'fail'
    transferTask.errCode = err.code
    transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
  }
}

@Concurrent
export async function upload(context: Context, id: string) {
  const transferTaskDataPreferences = preferences.getPreferencesSync(context, {
    name: 'transferTask'
  })
  const debugSettingDataPreferences = preferences.getPreferencesSync(context, {
    name: 'debugSetting'
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
            },
            onDataEnd: async () => {
              session.close()
              netBoost.setSceneDesc({
                scene: 'upload',
                sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
              })
              await backgroundTaskManager.stopBackgroundRunning(context,
                continuousTaskNotificationInfo.continuousTaskId)
            }
          }
        },
        dns: {
          dnsRules: getDnsServer(context)
        },
        security: {
          remoteValidation: debugSettingDataPreferences.getSync('closeRemoteValidationWhenLinkWebdav',
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
      const response = await session.uploadFromFile(transferTask.accountInfo.path + '/' + transferTask.path,
        new rcp.UploadFromFile(fileUri.getUriFromPath(transferTask.srcFileUri)))
      if (transferTask.srcFileUri.endsWith('.mv.png')) {
        await fileIo.unlink(new fileUri.FileUri(transferTask.srcFileUri).path)
      }
      if (response.statusCode !== 200) {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
        if (transferTask.backupTaskId) {
          await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, false)
        }
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transferTask.status = 'success'
        if (transferTask.backupTaskId) {
          await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, true)
          const backupSettingDataPreferences = preferences.getPreferencesSync(context, {
            name: 'backupSetting'
          })
          const deleteAfterSuccess = backupSettingDataPreferences.getSync('deleteAfterSuccess', true)
          if (deleteAfterSuccess) {
            await deleteBackupTask(context, transferTask.accountInfo, transferTask.backupTaskId)
          }
        }
      } else {
        transferTask.status = 'fail'
        transferTask.errCode = response.statusCode
        if (transferTask.backupTaskId) {
          await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, false)
        }
      }
      transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
    } catch (err) {
      if (transferTask.srcFileUri.endsWith('.mv.png')) {
        await fileIo.unlink(new fileUri.FileUri(transferTask.srcFileUri).path)
      }
      session.close()
      netBoost.setSceneDesc({
        scene: 'upload',
        sceneEvent: netBoost.SceneEvent.SCENE_EVENT_LEAVE
      })
      if (err.code !== 1007900992) {
        transferTask.status = 'fail'
        transferTask.errCode = err.code
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
        if (transferTask.backupTaskId) {
          await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, false)
        }
      }
      if (err.code === 1007900992) {
        transferTask.status = 'cancel'
        transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
        if (transferTask.backupTaskId) {
          await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, false)
        }
      }
    }
  } catch (err) {
    transferTask.status = 'fail'
    transferTask.errCode = err.code
    transferTaskDataPreferences.putSync(id, JSON.stringify(transferTask))
    if (transferTask.backupTaskId) {
      await updateBackupTaskStatus(context, transferTask.accountInfo, transferTask.backupTaskId, false)
    }
  }
}