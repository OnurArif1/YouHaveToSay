import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/pages/LoginPage.vue'),
      meta: { public: true },
    },
    {
      path: '/',
      component: () => import('@/layouts/AdminLayout.vue'),
      children: [
        { path: '', redirect: '/dashboard' },
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('@/pages/DashboardPage.vue'),
        },
        {
          path: 'comparisons',
          name: 'comparisons',
          component: () => import('@/pages/ComparisonsListPage.vue'),
        },
        {
          path: 'comparisons/create',
          name: 'comparison-create',
          component: () => import('@/pages/ComparisonCreatePage.vue'),
        },
        {
          path: 'comparisons/:id/edit',
          name: 'comparison-edit',
          component: () => import('@/pages/ComparisonEditPage.vue'),
          props: true,
        },
        {
          path: 'comparisons/:id/results',
          name: 'comparison-results',
          component: () => import('@/pages/ComparisonResultsPage.vue'),
          props: true,
        },
        {
          path: 'users',
          name: 'users',
          component: () => import('@/pages/UsersPage.vue'),
        },
        {
          path: 'settings',
          name: 'settings',
          component: () => import('@/pages/SettingsPage.vue'),
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (!to.meta.public && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (to.name === 'login' && auth.isAuthenticated) {
    return { name: 'dashboard' }
  }
})

export default router
