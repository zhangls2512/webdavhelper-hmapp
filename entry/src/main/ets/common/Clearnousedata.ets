import { fileIo } from '@kit.CoreFileKit'

export async function clearNouseData(context: Context) {
  const tempDir = context.tempDir
  const tempFiles = await fileIo.listFile(tempDir)
  const promises = tempFiles.map(async (item) => {
    const path = tempDir + '/' + item
    const isDirectory = fileIo.statSync(path)
    if (!isDirectory) {
      await fileIo.unlink(path)
    }
    if (isDirectory) {
      await fileIo.rmdir(path)
    }
  })
  await Promise.all(promises)
}