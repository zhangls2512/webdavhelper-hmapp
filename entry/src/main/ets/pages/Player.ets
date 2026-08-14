import { common, wantAgent } from '@kit.AbilityKit'
import { LoadingDialog, PiPWindow, promptAction, uiMaterial, window } from '@kit.ArkUI'
import { avSession } from '@kit.AVSessionKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { media } from '@kit.MediaKit'
import { getAccountAuthorization } from '../common/Account'

@ComponentV2
export default struct Player {
  @Consumer() isShowPlayer: boolean = false
  @Param src: string = ''
  @Param srcName: string = ''
  @Local isVideo: boolean = true
  @Local videoHeight: number = 0
  @Local videoWidth: number = 0
  @Local showTool: boolean = true
  @Local showSetting: boolean = false
  @Local state: media.AVPlayerState = 'idle'
  @Local time: number = 0
  @Local duration: number = 0
  @Local playbackRate: number = 1
  @Local loudnessGain: number = 0
  @Local volume: number = 100
  @Local muted: boolean = false
  @Local loop: boolean = false
  @Local superResolution: boolean = false
  @Local superResolutionEnabled: boolean = true
  @Local playWhenBackground: boolean = false
  @Local autoStartPipWindow: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  xComponentController = new XComponentController()
  avPlayer: media.AVPlayer | undefined = undefined
  avSessionController: avSession.AVSession | undefined = undefined
  pipWindow: PiPWindow.PiPController | undefined = undefined
  continuousTaskId = -1
  dialogControllerProgress = new CustomDialogController({
    builder: LoadingDialog({
      content: '播放准备中...'
    })
  })

  formatTime(seconds: number) {
    const hour = Math.floor(seconds / 3600)
    const minute = Math.floor((seconds % 3600) / 60)
    const second = seconds % 60
    const array: string[] = []
    if (hour !== 0) {
      array.push(String(hour))
    }
    array.push(String(minute).padStart(2, '0'))
    array.push(String(second).padStart(2, '0'))
    return array.join(':')
  }

