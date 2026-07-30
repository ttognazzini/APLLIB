export interface NavItem {
  label: string
  to: string
  /** Icon name understood by AppIcon.vue */
  icon: string
}

/**
 * Sidebar menu entries, in display order.
 * To add a screen: add a route in router/index.ts, then one entry here
 * (and a matching icon in AppIcon.vue if it needs a new one).
 */
export const navItems: NavItem[] = [
  { label: 'Home', to: '/', icon: 'home' },
  { label: 'Segments', to: '/segments', icon: 'segments' },
  { label: 'Dictionaries', to: '/dictionaries', icon: 'dictionaries' },
  { label: 'Files', to: '/files', icon: 'files' },
]
