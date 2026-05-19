import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiClient, setAuthToken } from '@/services/apiClient'

const TOKEN_KEY = 'yhts_backoffice_token'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem(TOKEN_KEY))
  const unauthorizedMessage = ref<string | null>(null)

  const isAuthenticated = computed(() => Boolean(token.value))

  function setToken(value: string) {
    token.value = value
    localStorage.setItem(TOKEN_KEY, value)
    setAuthToken(value)
  }

  function clearSession(message?: string) {
    token.value = null
    localStorage.removeItem(TOKEN_KEY)
    setAuthToken(null)
    unauthorizedMessage.value = message ?? null
  }

  async function loginWithDevEmail(email: string) {
    const firebaseToken = `dev:bo-${crypto.randomUUID()}:${email.trim()}`
    const { data } = await apiClient.post<{ accessToken: string }>(
      '/api/auth/register-or-login',
      { firebaseToken },
    )
    setToken(data.accessToken)
    await verifyAdminAccess()
  }

  async function verifyAdminAccess() {
    await apiClient.get('/api/backoffice/ping')
    unauthorizedMessage.value = null
  }

  function logout() {
    clearSession()
  }

  if (token.value) {
    setAuthToken(token.value)
  }

  return {
    token,
    isAuthenticated,
    unauthorizedMessage,
    setToken,
    clearSession,
    loginWithDevEmail,
    verifyAdminAccess,
    logout,
  }
})
