import { common } from '@kit.AbilityKit'
import { LengthMetrics, promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { hdsMaterial, HdsNavDestination } from '@kit.UIDesignKit'
import { getFlushPreference } from '../common/Preference'

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
          bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed')
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
          this.controller.loadUrl(this.url)
        })
        .onErrorReceive(async (event) => {
          await promptAction.openToast({
            message: '发生错误，错误码：' + event.error.getErrorCode() + '，错误信息：' + event.error.getErrorInfo()
          })
        })
        .onTitleReceive((event) => {
          this.title = event.title
        })
    }
    .backgroundColor($r('app.color.sheet_background'))
    .titleBar({
      padding: {
        end: LengthMetrics.vp(60)
      },
      style: {
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
      },
      enableComponentSafeArea: true
    })
    .onReady((context) => {
      this.url = context.pathInfo.param as string
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