import { common } from '@kit.AbilityKit'
import { url } from '@kit.ArkTS'
import { LengthMetrics, LoadingDialog, promptAction } from '@kit.ArkUI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import openLink from '../common/Openlink'
import { Type } from './Autouploaderrorlogtype'

interface Body {
  and?: RuleItem[],
  or?: RuleItem[]
}

interface Response {
  success: boolean,
  data: Data
}

interface Data {
  data: Item[],
  error: string
}

interface Item {
  name: string,
  developer_name: string,
  pkg_name: string
}

interface RuleItem {
  key: string,
  op: string,
  value: string
}

@Builder
export function HmappsearchBuilder() {
  Hmappsearch()
}

@ComponentV2
struct Hmappsearch {
  @Local itemArray: Item[] = []
  @Local page: number = 1
  @Local pageSize: number = 10
  @Local logic: string = 'and'
  @Local ruleArray: RuleItem[] = []
  @Local keyIndex: number = 0
  @Local keyValue: string = '应用名称'
  @Local opIndex: number = 0
  @Local opValue: string = '等于'
  @Local value: string = ''
  @Local hoverId: number = -1
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  keyArray: Type[] = [
    {
      name: '应用名称',
      value: 'name'
    },
    {
      name: '应用包名',
      value: 'pkg_name'
    },
    {
      name: '应用 ID',
      value: 'app_id'
    },
    {
      name: '开发者 ID',
      value: 'dev_id'
    },
    {
      name: '开发者名称',
      value: 'developer_name'
    },
    {
      name: '开发者英文名称',
      value: 'dev_en_name'
    },
    {
      name: '应用描述',
      value: 'description'
    },
    {
      name: '供应商',
      value: 'supplier'
    },
    {
      name: '分类名称',
      value: 'kind_name'
    },
    {
      name: '类型名称',
      value: 'kind_type_name'
    },
    {
      name: '标签',
      value: 'tag_name'
    },
    {
      name: '最低 SDK',
      value: 'minsdk'
    },
    {
      name: '上架时间',
      value: 'listed_at'
    },
    {
      name: '目标 API',
      value: 'target_sdk'
    },
    {
      name: '包体大小',
      value: 'size_bytes'
    },
    {
      name: '总评分人数',
      value: 'total_star_rating_count'
    },
    {
      name: '下载量',
      value: 'download_count'
    },
    {
      name: '平均评分',
      value: 'average_rating'
    },
    {
      name: '价格',
      value: 'price'
    },
    {
      name: '评分次数',
      value: 'rating_count'
    },
    {
      name: '创建时间',
      value: 'created_at'
    },
    {
      name: '更新时间',
      value: 'updated_at'
    },
    {
      name: '指标时间',
      value: 'metrics_created_at'
    },
    {
      name: '评分记录时间',
      value: 'rating_created_at'
    },
    {
      name: '发布时间',
      value: 'release_date'
    },
    {
      name: '版本号',
      value: 'version'
    },
    {
      name: '版本代码',
      value: 'version_code'
    },
    {
      name: '支持设备',
      value: 'main_device_codes'
    },
    {
      name: '发行国家',
      value: 'release_countries'
    }
  ]
  opArray: Type[] = [
    {
      name: '等于',
      value: 'eq'
    },
    {
      name: '不等于',
      value: 'ne'
    },
    {
      name: '模糊匹配',
      value: 'like'
    },
    {
      name: '不包含',
      value: 'not_like'
    },
    {
      name: '模糊匹配',
      value: 'ilike'
    },
    {
      name: '不包含',
      value: 'not_ilike'
    },
    {
      name: '大于',
      value: 'gt'
    },
    {
      name: '小于',
      value: 'lt'
    },
    {
      name: '大于等于',
      value: 'gte'
    },
    {
      name: '小于等于',
      value: 'lte'
    },
    {
      name: '为空',
      value: 'is_null'
    },
    {
      name: '不为空',
      value: 'is_not_null'
    },
    {
      name: '数组包含全部元素',
      value: 'array_contains'
    },
    {
      name: '数组交集',
      value: 'array_overlaps'
    },
    {
      name: '数组被包含',
      value: 'array_contained_by'
    }
  ]

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Column() {
              Row() {
                Text('页号')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Counter() {
                  Text(String(this.page))
                }
                .enableDec(this.page > 1)
                .onInc(() => {
                  this.page++
                })
                .onDec(() => {
                  this.page--
                })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('每页个数')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Counter() {
                  Text(String(this.pageSize))
                }
                .enableDec(this.pageSize > 1)
                .onInc(() => {
                  this.pageSize++
                })
                .onDec(() => {
                  this.pageSize--
                })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('匹配逻辑')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '与' },
                  { value: '或' }
                ])
                  .selected(0)
                  .value('与')
                  .onSelect((index) => {
                    if (index === 0) {
                      this.logic = 'and'
                    }
                    if (index === 1) {
                      this.logic = 'or'
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Column() {
              Row() {
                Text('字段')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select(this.keyArray.map((item): SelectOption => {
                  return {
                    value: item.name
                  }
                }))
                  .selected(this.keyIndex!!)
                  .value(this.keyValue!!)
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('操作符')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select(this.opArray.map((item): SelectOption => {
                  return {
                    value: item.name
                  }
                }))
                  .selected(this.opIndex!!)
                  .value(this.opValue!!)
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('值')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                TextInput({
                  text: this.value!!
                })
                  .enableAutoSpacing(true)
                  .width('50%')
              }
              .borderRadius(12)
              .padding(12)
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .padding($r('sys.float.ohos_id_corner_radius_mark'))

            Button('添加筛选条件')
              .enabled(this.value.length !== 0)
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .width('100%')
              .onClick(() => {
                this.ruleArray.push({
                  key: this.keyArray[this.keyIndex].value,
                  op: this.opArray[this.opIndex].value,
                  value: this.value
                })
                this.keyIndex = 0
                this.keyValue = '应用名称'
                this.opIndex = 0
                this.opValue = '等于'
                this.value = ''
              })
            ForEach(this.ruleArray, (item: RuleItem, index) => {
              Column() {
                Row() {
                  Text('字段：' + item.key + '\n操作符：' + item.op + '\n值：' + item.value)
                    .enableAutoSpacing(true)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Image($r('app.media.delete'))
                    .height(24)
                    .onClick(() => {
                      this.ruleArray.splice(index, 1)
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_m')
              })
              .padding($r('sys.float.ohos_id_corner_radius_mark'))
            })
            Button('搜索')
              .enabled(this.ruleArray.length > 0 ? true : false)
              .margin({
                top: $r('sys.float.ohos_id_elements_margin_vertical_l')
              })
              .width('100%')
              .onClick(async () => {
                this.itemArray = []
                const body = {} as Body
                if (this.logic === 'and') {
                  body.and = this.ruleArray
                }
                if (this.logic === 'or') {
                  body.or = this.ruleArray
                }
                const dialogControllerProgress = new CustomDialogController({
                  builder: LoadingDialog({
                    content: '请求中...'
                  })
                })
                dialogControllerProgress.open()
                const session = rcp.createSession()
                try {
                  const response =
                    await session.post('http://shenjack.top:10003/api/v0/apps/query?' + new url.URLParams({
                      page: String(this.page),
                      page_size: String(this.pageSize),
                      sort: 'download_count',
                      desc: String(true)
                    }).toString(), body)
                  session.close()
                  dialogControllerProgress.close()
                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    const res = JSON.parse(String(response)) as Response
                    if (!res.success) {
                      await promptAction.openToast({
                        message: '接口调用失败，原因：' + res.data.error
                      })
                      return
                    }
                    if (res.success) {
                      this.itemArray = res.data.data
                    }
                  } else {
                    await promptAction.openToast({
                      message: 'HTTP 请求失败，状态码：' + response.statusCode
                    })
                  }
                } catch (err) {
                  session.close()
                  dialogControllerProgress.close()
                  await promptAction.openToast({
                    message: '发生错误，错误码：' + err.code
                  })
                }
              })
          }
        }
        .margin({
          bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        if (this.itemArray.length === 0) {
          ListItem() {
            Text('无数据')
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
          .width('100%')
        }
        ForEach(this.itemArray, (item: Item, index) => {
          ListItem() {
            Column() {
              Row() {
                Text('名称')
                  .enableAutoSpacing(true)
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(item.name)
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
                Text('开发者')
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text(item.developer_name)
                  .enableAutoSpacing(true)
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
                Text('应用详情')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === index ? $r('sys.color.interactive_hover') :
                    $r('sys.color.ohos_id_color_card_bg'))
                },
                pressed: {
                  .backgroundColor($r('sys.color.interactive_pressed'))
                }
              })
              .onHover((isHover) => {
                if (!isHover) {
                  this.hoverId = -1
                }
                if (isHover) {
                  this.hoverId = index
                }
              })
              .onClick(async () => {
                await this.context.openLink('https://appgallery.huawei.com/app/detail?id=' + item.pkg_name)
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        })
        ListItem() {
          Text() {
            Span('数据来源：')
              .fontColor($r('sys.color.font_secondary'))
            Span('http://shenjack.top:10003')
              .fontColor($r('sys.color.font_emphasize'))
              .onClick(async () => {
                await openLink(this.context, 'http://shenjack.top:10003')
              })
          }
          .fontSize($r('sys.float.ohos_id_text_size_body3'))
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })
        .width('100%')

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
          mainTitle: '鸿蒙应用搜索'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
  }
}