import { LengthMetrics } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { hidebug } from '@kit.PerformanceAnalysisKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { getSizeString } from '../common/Stringformat'

@Builder
export function DebuginfoBuilder() {
  Debuginfo()
}

@ComponentV2
struct Debuginfo {
  @Local nativeHeapSize: number = 0
  @Local nativeHeapAllocatedSize: number = 0
  @Local nativeHeapFreeSize: number = 0
  @Local cpuUsage: number = 0
  @Local appVMMemoryTotalHeap: number = 0
  @Local appVMMemoryHeapUsed: number = 0
  @Local appVMMemoryAllArraySize: number = 0
  @Local appVMObjectUsedSize: number = 0
  @Local appThreadCpuUsage: hidebug.ThreadCpuUsage[] = []
  @Local appMemoryRssLimit: number = 0
  @Local appMemoryVssLimit: number = 0
  @Local appMemoryVmHeapLimit: number = 0
  @Local appMemoryVmTotalHeapSize: number = 0
  @Local systemCpuUsage: number = 0
  @Local appNativePss: number = 0
  @Local appNativeVss: number = 0
  @Local appNativeRss: number = 0
  @Local appNativeSharedDirty: number = 0
  @Local appNativePrivateDirty: number = 0
  @Local appNativeSharedClean: number = 0
  @Local appNativePrivateClean: number = 0
  @Local systemTotalMem: number = 0
  @Local systemFreeMem: number = 0
  @Local systemAvailableMem: number = 0
  @Local gcCount: number = 0
  @Local gcTime: number = 0
  @Local gcBytesAllocated: number = 0
  @Local gcBytesFreed: number = 0
  @Local gcFullLongtimeCount: number = 0
  @Local isDebugState: boolean = false
  @Local graphicsMemory: number = 0
  intervalId = -1

