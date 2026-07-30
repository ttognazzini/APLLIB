import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { clearCredentials, setCredentials, verifySignOn } from '@/api/client'

/**
 * Sign-on state. The user profile name is held here for display; the password
 * is handed straight to the API client and never stored in reactive state
 * (RULES.md S4).
 */
export const useAuthStore = defineStore('auth', () => {
  const user = ref<string | null>(null)

  const signedOn = computed(() => user.value !== null)

  async function signOn(profile: string, password: string): Promise<void> {
    const normalized = profile.trim().toUpperCase()
    const result = await verifySignOn({ user: normalized, password })
    if (result === 'bad-credentials') {
      // Deliberately vague — RULES.md S10.
      throw new Error('Invalid user profile or password')
    }
    if (result === 'not-authorized') {
      throw new Error(
        'Your user profile does not have *CHANGE authority to the APLLIB library. ' +
          'Contact the system administrator to request access.',
      )
    }
    setCredentials({ user: normalized, password })
    user.value = normalized
  }

  function signOff(): void {
    clearCredentials()
    user.value = null
  }

  return { user, signedOn, signOn, signOff }
})
