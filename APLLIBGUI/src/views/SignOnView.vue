<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()

const user = ref('')
const password = ref('')
const error = ref('')
const busy = ref(false)

async function submit() {
  error.value = ''
  busy.value = true
  try {
    await auth.signOn(user.value, password.value)
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    router.push(redirect)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Sign-on failed'
    password.value = ''
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <div class="page">
    <form class="card" @submit.prevent="submit">
      <img
        src="/apllib-logo.svg"
        alt="APLLIB — Application Development Library"
        class="logo logo-light"
      />
      <img
        src="/apllib-logo-dark.svg"
        alt="APLLIB — Application Development Library"
        class="logo logo-dark"
      />
      <p class="subtitle">Sign on with your IBM i user profile</p>

      <div v-if="error" class="error">{{ error }}</div>

      <label class="field">
        <span>User profile</span>
        <input
          v-model="user"
          type="text"
          name="user"
          maxlength="10"
          autocomplete="username"
          autocapitalize="characters"
          spellcheck="false"
          class="upper"
          required
          autofocus
        />
      </label>

      <label class="field">
        <span>Password</span>
        <input
          v-model="password"
          type="password"
          name="password"
          autocomplete="current-password"
          required
        />
      </label>

      <button type="submit" class="submit" :disabled="busy">
        {{ busy ? 'Signing on…' : 'Sign on' }}
      </button>
    </form>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: var(--color-sidebar);
}

.card {
  width: 340px;
  padding: 32px;
  background: var(--color-surface);
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}

.logo {
  display: block;
  width: 100%;
  height: auto;
}

/* Theme-matched logo variants (RULES.md U5) — the light-lettered SVG
   shows on dark backgrounds, the dark-lettered one on light. */
.logo-dark {
  display: none;
}

:root[data-theme='dark'] .logo-light {
  display: none;
}

:root[data-theme='dark'] .logo-dark {
  display: block;
}

.subtitle {
  margin: 10px 0 22px;
  text-align: center;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.error {
  margin-bottom: 14px;
  padding: 10px 12px;
  border-radius: 6px;
  background: var(--color-error-bg);
  color: var(--color-error);
  font-size: 0.9rem;
}

.field {
  display: block;
  margin-bottom: 14px;
}

.field span {
  display: block;
  margin-bottom: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-muted);
}

.field input {
  width: 100%;
  padding: 9px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
}

.field input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
  border-color: var(--color-primary);
}

.upper {
  text-transform: uppercase;
}

.submit {
  width: 100%;
  margin-top: 8px;
  padding: 10px;
  border: none;
  border-radius: 6px;
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}

.submit:hover:enabled {
  background: var(--color-primary-hover);
}

.submit:disabled {
  opacity: 0.7;
  cursor: default;
}
</style>
