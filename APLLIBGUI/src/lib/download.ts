/**
 * Save a file to the user's computer. Uses the File System Access API
 * (a real "Save As" dialog) when the browser supports it — Edge and Chrome
 * do — and falls back to a normal browser download otherwise.
 */

interface SaveFileWritable {
  write: (data: Blob) => Promise<void>
  close: () => Promise<void>
}

interface SavePickerWindow {
  showSaveFilePicker?: (options: {
    suggestedName: string
    types: { description: string; accept: Record<string, string[]> }[]
  }) => Promise<{ createWritable: () => Promise<SaveFileWritable> }>
}

export async function saveFile(data: Blob, filename: string, description: string): Promise<void> {
  const extension = '.' + (filename.split('.').pop() ?? '')
  const showPicker = (window as SavePickerWindow).showSaveFilePicker
  if (showPicker) {
    try {
      const handle = await showPicker({
        suggestedName: filename,
        types: [{ description, accept: { [data.type]: [extension] } }],
      })
      const writable = await handle.createWritable()
      await writable.write(data)
      await writable.close()
      return
    } catch (e) {
      if (e instanceof DOMException && e.name === 'AbortError') {
        return // user cancelled the save dialog
      }
      // Any other failure: fall through to the plain-download path.
    }
  }
  const url = URL.createObjectURL(data)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  link.click()
  URL.revokeObjectURL(url)
}