  @Builder
  SettingBuilder() {
    List() {
      if (this.state !== 'idle' && this.state !== 'initialized') {
        if (this.state !== 'stopped') {
          ListItem() {
            Row() {
              Text('倍速')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Slider({
                value: this.playbackRate!!,
                min: this.playWhenBackground ? 0.25 : 0.125,
                max: this.playWhenBackground ? 2 : 4,
                step: this.playWhenBackground ? 0.25 : 0.125
              })
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .onChange(async (value) => {
                  if (this.avPlayer) {
                    this.avPlayer.setPlaybackRate(value)
                    if (this.avSessionController) {
                      await this.avSessionController.setAVPlaybackState({
                        speed: value,
                        position: {
                          elapsedTime: this.avPlayer.currentTime,
                          updateTime: Date.now()
                        }
                      })
                    }
                  }
                })
              Text(this.playbackRate + 'x')
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
        ListItem() {
          Row() {
            Text('响度增益')
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Slider({
              value: this.loudnessGain!!,
              min: -900,
              max: 240
            })
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .onChange(async (value) => {
                if (this.avPlayer) {
                  await this.avPlayer.setLoudnessGain(value / 10)
                }
              })
            Text(this.loudnessGain / 10 + ' dB')
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        if (this.state !== 'stopped') {
          ListItem() {
            Row() {
              Text('音量')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Slider({
                value: this.volume!!,
                min: 0,
                max: 100
              })
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .onChange(value => {
                  if (this.avPlayer) {
                    this.avPlayer.setVolume(value / 100)
                  }
                })
              Text(this.volume + '%')
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
        ListItem() {
          Row() {
            Text('静音')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Toggle({
              type: ToggleType.Switch,
              isOn: this.muted!!
            })
              .onChange(async (isOn) => {
                if (this.avPlayer) {
                  await this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isOn)
                  if (this.avSessionController) {
                    await this.avSessionController.setAVPlaybackState({
                      muted: isOn
                    })
                  }
                }
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Row() {
            Text('循环')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Toggle({
              type: ToggleType.Switch,
              isOn: this.loop!!
            })
              .onChange(async (isOn) => {
                if (this.avPlayer) {
                  this.avPlayer.loop = isOn
                  if (this.avSessionController) {
                    await this.avSessionController.setAVPlaybackState({
                      loopMode: isOn ? avSession.LoopMode.LOOP_MODE_SINGLE : avSession.LoopMode.LOOP_MODE_SEQUENCE
                    })
                  }
                }
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        if (this.superResolutionEnabled && this.isVideo) {
          ListItem() {
            Row() {
              Text('超分辨率')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Toggle({
                type: ToggleType.Switch,
                isOn: this.superResolution!!
              })
                .onChange(async (isOn) => {
                  if (this.avPlayer) {
                    await this.avPlayer.setSuperResolution(isOn)
                  }
                })
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
        ListItem() {
          Row() {
            Text('后台播放')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            Toggle({
              type: ToggleType.Switch,
              isOn: this.playWhenBackground!!
            })
              .onChange(async (isOn) => {
                if (!isOn && this.avSessionController) {
                  this.avSessionController.off('setTargetLoopMode')
                  this.avSessionController.off('setSpeed')
                  this.avSessionController.off('seek')
                  this.avSessionController.off('fastForward')
                  this.avSessionController.off('rewind')
                  this.avSessionController.off('stop')
                  this.avSessionController.off('pause')
                  this.avSessionController.off('play')
                  await this.avSessionController.deactivate()
                  if (this.continuousTaskId !== -1) {
                    try {
                      await backgroundTaskManager.stopBackgroundRunning(this.context, this.continuousTaskId)
                      this.continuousTaskId = -1
                    } catch {
                    }
                  }
                  await this.avSessionController.destroy()
                  this.avSessionController = undefined
                }
                if (isOn && this.avPlayer) {
                  this.avSessionController =
                    await avSession.createAVSession(this.context, this.src, this.isVideo ? 'video' : 'audio')
                  await this.avSessionController.activate()
                  await this.avSessionController.setAVMetadata({
                    assetId: this.src,
                    title: this.srcName,
                    duration: this.avPlayer.duration
                  })
                  const wandAgent = await wantAgent.getWantAgent({
                    wants: [
                      {
                        bundleName: 'com.zhuzx.webdavhelper',
                        abilityName: 'EntryAbility'
                      }
                    ],
                    actionType: wantAgent.OperationType.START_ABILITY,
                    requestCode: 0
                  })
                  const backgroundTask = await backgroundTaskManager.startBackgroundRunning(this.context,
                    ['audioPlayback'], wandAgent)
                  this.continuousTaskId = backgroundTask.continuousTaskId ?? -1
                  await this.avSessionController.setSupportedPlaySpeeds([0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2])
                  await this.avSessionController.setSupportedLoopModes(
                    [avSession.LoopMode.LOOP_MODE_SEQUENCE, avSession.LoopMode.LOOP_MODE_SINGLE])
                  await this.avSessionController.setMediaCenterControlType(
                    ['fastForward', 'rewind', 'setSpeed', 'setLoopMode'])
                  if (this.isVideo) {
                    await this.avSessionController.setBackgroundPlayMode(
                      avSession.BackgroundPlayMode.ENABLE_BACKGROUND_PLAY)
                  }
                  if (this.state === 'idle') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_IDLE
                    })
                  }
                  if (this.state === 'initialized') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_INITIAL
                    })
                  }
                  if (this.state === 'prepared') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_PREPARE
                    })
                  }
                  if (this.state === 'playing') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY
                    })
                  }
                  if (this.state === 'paused') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE
                    })
                  }
                  if (this.state === 'completed') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_COMPLETED
                    })
                  }
                  if (this.state === 'stopped') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_STOP
                    })
                  }
                  if (this.state === 'released') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_RELEASED
                    })
                  }
                  if (this.state === 'error') {
                    await this.avSessionController.setAVPlaybackState({
                      state: avSession.PlaybackState.PLAYBACK_STATE_ERROR
                    })
                  }
                  await this.avSessionController.setAVPlaybackState({
                    speed: this.playbackRate,
                    position: {
                      elapsedTime: this.avPlayer.currentTime,
                      updateTime: Date.now()
                    },
                    loopMode: this.avPlayer.loop ? avSession.LoopMode.LOOP_MODE_SINGLE :
                      avSession.LoopMode.LOOP_MODE_SEQUENCE,
                    volume: this.volume,
                    muted: this.muted,
                    videoHeight: this.videoHeight,
                    videoWidth: this.videoWidth
                  })
                  this.avSessionController.on('play', async () => {
                    if (this.avPlayer) {
                      if (this.state === 'stopped') {
                        this.dialogControllerProgress.open()
                        try {
                          await this.avPlayer.prepare()
                          await this.avPlayer.play()
                        } catch (err) {
                          this.dialogControllerProgress.close()
                          await promptAction.openToast({
                            message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                          })
                        }
                      } else {
                        await this.avPlayer.play()
                      }
                    }
                  })
                  this.avSessionController.on('pause', async () => {
                    if (this.avPlayer) {
                      await this.avPlayer.pause()
                    }
                  })
                  this.avSessionController.on('stop', async () => {
                    if (this.avPlayer) {
                      await this.avPlayer.stop()
                    }
                  })
                  this.avSessionController.on('rewind', () => {
                    if (this.avPlayer && this.avPlayer.currentTime >= 15000) {
                      this.avPlayer.seek(this.avPlayer.currentTime - 15000, media.SeekMode.SEEK_PREV_SYNC)
                    }
                  })
                  this.avSessionController.on('fastForward', () => {
                    if (this.avPlayer && this.avPlayer.duration - this.avPlayer.currentTime >= 15000) {
                      this.avPlayer.seek(this.avPlayer.currentTime + 15000, media.SeekMode.SEEK_NEXT_SYNC)
                    }
                  })
                  this.avSessionController.on('seek', (time) => {
                    if (this.avPlayer) {
                      this.avPlayer.seek(time, media.SeekMode.SEEK_CLOSEST)
                    }
                  })
                  this.avSessionController.on('setSpeed', async (speed) => {
                    this.playbackRate = speed
                    if (this.avPlayer) {
                      this.avPlayer.setPlaybackRate(speed)
                      if (this.avSessionController) {
                        await this.avSessionController.setAVPlaybackState({
                          speed: speed,
                          position: {
                            elapsedTime: this.avPlayer.currentTime,
                            updateTime: Date.now()
                          }
                        })
                      }
                    }
                  })
                  this.avSessionController.on('setTargetLoopMode', async (loopMode) => {
                    if (this.avPlayer) {
                      this.avPlayer.loop = (loopMode === avSession.LoopMode.LOOP_MODE_SINGLE ? true : false)
                      this.loop = this.avPlayer.loop
                      if (this.avSessionController) {
                        await this.avSessionController.setAVPlaybackState({
                          loopMode: loopMode
                        })
                      }
                    }
                  })
                }
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        if (this.isVideo && PiPWindow.isPiPEnabled()) {
          ListItem() {
            Row() {
              Text('返回桌面时自动启动画中画')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Toggle({
                type: ToggleType.Switch,
                isOn: this.autoStartPipWindow!!
              })
                .onChange(isOn => {
                  if (this.pipWindow) {
                    this.pipWindow.setAutoStartEnabled(isOn)
                  }
                })
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
  }

  build() {
    Stack() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .height(this.videoHeight)
        .width(this.videoWidth)
        .onClick(() => {
          this.showTool = true
        })
      if (this.showTool && this.state !== 'idle' && this.state !== 'initialized') {
        Column() {
          Column() {
            Image($r('app.media.back'))
          }
          .bindTips('返回')
          .borderRadius(20)
          .height(40)
          .hitTestBehavior(HitTestMode.Block)
          .padding(11)
          .stateStyles({
            normal: {
              .backgroundColor($r('sys.color.interactive_hover'))
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            }
          })
          .systemMaterial(new uiMaterial.ImmersiveMaterial({
            style: uiMaterial.ImmersiveStyle.REGULAR,
            interactive: true,
            lightEffect: {
              color: Color.White
            }
          }))
          .width(40)
          .onClick(() => {
            this.isShowPlayer = false
          })

          Column() {
            if (this.state !== 'stopped') {
              Row() {
                Text(this.formatTime(this.time))
                  .fontColor(Color.White)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Slider({
                  value: this.time!!,
                  max: this.duration
                })
                  .hitTestBehavior(HitTestMode.Block)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                  .onChange(value => {
                    if (this.avPlayer) {
                      this.avPlayer.seek(value * 1000,
                        this.avPlayer.isSeekContinuousSupported() ? media.SeekMode.SEEK_CONTINUOUS :
                          media.SeekMode.SEEK_CLOSEST)
                    }
                  })
                Text(this.formatTime(this.duration))
                  .fontColor(Color.White)
              }
            }
            Row() {
              if (this.state !== 'stopped' && this.time >= 15) {
                Column() {
                  Image($r('app.media.gobackward15'))
                }
                .bindTips('快退')
                .borderRadius(20)
                .height(40)
                .hitTestBehavior(HitTestMode.Block)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .systemMaterial(new uiMaterial.ImmersiveMaterial({
                  style: uiMaterial.ImmersiveStyle.REGULAR,
                  interactive: true,
                  lightEffect: {
                    color: Color.White
                  }
                }))
                .width(40)
                .onClick(() => {
                  if (this.avPlayer) {
                    this.avPlayer.seek(this.avPlayer.currentTime - 15000, media.SeekMode.SEEK_PREV_SYNC)
                  }
                })
              }
              if (this.state === 'paused' || this.state === 'completed' || this.state === 'stopped') {
                Column() {
                  Image($r('app.media.play'))
                }
                .bindTips('播放')
                .borderRadius(20)
                .height(40)
                .hitTestBehavior(HitTestMode.Block)
                .margin({
                  right: this.state === 'paused' ? $r('sys.float.ohos_id_elements_margin_horizontal_m') : 0
                })
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .systemMaterial(new uiMaterial.ImmersiveMaterial({
                  style: uiMaterial.ImmersiveStyle.REGULAR,
                  interactive: true,
                  lightEffect: {
                    color: Color.White
                  }
                }))
                .width(40)
                .onClick(async () => {
                  if (this.avPlayer) {
                    if (this.state === 'stopped') {
                      this.dialogControllerProgress.open()
                      try {
                        await this.avPlayer.prepare()
                        await this.avPlayer.play()
                      } catch (err) {
                        this.dialogControllerProgress.close()
                        await promptAction.openToast({
                          message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                        })
                      }
                    } else {
                      await this.avPlayer.play()
                    }
                  }
                })
              }
              if (this.state === 'playing') {
                Column() {
                  Image($r('app.media.pause'))
                }
                .bindTips('暂停')
                .borderRadius(20)
                .height(40)
                .hitTestBehavior(HitTestMode.Block)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .systemMaterial(new uiMaterial.ImmersiveMaterial({
                  style: uiMaterial.ImmersiveStyle.REGULAR,
                  interactive: true,
                  lightEffect: {
                    color: Color.White
                  }
                }))
                .width(40)
                .onClick(async () => {
                  if (this.avPlayer) {
                    await this.avPlayer.pause()
                  }
                })
              }
              if (this.state === 'playing' || this.state === 'paused') {
                Column() {
                  Image($r('app.media.stop'))
                }
                .bindTips('停止')
                .borderRadius(20)
                .height(40)
                .hitTestBehavior(HitTestMode.Block)
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .systemMaterial(new uiMaterial.ImmersiveMaterial({
                  style: uiMaterial.ImmersiveStyle.REGULAR,
                  interactive: true,
                  lightEffect: {
                    color: Color.White
                  }
                }))
                .width(40)
                .onClick(async () => {
                  if (this.avPlayer) {
                    await this.avPlayer.stop()
                  }
                })
              }
              if (this.state !== 'stopped' && this.duration - this.time >= 15) {
                Column() {
                  Image($r('app.media.goforward15'))
                }
                .bindTips('快进')
                .borderRadius(20)
                .height(40)
                .hitTestBehavior(HitTestMode.Block)
                .margin({
                  left: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
                .padding(11)
                .stateStyles({
                  normal: {
                    .backgroundColor($r('sys.color.interactive_hover'))
                  },
                  pressed: {
                    .backgroundColor($r('sys.color.interactive_pressed'))
                  }
                })
                .systemMaterial(new uiMaterial.ImmersiveMaterial({
                  style: uiMaterial.ImmersiveStyle.REGULAR,
                  interactive: true,
                  lightEffect: {
                    color: Color.White
                  }
                }))
                .width(40)
                .onClick(() => {
                  if (this.avPlayer) {
                    this.avPlayer.seek(this.avPlayer.currentTime + 15000, media.SeekMode.SEEK_NEXT_SYNC)
                  }
                })
              }
              Blank()
              Column() {
                Image($r('app.media.setting'))
                  .fillColor($r('sys.color.icon_primary'))
              }
              .bindTips('设置')
              .borderRadius(20)
              .height(40)
              .hitTestBehavior(HitTestMode.Block)
              .padding(11)
              .stateStyles({
                normal: {
                  .backgroundColor($r('sys.color.interactive_hover'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .systemMaterial(new uiMaterial.ImmersiveMaterial({
                style: uiMaterial.ImmersiveStyle.REGULAR,
                interactive: true,
                lightEffect: {
                  color: Color.White
                }
              }))
              .width(40)
              .onClick(() => {
                this.showSetting = true
              })
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .width('100%')
            .bindSheet(this.showSetting!!, this.SettingBuilder(), {
              height: SheetSize.FIT_CONTENT,
              preferType: SheetType.SIDE,
              title: {
                title: '设置'
              },
              systemMaterial: new uiMaterial.ImmersiveMaterial({
                style: uiMaterial.ImmersiveStyle.REGULAR
              })
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .height(this.videoHeight)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding($r('sys.float.ohos_id_elements_margin_vertical_l'))
        .width(this.videoWidth)
        .onClick(() => {
          this.showTool = false
        })
      }
    }
    .backgroundColor(Color.Black)
    .height('100%')
    .onAppear(async () => {
      const lastWindow = await window.getLastWindow(this.context)
      lastWindow.setWindowDecorVisible(false)
      if (deviceInfo.deviceType === '2in1') {
        lastWindow.setWindowTitleButtonVisible(false, false, false)
      }
      await lastWindow.setSpecificSystemBarEnabled('status', false, true)
      const windowProperties = lastWindow.getWindowProperties()
      const windowHeight = this.UIContext.px2vp(windowProperties.windowRect.height)
      const windowWidth = this.UIContext.px2vp(windowProperties.windowRect.width)
      this.pipWindow = await PiPWindow.create({
        context: this.context,
        componentController: this.xComponentController,
        controlGroups: [PiPWindow.VideoPlayControlGroup.FAST_FORWARD_BACKWARD,
          PiPWindow.VideoPlayControlGroup.FAST_FORWARD_BACKWARD]
      })
      this.pipWindow.on('controlEvent', async (event) => {
        if (this.avPlayer) {
          if (event.controlType === PiPWindow.PiPControlType.FAST_BACKWARD) {
            this.avPlayer.seek(this.avPlayer.currentTime - 15000, media.SeekMode.SEEK_PREV_SYNC)
          }
          if (event.controlType === PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE) {
            if (event.status === PiPWindow.PiPControlStatus.PLAY) {
              if (this.state === 'stopped') {
                this.dialogControllerProgress.open()
                try {
                  await this.avPlayer.prepare()
                  await this.avPlayer.play()
                } catch (err) {
                  this.dialogControllerProgress.close()
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
                  })
                }
              } else {
                await this.avPlayer.play()
              }
            }
            if (event.status === PiPWindow.PiPControlStatus.PAUSE) {
              await this.avPlayer.pause()
            }
          }
          if (event.controlType === PiPWindow.PiPControlType.FAST_FORWARD) {
            this.avPlayer.seek(this.avPlayer.currentTime + 15000, media.SeekMode.SEEK_NEXT_SYNC)
          }
        }
      })
      this.dialogControllerProgress.open()
      this.avPlayer = await media.createAVPlayer()
      const mediaSource = media.createMediaSourceWithUrl(this.src, {
        Authorization: await getAccountAuthorization(this.context)
      })
      await this.avPlayer.setMediaSource(mediaSource)
      this.avPlayer.on('stateChange', async (state) => {
        this.state = state
        if (this.avSessionController) {
          if (this.state === 'idle') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_IDLE
            })
          }
          if (this.state === 'initialized') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_INITIAL
            })
          }
          if (this.state === 'prepared') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_PREPARE
            })
          }
          if (this.state === 'playing') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_PLAY
            })
          }
          if (this.state === 'paused') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE
            })
          }
          if (this.state === 'completed') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_COMPLETED
            })
          }
          if (this.state === 'stopped') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_STOP
            })
          }
          if (this.state === 'released') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_RELEASED
            })
          }
          if (this.state === 'error') {
            await this.avSessionController.setAVPlaybackState({
              state: avSession.PlaybackState.PLAYBACK_STATE_ERROR
            })
          }
        }
        if (this.pipWindow) {
          if (this.state !== 'stopped' && this.time >= 15) {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_BACKWARD, true)
          } else {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_BACKWARD, false)
          }
          if (this.state !== 'stopped' && this.duration - this.time >= 15) {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_FORWARD, true)
          } else {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_FORWARD, false)
          }
          if (this.state !== 'idle' && this.state !== 'initialized') {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, true)
          } else {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, false)
          }
        }
        if (state === 'initialized') {
          if (this.avPlayer) {
            this.avPlayer.surfaceId = this.xComponentController.getXComponentSurfaceId()
            try {
              await this.avPlayer.setPlaybackStrategy({
                preferredHdr: true,
                enableSuperResolution: true
              })
              await this.avPlayer.prepare()
              try {
                await this.avPlayer.setSuperResolution(true)
                await this.avPlayer.setSuperResolution(false)
              } catch (err) {
                if (err.code === 5410003) {
                  this.superResolutionEnabled = false
                }
              }
            } catch (err) {
              this.dialogControllerProgress.open()
              await promptAction.openToast({
                message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
              })
            }
          }
        }
        if (state === 'prepared') {
          this.dialogControllerProgress.close()
          if (this.avPlayer) {
            this.duration = Number((this.avPlayer.duration / 1000).toFixed(0))
            this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_SCALED_ASPECT
            if (this.avPlayer.width !== 0) {
              if (windowHeight < windowWidth || this.avPlayer.height >= this.avPlayer.width) {
                this.videoHeight = windowHeight
                this.videoWidth = windowWidth
              }
              if (windowHeight >= windowWidth && this.avPlayer.height < this.avPlayer.width) {
                await lastWindow.setPreferredOrientation(window.Orientation.LANDSCAPE)
                this.videoHeight = windowWidth
                this.videoWidth = windowHeight
              }
            }
            if (this.avPlayer.width === 0) {
              this.isVideo = false
              this.videoHeight = windowHeight
              this.videoWidth = windowWidth
            }
            await this.avPlayer.play()
          }
        }
      })
      let lastUpdateTime = 0
      this.avPlayer.on('timeUpdate', async (time) => {
        const currentTime = Date.now()
        this.time = Number((time / 1000).toFixed(0))
        if (currentTime - lastUpdateTime >= 500 && this.avSessionController) {
          lastUpdateTime = currentTime
          await this.avSessionController.setAVPlaybackState({
            position: {
              elapsedTime: time,
              updateTime: Date.now()
            }
          })
        }
        if (this.pipWindow) {
          if (this.state !== 'stopped' && this.time >= 15) {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_BACKWARD, true)
          } else {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_BACKWARD, false)
          }
          if (this.state !== 'stopped' && this.duration - this.time >= 15) {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_FORWARD, true)
          } else {
            this.pipWindow.setPiPControlEnabled(PiPWindow.PiPControlType.FAST_FORWARD, false)
          }
        }
      })
      this.avPlayer.on('error', async (err) => {
        await promptAction.openToast({
          message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
        })
      })
    })
    .onDisAppear(async () => {
      if (this.avPlayer) {
        this.avPlayer.off('error')
        this.avPlayer.off('timeUpdate')
        this.avPlayer.off('stateChange')
        await this.avPlayer.release()
      }
      if (this.avSessionController) {
        this.avSessionController.off('setTargetLoopMode')
        this.avSessionController.off('setSpeed')
        this.avSessionController.off('seek')
        this.avSessionController.off('fastForward')
        this.avSessionController.off('rewind')
        this.avSessionController.off('stop')
        this.avSessionController.off('pause')
        this.avSessionController.off('play')
        await this.avSessionController.deactivate()
        if (this.continuousTaskId !== -1) {
          try {
            await backgroundTaskManager.stopBackgroundRunning(this.context, this.continuousTaskId)
          } catch {
          }
        }
        await this.avSessionController.destroy()
        this.avSessionController = undefined
      }
      if (this.pipWindow) {
        this.pipWindow.off('controlEvent')
      }
      const lastWindow = await window.getLastWindow(this.context)
      await lastWindow.setPreferredOrientation(window.Orientation.PORTRAIT)
      await lastWindow.setSpecificSystemBarEnabled('status', true, true)
      if (deviceInfo.deviceType === '2in1') {
        lastWindow.setWindowTitleButtonVisible(true, true, true)
      }
      lastWindow.setWindowDecorVisible(true)
    })
  }
}