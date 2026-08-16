export function getPreferType(UIContext: UIContext) {
  const windowHeightBreakpoint = UIContext.getWindowHeightBreakpoint()
  if (windowHeightBreakpoint === HeightBreakpoint.HEIGHT_SM) {
    return SheetType.CENTER
  }
  return SheetType.BOTTOM
}