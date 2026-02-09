export function getPreferType(UIContext: UIContext) {
  const windowHeightBreakpoint = UIContext.getWindowHeightBreakpoint()
  if (windowHeightBreakpoint !== HeightBreakpoint.HEIGHT_SM) {
    return 0
  }
  if (windowHeightBreakpoint === HeightBreakpoint.HEIGHT_SM) {
    return 1
  }
  return -1
}