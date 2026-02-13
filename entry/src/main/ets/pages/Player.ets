import { common } from '@kit.AbilityKit'
import { LoadingDialog, PiPWindow, promptAction, window } from '@kit.ArkUI'
import { media } from '@kit.MediaKit'
import { hdsEffect } from '@kit.UIDesignKit'
import { getAccountAuthorization } from '../common/Account'

@ComponentV2
export default struct Player {
  @Param src: string = ''
  @Local isVideo: boolean = true
  @Local videoHeight: number = 100
  @Local videoWidth: number = 100
  @Local state: media.AVPlayerState = 'idle'
  @Local time: number = -1
  @Local duration: number = -1
  @Local playbackRate: number = 1
  @Local loudnessGain: number = 0
  @Local volume: number = 100
  @Local muted: boolean = false
  @Local loop: boolean = false
  @Local autoStartPipWindow: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  xComponentController = new XComponentController()
  avPlayer: media.AVPlayer | undefined = undefined
  pipWindow: PiPWindow.PiPController | undefined = undefined
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
    array.push(minute.toString().padStart(2, '0'))
    array.push(second.toString().padStart(2, '0'))
    return array.join(':')
  }

  build() {
    List() {
      if (this.isVideo) {
        ListItem() {
          XComponent({
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .height(this.videoHeight)
            .width(this.videoWidth)
        }
        .height(this.videoHeight)
      }

      ListItem() {
        Row() {
          if (this.state !== 'idle' && this.state !== 'initialized' && this.state !== 'stopped' && this.time >= 15) {
            Column() {
              Image($r('app.media.gobackward15'))
            }
            .borderRadius(20)
            .height(40)
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
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .pointLight({
                sourceType: hdsEffect.PointLightSourceType.SOFT,
                illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
              })
              .buildEffect())
            .width(40)
            .onClick(async () => {
              this.avPlayer?.seek(this.time * 1000 - 15000)
              if (this.state !== 'playing') {
                await this.avPlayer?.play()
              }
            })
          }
          if (this.state === 'paused' || this.state === 'completed' || this.state === 'stopped') {
            Column() {
              Image($r('app.media.play'))
            }
            .borderRadius(20)
            .height(40)
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
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .pointLight({
                sourceType: hdsEffect.PointLightSourceType.SOFT,
                illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
              })
              .buildEffect())
            .width(40)
            .onClick(async () => {
              if (this.state === 'stopped') {
                this.dialogControllerProgress.open()
                await this.avPlayer?.prepare()
              }
              await this.avPlayer?.play()
            })
          }
          if (this.state === 'playing') {
            Column() {
              Image($r('app.media.pause'))
            }
            .borderRadius(20)
            .height(40)
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
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .pointLight({
                sourceType: hdsEffect.PointLightSourceType.SOFT,
                illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
              })
              .buildEffect())
            .width(40)
            .onClick(async () => {
              await this.avPlayer?.pause()
            })
          }
          if (this.state === 'playing' || this.state === 'paused') {
            Column() {
              Image($r('app.media.stop'))
            }
            .borderRadius(20)
            .height(40)
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
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .pointLight({
                sourceType: hdsEffect.PointLightSourceType.SOFT,
                illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
              })
              .buildEffect())
            .width(40)
            .onClick(async () => {
              await this.avPlayer?.stop()
            })
          }
          if (this.state !== 'idle' && this.state !== 'initialized' && this.state !== 'stopped' &&
            this.duration - this.time >= 15) {
            Column() {
              Image($r('app.media.goforward15'))
            }
            .borderRadius(20)
            .height(40)
            .padding(11)
            .stateStyles({
              normal: {
                .backgroundColor($r('sys.color.interactive_hover'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              }
            })
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .pointLight({
                sourceType: hdsEffect.PointLightSourceType.SOFT,
                illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
              })
              .buildEffect())
            .width(40)
            .onClick(() => {
              this.avPlayer?.seek(this.time * 1000 + 15000)
            })
          }
        }
      }
      .margin({
        top: this.isVideo ? $r('sys.float.ohos_id_elements_margin_vertical_l') :
          $r('sys.float.ohos_id_elements_margin_vertical_m')
      })
      .width('100%')

      if (this.time !== -1 && this.duration !== -1 && this.state !== 'stopped') {
        ListItem() {
          Column() {
            Text(this.formatTime(this.time) + '/' + this.formatTime(this.duration))
            Slider({
              value: this.time!!,
              max: this.duration
            })
              .onChange((value) => {
                this.avPlayer?.seek(value * 1000)
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
        .width('100%')
      }
      if (this.state !== 'idle' && this.state !== 'initialized') {
        ListItem() {
          Column() {
            if (this.state !== 'stopped') {
              Text('倍速：' + this.playbackRate + 'x')
              Slider({
                value: this.playbackRate!!,
                min: 0.125,
                max: 4,
                step: 0.125
              })
                .onChange((value) => {
                  this.avPlayer?.setPlaybackRate(value)
                })
            }
            Text('响度增益：' + this.loudnessGain / 10 + ' dB')
            Slider({
              value: this.loudnessGain!!,
              min: -900,
              max: 240
            })
              .onChange(async (value) => {
                await this.avPlayer?.setLoudnessGain(value / 10)
              })
            if (this.state !== 'stopped') {
              Text('音量：' + this.volume + '%')
              Slider({
                value: this.volume!!,
                min: 0,
                max: 100
              })
                .onChange((value) => {
                  this.avPlayer?.setVolume(value / 100)
                })
            }
          }
        }
        .margin({
          top: this.state === 'stopped' ? $r('sys.float.ohos_id_elements_margin_vertical_l') : 0
        })
      }
      ListItem() {
        Column() {
          if (this.state !== 'idle' && this.state !== 'initialized') {
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
                  await this.avPlayer?.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isOn)
                })
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')

            Divider()
              .padding({
                left: 12,
                right: 12
              })
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
                .onChange((isOn) => {
                  if (this.avPlayer) {
                    this.avPlayer.loop = isOn
                  }
                })
            }
            .borderRadius(12)
            .padding(12)
            .width('100%')

            if (this.isVideo) {
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
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
                  .onChange((isOn) => {
                    this.pipWindow?.setAutoStartEnabled(isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)
              .width('100%')
            }
          }
        }
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
        .padding($r('sys.float.ohos_id_corner_radius_mark'))
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
    .onAppear(async () => {
      const lastWindow = await window.getLastWindow(this.context)
      this.videoWidth = (this.UIContext.px2vp(lastWindow.getWindowProperties().windowRect.width) - 32)
      lastWindow.on('windowSizeChange', (size) => {
        this.videoWidth = (this.UIContext.px2vp(size.width) - 32)
      })
      this.pipWindow = await PiPWindow.create({
        context: this.context,
        componentController: this.xComponentController
      })

      this.dialogControllerProgress.open()
      this.avPlayer = await media.createAVPlayer()
      const mediaSource = media.createMediaSourceWithUrl(this.src, {
        Authorization: await getAccountAuthorization()
      })
      await this.avPlayer.setMediaSource(mediaSource)
      this.avPlayer.on('stateChange', async (state) => {
        this.state = state
        if (state === 'initialized') {
          if (this.avPlayer) {
            this.avPlayer.surfaceId = this.xComponentController.getXComponentSurfaceId()
            await this.avPlayer.prepare()
          }
        }
        if (state === 'prepared') {
          this.dialogControllerProgress.close()
          if (this.avPlayer) {
            this.duration = Number((this.avPlayer?.duration / 1000).toFixed(0))
            this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_SCALED_ASPECT
            if (this.avPlayer.width !== 0) {
              this.videoHeight = (this.avPlayer.height / this.avPlayer.width) * this.videoWidth
            }
            if (this.avPlayer.width === 0) {
              this.isVideo = false
            }
          }
          await this.avPlayer?.play()
        }
      })
      this.avPlayer.on('timeUpdate', (time) => {
        this.time = Number((time / 1000).toFixed(0))
      })
      this.avPlayer.on('videoSizeChange', (width, height) => {
        this.videoHeight = (height / width) * this.videoWidth
      })
      this.avPlayer.on('error', async (err) => {
        await promptAction.openToast({
          message: '发生错误，错误码：' + err.code
        })
      })
    })
    .onDisAppear(async () => {
      await this.avPlayer?.release()
    })
  }
}