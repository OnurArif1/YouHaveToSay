<template>
  <div class="flex min-h-screen items-center justify-center bg-slate-100 px-4">
    <div class="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-lg">
      <h1 class="text-2xl font-semibold text-slate-900">Backoffice Giriş</h1>
      <p class="mt-1 text-sm text-slate-500">
        Admin e-postanızla giriş yapın. E-posta <code class="text-xs">Backoffice:AdminEmails</code> listesinde olmalıdır.
      </p>

      <form class="mt-6 space-y-4" @submit.prevent="onSubmit">
        <div>
          <label class="mb-1 block text-sm font-medium">E-posta</label>
          <input
            v-model="email"
            type="email"
            required
            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
            placeholder="admin@youhavetosay.com"
          />
        </div>
        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <button
          type="submit"
          class="w-full rounded-lg bg-indigo-600 py-2.5 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
          :disabled="loading"
        >
          {{ loading ? 'Giriş yapılıyor...' : 'Giriş yap' }}
        </button>
      </form>

      <p v-if="useDevAuth" class="mt-4 text-xs text-slate-400">
        Geliştirme modu: Firebase dev token ile API oturumu açılır.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { getErrorMessage } from '@/services/apiClient'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const email = ref('admin@youhavetosay.com')
const loading = ref(false)
const error = ref<string | null>(null)
const useDevAuth = import.meta.env.VITE_USE_DEV_AUTH === 'true'

async function onSubmit() {
  loading.value = true
  error.value = null
  try {
    await auth.loginWithDevEmail(email.value)
    const redirect = (route.query.redirect as string) || '/dashboard'
    await router.push(redirect)
  } catch (e) {
    error.value = auth.unauthorizedMessage ?? getErrorMessage(e)
  } finally {
    loading.value = false
  }
}
</script>