  async get() {
    this.nativeHeapSize = Number(hidebug.getNativeHeapSize())
    this.nativeHeapAllocatedSize = Number(hidebug.getNativeHeapAllocatedSize())
    this.nativeHeapFreeSize = Number(hidebug.getNativeHeapFreeSize())
    this.cpuUsage = hidebug.getCpuUsage()
    const appVMMemoryInfo = hidebug.getAppVMMemoryInfo()
    this.appVMMemoryTotalHeap = Number(appVMMemoryInfo.totalHeap)
    this.appVMMemoryHeapUsed = Number(appVMMemoryInfo.heapUsed)
    this.appVMMemoryAllArraySize = Number(appVMMemoryInfo.allArraySize)
    this.appVMObjectUsedSize = Number(hidebug.getAppVMObjectUsedSize())
    this.appThreadCpuUsage = hidebug.getAppThreadCpuUsage()
    const appMemoryLimit = hidebug.getAppMemoryLimit()
    this.appMemoryRssLimit = Number(appMemoryLimit.rssLimit)
    this.appMemoryVssLimit = Number(appMemoryLimit.vssLimit)
    this.appMemoryVmHeapLimit = Number(appMemoryLimit.vmHeapLimit)
    this.appMemoryVmTotalHeapSize = Number(appMemoryLimit.vmTotalHeapSize)
    this.systemCpuUsage = hidebug.getSystemCpuUsage()
    const appNativeMemInfo = await hidebug.getAppNativeMemInfoAsync()
    this.appNativePss = Number(appNativeMemInfo.pss)
    this.appNativeVss = Number(appNativeMemInfo.vss)
    this.appNativeRss = Number(appNativeMemInfo.rss)
    this.appNativeSharedDirty = Number(appNativeMemInfo.sharedDirty)
    this.appNativePrivateDirty = Number(appNativeMemInfo.privateDirty)
    this.appNativeSharedClean = Number(appNativeMemInfo.sharedClean)
    this.appNativePrivateClean = Number(appNativeMemInfo.privateClean)
    const systemMemInfo = hidebug.getSystemMemInfo()
    this.systemTotalMem = Number(systemMemInfo.totalMem)
    this.systemFreeMem = Number(systemMemInfo.freeMem)
    this.systemAvailableMem = Number(systemMemInfo.availableMem)
    const VMRuntimeStats = hidebug.getVMRuntimeStats()
    this.gcCount = VMRuntimeStats['ark.gc.gc-count']
    this.gcTime = VMRuntimeStats['ark.gc.gc-time']
    this.gcBytesAllocated = Number(VMRuntimeStats['ark.gc.gc-bytes-allocated'])
    this.gcBytesFreed = Number(VMRuntimeStats['ark.gc.gc-bytes-freed'])
    this.gcFullLongtimeCount = VMRuntimeStats['ark.gc.fullgc-longtime-count']
    this.isDebugState = hidebug.isDebugState()
    this.graphicsMemory = await hidebug.getGraphicsMemory()
  }

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Row() {
              Text('设备型号')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(deviceInfo.marketName)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('系统版本')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(deviceInfo.displayVersion)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('API版本')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(String(deviceInfo.sdkApiVersion))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('应用版本')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text($r('app.string.app_version'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Row() {
              Text('进程内存普通块大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.nativeHeapSize))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程内存已使用普通块大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.nativeHeapAllocatedSize))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程内存空闲普通块大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.nativeHeapFreeSize))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程CPU使用率')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text((this.cpuUsage * 100).toFixed(1) + '%')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('虚拟机堆总内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appVMMemoryTotalHeap * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('虚拟机堆已使用内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appVMMemoryHeapUsed * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('虚拟机所有数组对象大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appVMMemoryAllArraySize * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('虚拟机ArkTS对象占用内存大小')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appVMObjectUsedSize * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            ForEach(this.appThreadCpuUsage, (item: hidebug.ThreadCpuUsage) => {
              Row() {
                Text('线程' + item.threadId + ' CPU使用率')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text((item.cpuUsage * 100).toFixed(1) + '%')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .textAlign(TextAlign.End)
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
            })
            Row() {
              Text('进程物理内存限制')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appMemoryRssLimit * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程虚拟内存限制')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appMemoryVssLimit * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程JS VM堆大小限制')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appMemoryVmHeapLimit * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前进程JS堆内存大小限制')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appMemoryVmTotalHeapSize * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('系统CPU占用率')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text((this.systemCpuUsage * 100).toFixed(1) + '%')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程实际占用物理内存大小 (包括共享库占用的内存)')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.nativeHeapSize))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程实际占用物理内存大小 (比例分配共享库占用的内存)')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativePss * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程实际占用虚拟内存大小 (包括共享库占用的内存)')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativeVss))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程共享脏内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativeSharedDirty * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程私有脏内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativePrivateDirty * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程共享净内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativeSharedClean * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程私有净内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.appNativePrivateClean * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('系统总内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.systemTotalMem * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('系统空闲内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.systemFreeMem * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('系统可用内存大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.systemAvailableMem * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程GC次数')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(String(this.gcCount))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程GC总耗时')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.gcTime + ' ms')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程Ark虚拟机已分配内存大小')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.gcBytesAllocated))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程GC成功回收内存大小')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.gcBytesFreed))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('当前线程超长fullGC次数')
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(String(this.gcFullLongtimeCount))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('进程处于调试状态')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(this.isDebugState ? '是' : '否')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)

            Divider()
              .padding({
                left: 12,
                right: 12
              })
            Row() {
              Text('显存总大小')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(getSizeString(this.graphicsMemory * 1024))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .textAlign(TextAlign.End)
            }
            .borderRadius(12)
            .padding(12)
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .padding($r('sys.float.ohos_id_corner_radius_mark'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem()
          .margin({
            bottom: 28
          })
      }
      .padding({
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
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
          mainTitle: '调试信息'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onAppear(async () => {
      this.intervalId = setInterval(async () => {
        await this.get()
      }, 10000)
      await this.get()
    })
    .onDisAppear(() => {
      if (this.intervalId !== -1) {
        clearInterval(this.intervalId)
      }
    })
  }
}