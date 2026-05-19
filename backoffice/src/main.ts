import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { setAuthHandlers } from './services/apiClient'
import { useAuthStore } from './stores/authStore'
import './styles/index.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

const auth = useAuthStore()
setAuthHandlers({
  onUnauthorized: () => {
    auth.clearSession('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.')
    router.push({ name: 'login' })
  },
  onForbidden: (message) => {
    auth.clearSession(message || 'Bu panele erişim yetkiniz yok.')
    router.push({ name: 'login' })
  },
})

app.mount('#app')
