import { ref } from 'vue'

/**
 * Theme handling: 'auto' follows the operating-system preference via the
 * prefers-color-scheme media query (and tracks live changes); 'light' /
 * 'dark' are user overrides remembered in localStorage. The resolved
 * theme is stamped on <html data-theme="…">, which main.css keys its
 * CSS-variable palettes off. index.html applies the same logic inline
 * before the app loads so there is no flash of the wrong theme.
 */
export type ThemePref = 'auto' | 'light' | 'dark'

const STORAGE_KEY = 'apllib-theme'

function readPref(): ThemePref {
  const value = localStorage.getItem(STORAGE_KEY)
  return value === 'light' || value === 'dark' ? value : 'auto'
}

export const themePref = ref<ThemePref>(readPref())

const osDark = window.matchMedia('(prefers-color-scheme: dark)')

function apply(): void {
  const resolved =
    themePref.value === 'auto' ? (osDark.matches ? 'dark' : 'light') : themePref.value
  document.documentElement.dataset.theme = resolved
}

/** Auto → Light → Dark → Auto */
export function cycleTheme(): void {
  themePref.value =
    themePref.value === 'auto' ? 'light' : themePref.value === 'light' ? 'dark' : 'auto'
  if (themePref.value === 'auto') {
    localStorage.removeItem(STORAGE_KEY)
  } else {
    localStorage.setItem(STORAGE_KEY, themePref.value)
  }
  apply()
}

// Track live OS theme changes while in auto mode.
osDark.addEventListener('change', () => {
  if (themePref.value === 'auto') {
    apply()
  }
})

apply()
