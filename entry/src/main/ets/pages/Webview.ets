import { common } from '@kit.AbilityKit'
import { uri } from '@kit.ArkTS'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { getFlushPreference } from '../common/Preference'

interface UrlTrustList {
  UrlPermissionList: UrlPermissionItem[]
}

export interface Param {
  url: string,
  trust: boolean
}

interface UrlPermissionItem {
  scheme: string,
  host: string,
  port?: number,
  path: string
}

@Builder
export function WebviewBuilder() {
  Webview()
}

@ComponentV2
struct Webview {
  @Local url: string = ''
  @Local darkMode: WebDarkMode = WebDarkMode.Auto
  @Local optimizeParserBudget: boolean = false
  @Local title: string = ''
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  controller = new webview.WebviewController()
  trust = false

  build() {
    HdsNavDestination() {
      Web({
        src: this.url,
        controller: this.controller,
        incognitoMode: true
      })
        .darkMode(this.darkMode)
        .enableDataDetector(true)
        .enableNativeEmbedMode(true)
        .geolocationAccess(false)
        .margin({
          bottom: 28,
          top: 64
        })
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_ONLY,
          scrollBackward: NestedScrollMode.SELF_ONLY
        })
        .optimizeParserBudget(this.optimizeParserBudget)
        .pinchSmooth(true)
        .onControllerAttached(() => {
          this.controller.enableAdsBlock(true)
          this.controller.enableIntelligentTrackingPrevention(true)
          this.controller.enableSafeBrowsing(true)
          this.controller.setErrorPageEnabled(true)
          if (this.trust) {
            const urlTrustList = {
              UrlPermissionList: []
            } as UrlTrustList
            const uriobject = new uri.URI(this.url)
            const port = Number(uriobject.port)
            if (port !== -1) {
              urlTrustList.UrlPermissionList.push({
                scheme: uriobject.scheme,
                host: uriobject.host,
                port: port,
                path: uriobject.path.substring(1)
              })
            }
            if (port === -1) {
              urlTrustList.UrlPermissionList.push({
                scheme: uriobject.scheme,
                host: uriobject.host,
                path: uriobject.path.substring(1)
              })
            }
            this.controller.setUrlTrustList(JSON.stringify(urlTrustList), true, false)
          }
          this.controller.loadUrl(this.url)
        })
        .onErrorReceive(async (event) => {
          await promptAction.openToast({
            message: '发生错误，错误码：' + event.error.getErrorCode() + '，错误信息：' + event.error.getErrorInfo()
          })
        })
        .onTitleReceive(event => {
          this.title = event.title
        })
    }
    .backgroundColor($r('app.color.sheet_background'))
    .recoverable(true)
    .titleBar({
      padding: {
        end: LengthMetrics.vp(60)
      },
      style: {
        scrollEffectOpts: {
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR
        },
        originalStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('sys.color.font_primary')
            },
            backIconStyle: {
              iconColor: $r('sys.color.icon_primary')
            }
          }
        },
        thermoCtrl: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      },
      content: {
        title: {
          mainTitle: this.title
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady(context => {
      const param = context.pathInfo.param as Param
      this.url = param.url
      this.trust = param.trust
      const colorMode = getFlushPreference(this.context, 'commonSetting', 'colorMode', 0)
      if (colorMode === 0) {
        this.darkMode = WebDarkMode.Auto
      }
      if (colorMode === 1) {
        this.darkMode = WebDarkMode.Off
      }
      if (colorMode === 2) {
        this.darkMode = WebDarkMode.On
      }
      this.optimizeParserBudget =
        getFlushPreference(this.context, 'debugSetting', 'optimizeParserBudget', true) as boolean
      const destroyMode = getFlushPreference(this.context, 'debugSetting', 'destroyMode',
        webview.WebDestroyMode.NORMAL_MODE) as webview.WebDestroyMode
      webview.WebviewController.setWebDestroyMode(destroyMode)
    })
  }
}