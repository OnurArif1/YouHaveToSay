<template>
  <div>
    <AppTopbar title="Kullanıcılar" subtitle="Oy ve kullanıcı özeti" />

    <LoadingState v-if="loading" class="mt-6" />
    <ErrorState v-else-if="error" class="mt-6" :message="error" :retry="load" />
    <template v-else-if="summary">
      <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <StatCard label="Toplam kullanıcı" :value="summary.totalUsers" />
        <StatCard label="Oy kullanan" :value="summary.totalVoters" />
        <StatCard label="Toplam oy" :value="summary.totalVotes" />
        <StatCard label="Kullanıcı başına ortalama oy" :value="summary.averageVotesPerUser" />
        <StatCard label="Bu hafta yeni kullanıcı" :value="summary.newUsersThisWeek" />
      </div>

      <section class="mt-8 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
        <h2 class="border-b border-slate-100 px-4 py-3 font-semibold">En aktif oy verenler</h2>
        <table v-if="summary.topVoters.length" class="min-w-full text-sm">
          <thead class="bg-slate-50 text-left text-slate-500">
            <tr>
              <th class="px-4 py-3">E-posta</th>
              <th class="px-4 py-3">Toplam oy</th>
              <th class="px-4 py-3">Kayıt</th>
              <th class="px-4 py-3">Son oy</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="user in summary.topVoters" :key="user.email">
              <td class="px-4 py-3">{{ user.email }}</td>
              <td class="px-4 py-3">{{ user.totalVotes }}</td>
              <td class="px-4 py-3">{{ formatDate(user.createdAt) }}</td>
              <td class="px-4 py-3">{{ user.lastVoteAt ? formatDate(user.lastVoteAt) : '—' }}</td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-else class="m-4" title="Henüz oy veren yok" />
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import AppTopbar from '@/components/AppTopbar.vue'
import StatCard from '@/components/StatCard.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import EmptyState from '@/components/EmptyState.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'
import type { BackofficeUsersSummary } from '@/types/backoffice'

const summary = ref<BackofficeUsersSummary | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

function formatDate(value: string) {
  return new Date(value).toLocaleString('tr-TR')
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const { data } = await backofficeApi.getUsersSummary()
    summary.value = data
  } catch (e) {
    error.value = getErrorMessage(e)
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>
